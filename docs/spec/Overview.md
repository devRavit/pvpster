# PvPster - Overview

> "PvP" + "Roster" 합성어 — 계정 내 모든 캐릭터의 PvP 현황을 한눈에 보는 애드온

## 개요

PvPster는 World of Warcraft Midnight (12.0.5) 환경에서 **계정 단위 PvP 트래커** 역할을 한다.
한 계정에 여러 캐릭터를 굴리는 PvP 유저가 각 캐릭의 정복/명예 점수, 장비 수준, 종목별 레이팅을
독립 창 하나에서 한눈에 확인할 수 있게 한다.

## 목표

- **저비용 운영**: 폴링 없이 이벤트 기반으로만 데이터 갱신
- **계정 공유 저장**: 캐릭터마다 한 번 로그인하면 다른 캐릭으로 바꿔도 마지막 데이터 표시
- **독자 UI**: Blizzard 패널에 의존하지 않는 별도 창 (드래그/리사이즈/토글 가능)
- **12.0.5 API 정합**: 현행 라이브 빌드 함수 시그니처 사용

## 비목표 (Out of Scope, v1)

- Battle.net API 연동 — 인게임 SavedVariables만으로 동작
- 길드원/공격대원 PvP 정보 — 본인 계정 캐릭만
- 실시간 매치 트래킹/스코어보드 — 별도 애드온(Rated Stats 등) 영역
- PvP 능력치 상세 분석(저항/전투력) — 평균 ilvl까지만

## 모듈 구성

PvPster는 단일 애드온이며 내부에서 책임 단위로 파일을 분리한다.

| 파일 | 역할 |
|------|------|
| `Core.lua` | 진입점, 이벤트 등록/디스패치, 다른 모듈 초기화 |
| `Constants.lua` | 화폐 ID, 브래킷 인덱스, 슬롯 ID 등 상수 |
| `Localization.lua` | enUS + koKR 문자열 |
| `Logger.lua` | SavedVariables 기반 로그 |
| `DB.lua` | SavedVariables 읽기/쓰기, 마이그레이션 |
| `Collector.lua` | 현재 캐릭의 화폐/레이팅/장비 데이터 수집 |
| `UI.lua` | 메인 창, 캐릭터 목록 테이블, 컬럼 정렬 |
| `Slash.lua` | `/pvpster`, `/pvps` 명령 |

## 프로젝트 구조

```
pvpster/
├── docs/
│   └── spec/
│       ├── Overview.md      (이 문서)
│       ├── Core.md          DB, 이벤트, 슬래시
│       ├── Collector.md     데이터 수집 명세
│       └── UI.md            창 레이아웃, 컬럼
├── PvPster/
│   ├── PvPster.toc
│   ├── Localization.lua
│   ├── Constants.lua
│   ├── Logger.lua
│   ├── DB.lua
│   ├── Core.lua
│   ├── Collector.lua
│   ├── UI.lua
│   └── Slash.lua
├── README.md
├── CHANGELOG.md
├── CLAUDE.md
├── .gitignore
└── setup-junctions.ps1
```

## 12.0.5 API 사용 요약

### 화폐 (Currency)

```lua
local info = C_CurrencyInfo.GetCurrencyInfo(currencyID)
-- info.quantity, info.totalEarned, info.maxQuantity, info.useTotalEarnedForMaxQty
```

| 화폐 | ID 상수 | 값 |
|------|---------|-----|
| 명예 | `HONOR_CURRENCY_ID` | 1792 |
| 계정 공유 명예 | `ACCOUNT_WIDE_HONOR_CURRENCY_ID` | 1585 |
| 정복 | `CONQUEST_CURRENCY_ID` | 1602 |

### 레이팅 (Personal Rated Info)

```lua
local rating, seasonBest, weeklyBest,
      seasonPlayed, seasonWon,
      weeklyPlayed, weeklyWon,
      lastWeeksBest, hasWon, pvpTier, ranking,
      roundsSeasonPlayed, roundsSeasonWon,
      roundsWeeklyPlayed, roundsWeeklyWon
    = GetPersonalRatedInfo(bracketIndex)
```

`CONQUEST_BRACKET_INDEXES = { 7, 9, 1, 2, 4 }` 순서:

| Index | 종목 |
|-------|------|
| 1 | 2v2 Arena |
| 2 | 3v3 Arena |
| 4 | Rated Battleground (구 RBG) |
| 7 | Solo Shuffle |
| 9 | Rated BG Blitz |

> **중요**: Solo Shuffle / Blitz는 한 매치가 여러 라운드로 구성되어,
> `weeklyPlayed`(매치 수)와 `roundsWeeklyPlayed`(라운드 수)가 다르다.
> UI에서 종목별로 적절한 값을 노출한다.

### 장비

```lua
local overall, equipped, pvp = GetAverageItemLevel()
local link = GetInventoryItemLink("player", slotID)
local quality = GetInventoryItemQuality("player", slotID)
local itemLevel = C_Item.GetCurrentItemLevel(ItemLocation:CreateFromEquipmentSlot(slotID))
```

ilvl 기여 슬롯 IDs: 1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17 (셔츠/문장 제외)

### 캐릭터 식별

```lua
local name = UnitName("player")
local _, classFile = UnitClass("player")          -- "WARRIOR" 등 영문 토큰
local _, raceFile = UnitRace("player")
local faction = UnitFactionGroup("player")        -- "Alliance" / "Horde"
local level = UnitLevel("player")
local realm = GetNormalizedRealmName()            -- "Azshara" 등 (공백/따옴표 제거된 형태)
```

DB 키 형식: `realm-name` (예: `"Azshara-Ravit"`)

## 갱신 트리거

| 이벤트 | 갱신 대상 |
|--------|----------|
| `PLAYER_ENTERING_WORLD` | 전체 (첫 진입 시 한 번) |
| `PVP_RATED_STATS_UPDATE` | 레이팅 |
| `CURRENCY_DISPLAY_UPDATE` | 화폐 |
| `PLAYER_EQUIPMENT_CHANGED` | 장비 |
| `PLAYER_LEVEL_UP` | 캐릭터 레벨 |
| `PLAYER_LOGOUT` | 마지막 저장 보장 |

`RequestRatedInfo()`를 첫 진입 시 호출해 레이팅 캐시 워밍.

## Secret Values 영향도

본 애드온이 사용하는 API는 **모두 비전투 데이터 조회**라서 Secret Values 제약은 사실상 없다.

- 화폐 (`C_CurrencyInfo.GetCurrencyInfo`): 시크릿 태그 없음
- 레이팅 (`GetPersonalRatedInfo`): 시크릿 태그 없음
- 장비 (`GetInventoryItemLink`, `GetAverageItemLevel`): 시크릿 태그 없음

또한 본 애드온은 **Blizzard Protected 프레임을 수정하지 않으므로** Combat Lockdown도 무관하다.
순수 사용자 정의 프레임만 사용한다.

## 코딩 컨벤션

> 상세 규칙은 [`../../oculus/docs/CODE_STYLE.md`](../../oculus/docs/CODE_STYLE.md) 참조 (oculus와 동일 적용).

### 핵심 요약

| 대상 | 규칙 |
|------|------|
| 모듈/클래스 | PascalCase (`Collector`, `UI`) |
| 함수 | PascalCase (`Collector:Run()`, `UpdateCharacterRow()`) |
| 지역 변수 | camelCase (`currentInfo`, `rowFrame`) |
| 상수 | LOUD_SNAKE_CASE (`HONOR_CURRENCY_ID`) |
| 비공개 멤버 | `_underscore` 접두사 |

- 4 spaces 인덴트, 100 칼럼, 후행 쉼표
- 와일드카드 import 금지, 전역 API 로컬화
- print() 직접 호출 금지 — `Logger:Log()` 사용

## 참고 자료

- [WoW 12.0 API 변경사항](https://warcraft.wiki.gg/wiki/Patch_12.0.0/API_changes)
- [Blizzard UI Source (Gethe mirror)](https://github.com/Gethe/wow-ui-source)
- [Rated Stats addon](https://www.curseforge.com/wow/addons/rated-stats) — 참고용
