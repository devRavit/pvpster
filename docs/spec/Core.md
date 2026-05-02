# PvPster - Core 명세

> Core, DB, Logger, Slash 책임 정의

---

## Core 모듈

### 책임

- 애드온 진입점 (`ADDON_LOADED` 핸들링)
- 전역 namespace `PvPster` 노출
- 다른 모듈(Collector, UI, Slash, DB, Logger) 초기화 순서 제어
- 이벤트 프레임 한 개 보유 후 모든 이벤트 멀티플렉싱

### 전역 Namespace

```lua
_G.PvPster = {
    L = {},              -- Localization 문자열 테이블 (mutate-in-place)
    Localization = {},   -- Localization 모듈 (Apply / Resolve / GetClientLocale)
    DB = {},             -- DB 모듈
    Collector = {},      -- 데이터 수집
    UI = {},             -- UI 창
    Logger = {},         -- 로그
    Constants = {},      -- 상수
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

PLAYER_ENTERING_WORLD (첫 진입)
    └─ Collector:RunFullSync()      -- 전체 데이터 갱신
```

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
- `PvPsterLogs` — 디버그 로그 (계정 공유, 옵션)

### 스키마

```lua
PvPsterDB = {
    version = 1,                       -- 마이그레이션용
    characters = {
        ["Azshara-Ravit"] = {
            -- 식별 정보
            name = "Ravit",
            realm = "Azshara",
            classFile = "WARRIOR",
            classLocalized = "전사",
            raceFile = "Human",
            faction = "Alliance",       -- "Alliance" / "Horde"
            level = 80,
            gender = 2,                 -- 2=남, 3=여
            lastSeen = 1714539600,      -- Unix timestamp

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
                [1] = {                  -- 2v2
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
                [2] = { ... },           -- 3v3
                [7] = { ... },           -- Solo Shuffle (rounds 필드 있음)
                [9] = { ... },           -- Blitz (rounds 필드 있음)
            },

            -- 장비
            equipment = {
                averageItemLevel = 642.5,
                averageItemLevelEquipped = 640.0,
                averageItemLevelPvP = 645.0,
                slots = {
                    [1] = {              -- Head
                        itemLink = "|cffa335ee|Hitem:...|h[Item Name]|h|r",
                        itemLevel = 642,
                        quality = 4,
                    },
                    -- ...
                },
            },
        },
    },
    ui = {
        position = { point = "CENTER", x = 0, y = 0 },
        size = { width = 920, height = 420 },
        sortColumn = "name",             -- 정렬 컬럼 키
        sortDirection = "asc",           -- "asc" / "desc"
        visible = false,
        minimapVisible = true,
        minimapAngle = 225,
        uiScale = 1.0,
        theme = "github",
        locale = "auto",                 -- "auto" | "enUS" | "koKR" — auto는 GetLocale() 따라감
    },
}
```

### 주요 함수

```lua
function DB:Initialize()
    -- PvPsterDB 없으면 생성 + 버전 마이그레이션
end

function DB:GetCharacterKey()
    -- "{realm}-{name}" 반환 (현재 캐릭터)
end

function DB:GetCharacter(key)
    -- 키 없으면 빈 테이블 반환
end

function DB:UpsertCharacter(key, data)
    -- 부분 업데이트 (기존 필드 보존)
end

function DB:GetAllCharacters()
    -- {key: data} 전체 반환
end

function DB:RemoveCharacter(key)
    -- 캐릭터 삭제
end

function DB:Reset()
    -- 전체 초기화
end
```

### 마이그레이션 정책

`PvPsterDB.version`이 코드 상수 `DB_VERSION`보다 낮으면 단계별 마이그레이션 함수 호출.
v1 단계에서는 단순 초기화만. v2부터 `MigrateV1ToV2()` 같은 함수 추가.

---

## Logger 모듈

### 책임

- print() 직접 호출 금지 (CLAUDE.md 규칙)
- 로그를 SavedVariables(`PvPsterLogs`)에 누적
- 디버그 모드에서만 채팅 출력
- 최대 500개 항목 (초과 시 오래된 것 삭제)

### 인터페이스

```lua
function Logger:Log(module, message)
    -- "[YYYY-MM-DD HH:MM:SS] [Module] message"
end

function Logger:Debug(module, message)
    -- 디버그 모드일 때만 출력
end

function Logger:SetDebug(enabled)
    -- 디버그 토글
end

function Logger:Clear()
    -- 로그 초기화
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

### 서브커맨드

| 커맨드 | 동작 |
|--------|------|
| `/pvpster` | 창 토글 (열림/닫힘) |
| `/pvpster show` | 창 열기 |
| `/pvpster hide` | 창 닫기 |
| `/pvpster sync` | 현재 캐릭 강제 재수집 |
| `/pvpster reset` | DB 전체 초기화 (확인 프롬프트) |
| `/pvpster remove <character>` | 특정 캐릭터 삭제 |
| `/pvpster debug on/off` | 디버그 로그 토글 |
| `/pvpster lang [auto\|enUS\|koKR]` | 언어 설정 조회/변경 (no-arg = 현재 설정 + 지원 목록 출력) |
| `/pvpster help` | 도움말 |

### Localization 모듈

```lua
PvPster.Localization:Apply(preference)        -- L 테이블 in-place 갱신, effective locale 반환
PvPster.Localization:Resolve(preference)      -- 적용 없이 effective locale 만 계산
PvPster.Localization:GetClientLocale()        -- GetLocale() 결과를 지원 locale 로 정규화
PvPster.Localization:GetSupportedLocales()    -- {{ key, nativeName }, ...} 표시 순서대로
PvPster.Localization:GetNativeName(localeKey) -- 옵션 라벨용 native 이름
PvPster.Localization:IsSupported(localeKey)   -- "auto" 도 true
```

**Resolution 우선순위**
1. 사용자 저장값 (`ui.locale`) 이 지원되는 locale 키면 그대로 사용
2. 저장값이 nil 또는 `"auto"` 이면 `GetLocale()` 결과
3. 위 두 단계로 얻은 값이 미지원 locale (예: deDE, zhCN) 이면 enUS fallback

**핵심 규칙**: L 테이블은 절대 교체하지 않고 mutate-in-place. 다른 모듈이 파일 로드 시점에 `local L = PvPster.L` 로 reference 캡처해두기 때문.

### 메시지 출력

모든 사용자 응답은 채팅 프레임에 prefix `|cff5599ff[PvPster]|r ` 붙여서 출력.
