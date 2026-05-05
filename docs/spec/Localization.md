# PvPster - Localization 명세

> i18n 엔진. 사용 측 문자열 테이블 `PvPster.L`을 mutate-in-place로 갱신하고, 각 locale 파일은 데이터만 들고 있다.

엔진 구현은 `Localization.lua`, locale 데이터는 `Locales/{key}.lua` (10개), 도메인 키워드 매핑(스탯 키워드, 인챈트 ID → stat 키)은 `Constants.lua`.

---

## 디자인 원칙

1. **L은 절대 교체하지 않는다, mutate-in-place** — 다른 모듈이 파일 로드 시점에 `local L = PvPster.L`로 reference를 캡처해 사용. 테이블 자체를 갈아끼우면 그 캡처들이 stale 참조가 되어 hot-swap이 깨진다.
2. **데이터는 파일 분리, 엔진은 단일** — 각 `Locales/{key}.lua`는 단순히 `LOCALE_REGISTRY`에 push만. 엔진(`Localization.lua`)은 레지스트리만 본다. 새 locale 추가 = 파일 1개 + `.toc` 한 줄.
3. **per-key enUS 폴백** — 비-enUS locale이 일부 키를 누락해도 raw 키 노출 없이 enUS 값으로 자동 폴백.
4. **enUS는 필수 (whole-locale fallback)** — enUS가 없으면 명시적으로 `error()`. 다른 locale은 부분 번역 OK.

---

## 데이터 흐름

```
.toc 로드 순서:
    Locales/enUS.lua          → LOCALE_REGISTRY.strings.enUS = { ... }
                                LOCALE_REGISTRY.names.enUS = "English"
                                LOCALE_REGISTRY.order = { "enUS" }
    Locales/koKR.lua          → strings.koKR = { ... }, names.koKR = "한국어",
                                order = { "enUS", "koKR" }
    Locales/frFR.lua          → ...
    ... (총 10개)
    Localization.lua          → 레지스트리 스냅샷, applyLocale(getClientLocale()) 즉시 호출
    Constants.lua, ..., Core.lua  → 다른 모듈 로드 (이 시점엔 L에 client locale 적용 완료)
    ADDON_LOADED              → DB 준비 후 Localization:Apply(DB.ui.locale)로 사용자 preference 적용
```

> Localization.lua가 파일 로드 시점에 한 번 적용하는 이유: 다른 모듈이 top-level 표현식에서 `local L = PvPster.L`을 캡처해도 빈 테이블이 잡히지 않게 하기 위함. ADDON_LOADED에서 DB의 저장된 preference로 다시 적용.

---

## 레지스트리 구조

```lua
PvPster.LOCALE_REGISTRY = {
    strings = {
        enUS = { ["PvPster"] = "PvPster", ["Sync"] = "Sync", ... },
        koKR = { ["Sync"] = "동기화", ["Show"] = "열기", ... },
        -- 비-enUS는 부분 번역 OK
    },
    names = {
        enUS = "English",
        koKR = "한국어",
        -- locale별 native name (UI 드롭다운/도움말용)
    },
    order = { "enUS", "koKR", "frFR", ... },  -- .toc 로드 순서 = 드롭다운 표시 순서
}
```

각 `Locales/{key}.lua`는 다음 패턴:

```lua
local _, PvPster = ...

PvPster.LOCALE_REGISTRY = PvPster.LOCALE_REGISTRY or {
    strings = {}, names = {}, order = {},
}

local KEY = "koKR"
table.insert(PvPster.LOCALE_REGISTRY.order, KEY)
PvPster.LOCALE_REGISTRY.names[KEY] = "한국어"
PvPster.LOCALE_REGISTRY.strings[KEY] = {
    ["Sync"] = "동기화",
    -- ...
}
```

> enUS는 다른 모든 locale의 폴백이라 모든 키를 가져야 한다. 비-enUS는 누락된 키만큼 enUS로 폴백.

---

## Resolution 알고리즘

```
resolveLocale(preference):
    1. preference == nil 또는 "auto"  → getClientLocale() 결과 사용
    2. preference가 LOCALES에 존재    → 그대로 사용
    3. 그 외                           → getClientLocale() 결과 사용 (안전 폴백)

getClientLocale():
    1. GetLocale() 결과가 LOCALES에 있으면 그대로
    2. 없으면 enUS (예: deDE 클라가 아닌데 LOCALES에 deDE가 없는 경우는 없음 —
       이 코드 경로는 미래 안전장치)
```

상수:

```lua
DEFAULT_LOCALE = "enUS"
AUTO_KEY = "auto"
```

---

## L 테이블 갱신

```
applyLocale(localeKey):
    1. clearTable(L)                                  -- 기존 키 제거 (mutate-in-place)
    2. L에 enUS 전체 복사                              -- per-key 폴백을 위해 먼저 깔기
    3. localeKey != enUS면 active locale을 overlay   -- 누락 키는 enUS 그대로 남음
    4. currentLocale = localeKey
```

L에는 메타테이블이 걸려 있어 **누락 키는 키 자체를 반환**:

```lua
setmetatable(L, {
    __index = function(_, key) return key end,
})
```

- per-key 폴백 덕에 정상 경로에서는 메타테이블이 거의 안 타지만, enUS에도 없는 신규 키를 코드가 잘못 참조하면 raw 키가 그대로 노출되어 디버깅 단서가 됨 (silent fail보다 나음).
- enUS 자체가 누락된 경우는 별도 `error()`로 즉시 실패.

---

## 모듈 API

```lua
-- 적용 없이 effective locale만 계산 (current 표시용)
function Localization:Resolve(preference)
    return resolveLocale(preference)
end

-- preference에 해당하는 effective locale을 적용 + 반환
function Localization:Apply(preference)
    local effective = resolveLocale(preference)
    applyLocale(effective)
    return effective
end

-- GetLocale()를 지원 locale로 정규화한 결과 (UI 보조용)
function Localization:GetClientLocale() ... end

-- 현재 적용된 locale 키 (예: "enUS", "koKR")
function Localization:GetCurrent() ... end

-- 드롭다운/도움말용. 등록 순서대로 [{ key, nativeName }, ...] 반환
function Localization:GetSupportedLocales() ... end

-- "auto"도 true. 외부 입력 검증용 (Slash 명령 등)
function Localization:IsSupported(localeKey) ... end

-- 옵션 라벨용 native name (예: "한국어"). 없으면 localeKey 그대로 반환
function Localization:GetNativeName(localeKey) ... end
```

---

## 키 카탈로그 (enUS 기준)

`Locales/enUS.lua`가 단일 소스. 카테고리는 파일 내 주석으로만 구분되고 코드상으로는 평면 dict. 주요 카테고리:

| 카테고리 | 키 예시 |
|---------|--------|
| General | `PvPster`, `Sync`, `Show`, `Hide`, `Reset`, `Help`, `Close` |
| Columns | `Name`, `Realm`, `Level`, `iLvl`, `Honor`, `Conquest`, `BRACKET_2V2`, `BRACKET_3V3`, `BRACKET_SHUFFLE`, `BRACKET_BLITZ`, `LastSeen` |
| Empty state | `NoCharactersTitle`, `NoCharactersBody` |
| Footer | `LastSync`, `JustNow`, `MinutesAgo`, `HoursAgo`, `DaysAgo` |
| Slash messages | `DataResetConfirm`, `DataReset`, `SyncDone`, `DebugOn`, `DebugOff`, `UnknownCommand`, `HelpCommands`, `LocaleCurrent`, `LocaleSet`, `LocaleSupported`, `LocaleUnsupported` |
| Tooltip headings | `AverageItemLevel`, `Equipment`, `Currencies`, `Ratings`, `WeeklyShort`, `SeasonShort`, `WinRate`, `WinLossRecord`, `AccountHonor`, `Enchant`, `Gem` |
| Minimap | `LeftClickToggle`, `RightClickDebug`, `DragToReposition`, `MinimapShown`, `MinimapHidden` |
| Misc UI | `Language`, `ScaleLabel`, `ScaleSet`, `StateOn`, `StateOff` |
| Class names | `CLASS_WARRIOR`, `CLASS_PALADIN`, `CLASS_HUNTER`, ... (13개) |
| Race names | `RACE_HUMAN`, `RACE_NIGHTELF`, ... (~25개) |
| Stat keywords (보석/인챈트 표기용) | `STAT_HASTE`, `STAT_CRIT`, `STAT_VERSATILITY`, `STAT_MASTERY`, `STAT_LEECH`, `STAT_AVOIDANCE`, `STAT_SPEED`, `STAT_INDESTRUCTIBLE`, ... |
| Enchant override (Wowhead 기반 stat) | `ENCHANT_STATS_*` 키들 — `Constants.ENCHANT_STATS_BY_ID[enchantID]`가 가리키는 L 키 |

> 신규 키 추가 시: enUS에 반드시 등록. 다른 locale은 누락해도 됨(자동 폴백). UI 코드에서 `L["..."]` 직접 참조 시 enUS 등록을 깜박하면 메타테이블이 raw 키를 반환하므로 디버깅 가능.

---

## 도메인별 i18n 메커니즘

UI에 표시되는 문자열은 출처가 다양해서, 단순 키 룩업으로 처리할 수 없는 두 가지 케이스에 별도 메커니즘이 있다.

### 1. 종족/직업명 — locale-independent ID 룩업

캡처 시점의 클라이언트 locale 표기 대신 `classFile` / `raceFile`(예: `"WARRIOR"`, `"NightElf"`)을 DB에 저장. UI 렌더 시 `L["CLASS_" .. classFile]` / `L["RACE_" .. raceFile]`로 룩업해 활성 애드온 locale로 표시. 룩업 실패 시 캡처된 `classLocalized` 등으로 폴백.

이렇게 하면 사용자가 한국어 클라에서 캐릭을 캡처한 뒤 영어로 언어를 바꿔도 직업/종족이 영어로 표시된다 (재수집 없이).

### 2. 인챈트 stat 오버라이드 — Wowhead 기반 매핑

WoW가 인챈트 툴팁에서 stat을 명시적으로 보여주지 않는 경우(예: `"Mark of the Magister"`)가 있다. PvPster는 이를 보완하기 위해 Wowhead에서 검증된 stat 정보를 `Constants.ENCHANT_STATS_BY_ID`로 매핑한다.

```lua
ENCHANT_STATS_BY_ID = {
    [enchantID] = "ENCHANT_STATS_xxx",  -- L 키 (locale별 stat 텍스트)
}
```

UI 렌더 시점에 `enchantID`로 룩업해서 raw `enchantName` 뒤에 stat을 합성. **합성을 캡처가 아닌 렌더 시점에 하기 때문에 locale 변경 시 재수집 없이 stat 표기가 바뀐다** (이게 v1 → v2 마이그레이션의 핵심 동기).

### 3. 보석 stat 텍스트 — 클라 locale → 활성 locale 키워드 치환

보석 툴팁의 stat 라인은 `getGemStatText`가 클라이언트 locale로 캡처(예: 한국어 클라면 `"특화 +16 / 가속 +7"`). 사용자가 영어로 언어를 바꾸면 이걸 `"Mastery +16 / Haste +7"`로 보여줘야 한다.

`Constants.STAT_KEYWORDS`는 10 locale × 12 stat의 패턴 테이블. UI 렌더 시점에 `Localization:GetCurrent()`로 활성 locale을 알아낸 뒤, 캡처 시점의 클라이언트 locale 키워드를 활성 locale 키워드로 치환.

> Pawn / RatingBuster / ElvUI의 stat 키워드 테이블과 교차 검증된 Blizzard 공식 용어 기반. deDE는 Wowhead spell 페이지로 직접 확인.

---

## 새 locale 추가 절차

1. `Locales/enUS.lua`를 복사해 `Locales/{newKey}.lua` 생성
2. 파일 상단의 `local KEY = "{newKey}"`로 변경, `LOCALE_REGISTRY.names[KEY] = "{NativeName}"`
3. strings 테이블의 값들을 번역 (전체일 필요 없음, 누락은 enUS 폴백)
4. `PvPster.toc`의 `Locales/` 블록에 한 줄 추가 (`Localization.lua`보다 위)
5. (선택) `Constants.STAT_KEYWORDS`에 해당 locale의 stat 키워드 패턴 12종 추가 — 보석 stat 표시를 활성 locale로 치환하려면 필수
6. (선택) `Locales/{newKey}.lua`에 `CLASS_*`, `RACE_*` 키들 추가 — 종족/직업명 현지화

`Slash.lua` / `Localization.lua` / 다른 모듈은 손댈 필요 없음. 도움말/드롭다운/Slash lang 인자가 새 locale을 자동으로 인식.

---

## 안전장치 / Invariants

- **enUS 부재 시 즉시 fail** — `Localization.lua` 로드 시점에 enUS strings 누락이면 `error()`로 명시적 실패 (silent degradation 회피)
- **L은 단 한 번만 생성** — 모듈 시작에서 `local L = {}` + `PvPster.L = L`, 이후 절대 교체 X
- **applyLocale은 clearTable 후 재구성** — 이전 locale의 키가 남아있으면 새 locale에 없는 키가 leak. clear → enUS 깔기 → overlay 순서 보장
- **메타테이블 폴백은 디버깅용** — 정상 경로에서는 enUS per-key 폴백이 먼저 작동. raw 키가 화면에 보이면 enUS에서도 그 키가 빠진 것
- **`.toc` 순서 의존성** — `Locales/*` 가 `Localization.lua`보다 먼저 로드되어야 레지스트리가 채워진 상태로 엔진이 본다. enUS는 다른 locale보다 먼저 로드 (드롭다운 표시 순서를 위해)
