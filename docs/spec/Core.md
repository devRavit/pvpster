# PvPster - Core 명세

> Core, DB, Logger, Slash 책임 정의 (i18n 엔진은 [Localization.md](./Localization.md))

---

## Core 모듈

### 책임

- 애드온 진입점 (`ADDON_LOADED` 핸들링)
- 전역 namespace `PvPster` 노출
- 다른 모듈(Localization, DB, Logger, Collector, UI, Minimap, Slash) 초기화 순서 제어
- 이벤트 프레임 한 개 보유 후 모든 이벤트 멀티플렉싱

### 전역 Namespace

```lua
_G.PvPster = {
    Version = "...",       -- C_AddOns.GetAddOnMetadata 으로 빌드 시 채워짐
    L = {},                -- Localization 문자열 테이블 (mutate-in-place)
    LOCALE_REGISTRY = {    -- 각 Locales/*.lua가 push 하는 레지스트리
        strings = {},      --   { [localeKey] = { [stringKey] = "..." } }
        names = {},        --   { [localeKey] = "한국어" 등 native name }
        order = {},        --   .toc 로드 순서 (드롭다운 표시 순서)
    },
    Constants = {},        -- 상수 (DB_VERSION, UI_DEFAULTS, TRACKED_BRACKETS, ITEM_SLOTS, ENCHANT_STATS_BY_ID, STAT_KEYWORDS, ...)
    Logger = {},           -- 로그 (PvPsterLogs)
    DB = {},               -- DB 모듈 (PvPsterDB)
    Localization = {},     -- i18n 엔진 — 자세한 API는 Localization.md
    Theme = {},            -- 색상/스타일 토큰
    Collector = {},        -- 데이터 수집
    UI = {},               -- UI 창
    Minimap = {},          -- 미니맵 버튼
    Slash = {},            -- 슬래시 명령 디스패치
    Core = {},             -- 진입점
}
```

### 초기화 순서

```
ADDON_LOADED("PvPster")
    └─ Logger:Initialize()
    └─ DB:Initialize()                              -- SavedVariables 마이그레이션
    └─ Localization:Apply(DB:GetUIState().locale)   -- 저장된 언어 설정 적용 (없으면 client locale)
    └─ Collector:Initialize()                       -- 이벤트 등록
    └─ UI:Initialize()                              -- 프레임 생성 (숨김 상태)
    └─ Minimap:Initialize()                         -- 미니맵 버튼
    └─ Slash:Initialize()                           -- /pvpster 등록

PLAYER_LOGIN
    └─ RequestRatedInfo()           -- 레이팅 캐시 워밍
    └─ RequestPVPRewards()          -- 정복 cap / 보상 데이터 워밍

PLAYER_ENTERING_WORLD (첫 진입)
    └─ Collector:RunFullSync()      -- 전체 데이터 갱신
```

> Localization은 파일 로드 시점에도 `applyLocale(getClientLocale())`로 한 번 적용됨 — 다른 모듈이 top-level에서 `local L = PvPster.L`을 읽어도 빈 테이블이 잡히지 않게 하기 위함. DB가 준비되는 `ADDON_LOADED`에서 저장된 preference로 다시 적용.

### 이벤트 디스패치

```lua
local eventHandlers = {
    PLAYER_ENTERING_WORLD = function() Collector:OnEnteringWorld() end,
    PVP_RATED_STATS_UPDATE = function() Collector:UpdateRatings() end,
    CURRENCY_DISPLAY_UPDATE = function() Collector:UpdateCurrencies() end,
    PLAYER_EQUIPMENT_CHANGED = function() Collector:UpdateEquipment() end,
    PLAYER_LEVEL_UP = function(level) Collector:UpdateCharacter() end,
    PLAYER_LOGOUT = function() Collector:RunFullSync() end,
}
```

업데이트 후에는 항상 `UI:Refresh()` 호출 (창이 보일 때만 실제 갱신).

---

## DB 모듈

### SavedVariables

`PvPster.toc` 선언:

```
## SavedVariables: PvPsterDB, PvPsterLogs
```

- `PvPsterDB` — 캐릭터 데이터 + UI 상태 (계정 공유)
- `PvPsterLogs` — 디버그 로그 (계정 공유, 옵션) — Logger 모듈 섹션 참조

### 스키마

> `version` 값은 `Constants.DB_VERSION` 단일 소스에서 결정. 현재 v2.

```lua
PvPsterDB = {
    version = 2,                       -- Constants.DB_VERSION (현재 2)
    characters = {
        ["Azshara-Ravit"] = {
            -- 식별 정보
            name = "Ravit",
            realm = "Azshara",
            classFile = "WARRIOR",          -- 로케일-무관 ID (UI에서 L["CLASS_WARRIOR"]로 룩업)
            classLocalized = "전사",         -- 캡처 시점의 로컬 표기 (폴백용)
            raceFile = "Human",             -- 로케일-무관 ID
            faction = "Alliance",           -- "Alliance" / "Horde"
            level = 80,
            gender = 2,                     -- 2=남, 3=여
            lastSeen = 1714539600,          -- Unix timestamp

            -- 화폐
            currency = {
                honor = {
                    quantity = 1500,
                    totalEarned = 8500,
                    maxQuantity = 15000,
                },
                accountHonor = {
                    quantity = 0,
                    totalEarned = 0,
                    maxQuantity = 0,
                },
                conquest = {
                    quantity = 825,
                    totalEarned = 825,
                    maxQuantity = 1350,
                    useTotalEarnedForMaxQty = true,
                },
            },

            -- 레이팅 (key = bracketIndex)
            ratings = {
                [1] = {                          -- 2v2
                    rating = 1850,
                    seasonBest = 1920,
                    weeklyBest = 1880,
                    seasonPlayed = 120,
                    seasonWon = 70,
                    weeklyPlayed = 15,
                    weeklyWon = 9,
                    pvpTier = 4,
                    -- 솔셔/블리츠 전용 (다른 종목은 nil)
                    roundsSeasonPlayed = nil,
                    roundsSeasonWon = nil,
                    roundsWeeklyPlayed = nil,
                    roundsWeeklyWon = nil,
                },
                [2] = { ... },                   -- 3v3
                [7] = { ... },                   -- Solo Shuffle (rounds 필드 있음)
                [9] = { ... },                   -- Blitz (rounds 필드 있음)
            },

            -- 장비
            equipment = {
                averageItemLevel = 642.5,
                averageItemLevelEquipped = 640.0,
                averageItemLevelPvP = 645.0,
                slots = {
                    [1] = {                              -- Head
                        itemLink = "|cffa335ee|Hitem:...|h[Item Name]|h|r",
                        itemLevel = 642,
                        pvpItemLevel = 645,              -- PvP 환경 ilvl (참고용)
                        quality = 4,
                        enchantID = 1234,                -- 로케일-무관 (UI 렌더 시 stat 오버라이드 룩업)
                        enchantName = "Mark of the Magister",  -- 클라이언트 locale 캡처 (raw, stat override 미포함)
                        gemLinks = { "|Hitem:213743:..." },     -- 보석 아이템 링크 배열
                        gemStats = { "특화 +16 / 가속 +7" },     -- 캡처 시점의 stat 텍스트 (UI 렌더 시 키워드 치환)
                    },
                    -- ...
                },
            },
        },
    },
    ui = {
        position = { point = "CENTER", x = 0, y = 0 },
        size = { width = 1024, height = 540 },     -- Constants.UI_DEFAULTS 참조
        sortColumn = "name",                       -- 정렬 컬럼 키
        sortDirection = "asc",                     -- "asc" / "desc"
        visible = false,
        minimapVisible = true,
        minimapAngle = 225,
        uiScale = 1.0,
        theme = "github",
        locale = "auto",                           -- "auto" 또는 10개 locale 키 중 하나 (Localization.md 참조)
    },
}
```

### 주요 함수

```lua
function DB:Initialize()
    -- PvPsterDB 없으면 defaultStorage()로 생성
    -- 있으면 migrate() 후 ensureField()로 새 필드 backfill
end

function DB:Get()
    -- _G.PvPsterDB 직접 반환 (저수준 접근용)
end

function DB:GetCharacterKey()
    -- "{realm}-{name}" 반환 (현재 캐릭터). realm은 GetNormalizedRealmName 우선,
    -- 폴백은 GetRealmName, 둘 다 nil이면 "Unknown"
end

function DB:GetCharacter(key)
    -- 키 없으면 nil 반환
end

function DB:UpsertCharacter(key, partial)
    -- 부분 업데이트 (기존 필드 보존, partial의 키만 덮어쓰기)
end

function DB:GetAllCharacters()
    -- {key: data} 전체 반환
end

function DB:CountCharacters()
    -- 캐릭터 수
end

function DB:RemoveCharacter(key)
    -- 캐릭터 삭제
end

function DB:Reset()
    -- characters만 비움 (UI 설정/창 위치/테마/스케일/locale/minimap 보존)
    -- /pvpster reset confirm 으로 트리거됨
end

function DB:GetUIState()
    -- ui 테이블 반환
end

function DB:SaveUIState(field, value)
    -- ui[field] = value
end

function DB:PropagateAccountCurrency(currencyKey, value)
    -- 계정 공유 화폐(예: 계정 명예)를 모든 캐릭터 entry에 전파
    -- 진실의 원천이 캐릭터가 아닌 계정에 있는 항목에 사용
end
```

### 마이그레이션 정책

`PvPsterDB.version != Constants.DB_VERSION` 일 때 `migrate()` 호출:

- **`characters`만 비우고 `version`만 갱신**한다. UI 설정(창 위치/테마/스케일/locale/sort/미니맵)은 그대로 보존.
- 단계별 마이그레이션 함수(`MigrateV1ToV2()` 같은 것)는 두지 않는다. 마이그레이션 사유가 "수집된 데이터 형태가 달라져 surgical 변환이 위험할 때"인 경우 단순 wipe + 재수집이 가장 안전.

#### v1 → v2 (현재 적용 중)

v1에서는 `enchantName`을 캡처 시점에 Wowhead 기반 stat 오버라이드까지 합쳐서 저장 (예: `"Mark of the Magister - +? 지능 / +? 최대 마나"`). v2는 `enchantName`을 raw 그대로 저장하고 stat 오버라이드는 UI 렌더 시점에 `Constants.ENCHANT_STATS_BY_ID[enchantID] → L[key]`로 합성. locale 변경 시 재수집 없이 stat 표기가 갱신된다.

v1 문자열을 surgically un-merge 하는 건 신뢰성이 낮아 wipe가 더 안전.

---

## Logger 모듈

### 책임

- print() 직접 호출 금지 (CLAUDE.md 규칙)
- 로그를 SavedVariables(`PvPsterLogs`)에 누적
- 디버그 모드에서만 채팅에도 출력
- 최대 500개 항목 (`MAX_LOGS`, 초과 시 오래된 것 `table.remove`)

### 인터페이스

```lua
function Logger:Initialize()
    -- _G.PvPsterLogs 없으면 { debugEnabled=false, entries={} } 생성
end

function Logger:Log(module, message)
    -- "[YYYY-MM-DD HH:MM:SS] [Module] message"
    -- pcall로 감싸 SavedVariables 쓰기 실패 시 로그 흐름이 끊기지 않게
end

function Logger:Debug(module, message)
    -- :Log()로 저장 + debugEnabled일 때만 채팅 출력
    --   포맷: "|cff5599ff[PvPster]|r module: message"
end

function Logger:SetDebug(enabled)
    -- _G.PvPsterLogs.debugEnabled 토글
end

function Logger:IsDebug()
    -- debugEnabled 조회
end

function Logger:Clear()
    -- entries = {}
end

function Logger:GetEntries()
    -- entries 반환 (없으면 빈 테이블)
end
```

### 저장 형식

```lua
PvPsterLogs = {
    debugEnabled = false,
    entries = {
        "[2026-05-01 14:23:11] [Collector] Full sync complete: 4 brackets, 3 currencies",
        ...
    },
}
```

---

## Slash 모듈

### 등록

```
/pvpster, /pvps
```

대소문자 구분 없이 처리(`input:lower()`). 알 수 없는 명령은 `L["UnknownCommand"]` 응답.

### 서브커맨드

| 커맨드 | 동작 |
|--------|------|
| `/pvpster` | 창 토글 (열림/닫힘) |
| `/pvpster show` | 창 열기 |
| `/pvpster hide` | 창 닫기 |
| `/pvpster sync` | 현재 캐릭 강제 재수집 (`Collector:RunFullSync`) |
| `/pvpster reset` | 안내 메시지만 출력 (`L["DataResetConfirm"]`) |
| `/pvpster reset confirm` | 실제 DB 초기화 (UI 설정 보존) |
| `/pvpster debug on` / `off` | 디버그 로그 채팅 출력 토글 |
| `/pvpster minimap` | 미니맵 버튼 토글 |
| `/pvpster scale [value]` | UI 스케일 설정. 인자 없으면 현재 값 출력 |
| `/pvpster lang` | 현재 설정 + 지원 locale 목록 출력 |
| `/pvpster lang [auto\|enUS\|koKR\|frFR\|deDE\|esES\|esMX\|ptBR\|ruRU\|zhCN\|zhTW]` | 언어 변경 (DB 저장 + `Localization:Apply` + `UI:RefreshLocalizedText`) |
| `/pvpster help` | 도움말 (지원 locale 목록은 동적으로 생성) |

> `lang` 인자는 대소문자 무시 후 `normalizeLocaleArg()`가 canonical 표기로 정규화 (`enus` → `enUS` 등). `Localization:GetSupportedLocales()`를 통해 도움말/help/에러 메시지의 locale 목록이 자동 도출되므로, 새 locale 추가 시 Slash.lua를 손댈 필요 없음.

### 메시지 출력

모든 사용자 응답은 채팅 프레임에 prefix `|cff5599ff[PvPster]|r ` 붙여서 출력.

### Localization 의존성

Slash 모듈은 다음 메서드를 사용:

- `PvPster.Localization:Apply(preference)` — 저장 후 즉시 적용
- `PvPster.Localization:Resolve(preference)` — 저장값에 대한 effective locale 조회 (current 출력용)
- `PvPster.Localization:IsSupported(localeKey)` — 입력 검증 (`auto` 포함)
- `PvPster.Localization:GetSupportedLocales()` — 도움말/에러 메시지의 locale 목록

자세한 API는 [Localization.md](./Localization.md).
