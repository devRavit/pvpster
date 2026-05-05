# PvPster

[![CurseForge](https://img.shields.io/badge/CurseForge-PvPster-F16436?logo=curseforge&logoColor=white)](https://www.curseforge.com/wow/addons/pvpster)
[![WoW](https://img.shields.io/badge/WoW-12.0.5%2B-blue)](https://warcraft.wiki.gg/wiki/Patch_12.0.0)
[![Locales](https://img.shields.io/badge/locales-10-green)](#localization)

> Account-wide PvP tracker for World of Warcraft Midnight (12.0.5+)
> 계정 내 모든 캐릭터의 PvP 현황을 한눈에 — 한국어 안내는 [아래로](#한국어).

---

## English

PvPster is an account-level PvP tracker for players who run multiple characters. It shows each character's **Conquest / Honor points, average item level, and per-bracket ratings (2v2, 3v3, Solo Shuffle, Rated BG Blitz)** in a single standalone window — no need to log into each alt to compare.

### Features

- **Account-wide auto collection** — data is captured from each character on login and persists across sessions via SavedVariables
- **Currency tracking** — Conquest, Honor, and account-wide Honor; weekly Conquest cap is colored when reached, even for alts that haven't logged in this week
- **Per-bracket ratings** — 2v2, 3v3, Solo Shuffle, and Rated BG Blitz, with separate match / round counts where applicable
- **Equipment view** — average item level plus per-slot item link, quality, and item level; gem and enchant stats are shown in tooltips
- **Sortable column table** — click any column header to sort
- **Standalone window** — drag, resize, toggle, and remember position; not tied to any Blizzard panel
- **Minimap button** — quick toggle from the minimap
- **10 locales** — English, 한국어, Français, Deutsch, Español (ES/MX), Português (BR), Русский, 简体中文, 繁體中文 — switchable in-game without `/reload`
- **Race/class names localized** via locale-independent IDs (`classFile` / `raceFile`); gem and enchant stat keywords are translated from the client locale to the active addon locale
- **Lightweight** — event-driven only; no polling

### Installation

#### CurseForge (recommended)

Search **PvPster** in the [CurseForge App](https://www.curseforge.com/download/app), or grab it directly from the [project page](https://www.curseforge.com/wow/addons/pvpster). WowUp, WoWInterface, and other CurseForge mirrors all work.

#### Development build

Clone the repo, then run from PowerShell (administrator privileges required for symbolic links):

```powershell
.\setup-junctions.ps1
```

This junctions the repo root into `World of Warcraft\_retail_\Interface\AddOns\PvPster`. Restart WoW or `/reload`.

### Usage

| Command | Action |
|---------|--------|
| `/pvpster` | Toggle the main window |
| `/pvpster show` / `hide` | Open / close the window explicitly |
| `/pvpster sync` | Force-resync the current character |
| `/pvpster reset confirm` | Reset the database (requires `confirm` to actually wipe) |
| `/pvpster debug on` / `off` | Toggle debug log output to chat |
| `/pvpster minimap` | Toggle the minimap button |
| `/pvpster scale <value>` | Set UI scale (e.g. `0.9`, `1.0`, `1.2`); no arg prints the current value |
| `/pvpster lang [auto\|enUS\|koKR\|frFR\|deDE\|esES\|esMX\|ptBR\|ruRU\|zhCN\|zhTW]` | Switch language; `auto` follows the WoW client locale |
| `/pvpster help` | Show the command list |

`/pvps` is a shorter alias for `/pvpster`.

### Localization

PvPster ships full strings for **10 locales**: `enUS`, `koKR`, `frFR`, `deDE`, `esES`, `esMX`, `ptBR`, `ruRU`, `zhCN`, `zhTW`. Missing keys in any non-English locale fall back to `enUS` per-key. Language can be changed live (no `/reload`) via the title-bar dropdown or `/pvpster lang`.

Adding a new locale only requires a single `Locales/<code>.lua` file plus one line in `PvPster.toc` — the engine in `Localization.lua` discovers it automatically.

### Project structure

```
pvpster/
├── PvPster.toc
├── Locales/
│   ├── enUS.lua  koKR.lua  frFR.lua  deDE.lua
│   ├── esES.lua  esMX.lua  ptBR.lua  ruRU.lua
│   └── zhCN.lua  zhTW.lua
├── Localization.lua    # i18n engine (Apply, Resolve, GetSupportedLocales)
├── Constants.lua       # currency IDs, bracket indexes, slot/stat tables
├── Logger.lua          # SavedVariables-backed logging (PvPsterLogs)
├── DB.lua              # PvPsterDB I/O + schema migration
├── Theme.lua           # color / style tokens
├── Collector.lua       # currency / rating / equipment collection
├── UI.lua              # main window, sortable table, language dropdown
├── Minimap.lua         # minimap button
├── Slash.lua           # /pvpster, /pvps
├── Core.lua            # entry point, event dispatch
├── docs/spec/          # design specs (Overview, Core, Collector, UI)
├── setup-junctions.ps1 # Windows dev install script
├── CHANGELOG.md        # full history
└── RELEASE_NOTES.md    # CurseForge user-facing changelog (current release only)
```

### Saved data

| Variable | Purpose |
|----------|---------|
| `PvPsterDB` | Per-character data (currency, ratings, equipment), UI state (window position, theme, scale, locale, minimap), schema version |
| `PvPsterLogs` | Log entries (`entries`, capped at 500) and debug flag (`debugEnabled`) |

Located at:
```
World of Warcraft/_retail_/WTF/Account/<accountID>/SavedVariables/PvPster.lua
```

### Recent changes

See [CHANGELOG.md](./CHANGELOG.md) for the full history. The current release notes for CurseForge live in [RELEASE_NOTES.md](./RELEASE_NOTES.md).

### License

All Rights Reserved.

---

## 한국어

PvPster는 한 계정에 여러 캐릭을 굴리는 PvP 유저를 위한 트래커 애드온입니다. 각 캐릭터의 **정복/명예 점수, 평균 아이템 레벨, 종목별 레이팅(2v2, 3v3, Solo Shuffle, Rated BG Blitz)** 을 독립 창 하나에서 한눈에 비교할 수 있습니다 — 부캐로 일일이 로그인할 필요 없이.

### 주요 기능

- **계정 단위 자동 수집** — 캐릭터 로그인 시 데이터 캡처, SavedVariables로 영구 저장
- **화폐 트래킹** — 정복, 명예, 계정 공유 명예. 정복점수 주간 cap 도달 시 색상 표시 (이번 주 미접속 부캐도 동일 cap 기준 적용)
- **종목별 레이팅** — 2v2, 3v3, Solo Shuffle, Rated BG Blitz. 매치 수와 라운드 수가 다른 종목은 적절한 값을 노출
- **장비 정보** — 평균 아이템 레벨 + 슬롯별 링크/품질/ilvl. 보석/인챈트 스탯 툴팁 표시
- **컬럼 정렬** — 모든 컬럼 헤더 클릭으로 정렬
- **독립 창** — 드래그/리사이즈/토글/위치 기억. Blizzard 패널과 무관
- **미니맵 버튼** — 미니맵에서 빠른 토글
- **10개 locale** — English, 한국어, Français, Deutsch, Español (ES/MX), Português (BR), Русский, 简体中文, 繁體中文 — 게임 내에서 `/reload` 없이 전환
- **종족/직업명 현지화** — 로케일-무관 ID(`classFile`/`raceFile`) 기반. 보석/인챈트 스탯 키워드도 클라이언트 locale에서 활성 애드온 locale로 치환
- **가벼움** — 이벤트 기반, 폴링 없음

### 설치

#### CurseForge (권장)

[CurseForge App](https://www.curseforge.com/download/app)에서 **PvPster** 검색 또는 [프로젝트 페이지](https://www.curseforge.com/wow/addons/pvpster)에서 직접 다운로드. WowUp, WoWInterface 등 CurseForge 미러도 모두 지원.

#### 개발 빌드

리포 클론 후 PowerShell **관리자 권한**으로:

```powershell
.\setup-junctions.ps1
```

리포 루트를 `World of Warcraft\_retail_\Interface\AddOns\PvPster`로 junction합니다. WoW 재시작 또는 `/reload`.

### 사용법

| 명령 | 동작 |
|------|------|
| `/pvpster` | 메인 창 토글 |
| `/pvpster show` / `hide` | 창 명시적 열기/닫기 |
| `/pvpster sync` | 현재 캐릭터 강제 재수집 |
| `/pvpster reset confirm` | DB 초기화 (`confirm` 인자 필수 — 안전장치) |
| `/pvpster debug on` / `off` | 디버그 로그 채팅 출력 토글 |
| `/pvpster minimap` | 미니맵 버튼 토글 |
| `/pvpster scale <값>` | UI 스케일 설정 (예: `0.9`, `1.0`, `1.2`). 인자 없으면 현재 값 표시 |
| `/pvpster lang [auto\|enUS\|koKR\|frFR\|deDE\|esES\|esMX\|ptBR\|ruRU\|zhCN\|zhTW]` | 언어 변경. `auto`는 WoW 클라이언트 locale 따라감 |
| `/pvpster help` | 명령어 목록 표시 |

`/pvps`는 `/pvpster`의 짧은 별칭.

### 다국어 지원

10개 locale의 전체 문자열을 동봉: `enUS`, `koKR`, `frFR`, `deDE`, `esES`, `esMX`, `ptBR`, `ruRU`, `zhCN`, `zhTW`. 비영어 locale에서 키가 누락되면 per-key로 `enUS`로 폴백. 언어 변경은 타이틀바 드롭다운 또는 `/pvpster lang`으로 즉시 적용 (`/reload` 불필요).

새 locale 추가는 `Locales/<code>.lua` 파일 1개와 `PvPster.toc` 한 줄 추가만 필요 — `Localization.lua` 엔진이 자동 인식.

### 프로젝트 구조

위 영문 섹션의 트리 참조.

### 저장 데이터

| 변수 | 용도 |
|------|------|
| `PvPsterDB` | 캐릭터별 데이터(화폐/레이팅/장비), UI 상태(창 위치/테마/스케일/locale/미니맵), 스키마 버전 |
| `PvPsterLogs` | 로그 엔트리(`entries`, 500개 cap), 디버그 플래그(`debugEnabled`) |

위치:
```
World of Warcraft/_retail_/WTF/Account/<계정ID>/SavedVariables/PvPster.lua
```

### 최근 변경

전체 이력은 [CHANGELOG.md](./CHANGELOG.md). CurseForge용 현재 릴리즈 노트는 [RELEASE_NOTES.md](./RELEASE_NOTES.md).

### 라이선스

All Rights Reserved.
