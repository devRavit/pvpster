# PvPster Addon - Development Guidelines

> **Claude 지시사항**: 이 파일의 모든 규칙을 준수할 것.

---

## Checkpoint: 작업 전 필수 읽기

> **⚠️ WoW API 사용 시 1순위 참조**: https://warcraft.wiki.gg/wiki/Secret_Values
> 본 애드온은 비전투 데이터 조회만 사용해 Secret Values 제약은 최소이지만,
> 새 API 추가 시 반드시 시크릿 태그 확인.

작업 시 **반드시** 해당 명세서를 먼저 읽을 것.

| 작업 대상 | 명세서 경로 |
|-----------|-------------|
| 전체 구조/개요 | `docs/spec/Overview.md` |
| Core / DB / Logger / Slash | `docs/spec/Core.md` |
| 데이터 수집 | `docs/spec/Collector.md` |
| UI | `docs/spec/UI.md` |

### 작업 흐름

1. **작업 시작 전**: 관련 명세서 Read 도구로 읽기
2. **구현 중**: 명세서의 구조/API 설계 따르기
3. **구현 완료 후**: 명세서 업데이트 (구현된 내용 반영)

---

## 코딩 컨벤션

> Oculus와 동일한 Roblox Lua 스타일 따름.
> 상세: `../oculus/docs/CODE_STYLE.md` 참조.

### 핵심 요약

| 대상 | 규칙 | 예시 |
|------|------|------|
| 모듈/클래스 | PascalCase | `Collector`, `UI` |
| 함수 | PascalCase | `Collector:RunFullSync()` |
| 지역 변수 | camelCase | `currentInfo`, `rowFrame` |
| 상수 | LOUD_SNAKE_CASE | `HONOR_CURRENCY_ID` |
| 비공개 멤버 | `_underscore` 접두사 | `_eventFrame` |

- 4 spaces 인덴트, 100 칼럼, 후행 쉼표
- 와일드카드 import 금지, 전역 API 로컬화
- 약어 사용 최소화 (`config` → `configuration`)
- 한 파일 300줄 초과 시 분리 검토

---

## Localization (i18n)

**모든 UI에 표시되는 문자열은 반드시 현지화 처리되어야 함**

- 하드코딩된 문자열 사용 금지
- `PvPster.L` 테이블을 통해 현지화된 문자열 사용
- 새로운 문자열 추가 시 `Localization.lua`에 enUS, koKR 모두 추가

### 사용 예시

```lua
-- Bad
button:SetText("Sync")

-- Good
button:SetText(L["Sync"])
```

---

## 로깅 규칙 (절대 준수)

**CRITICAL: print() 함수 사용 절대 금지**

- print() 직접 호출 금지 — 어떠한 상황에서도 사용 금지
- 모든 로그는 `Logger:Log(module, message)` 통해서만 출력
- 로그는 SavedVariables (`PvPsterLogs`)에 저장
- 디버그 모드일 때만 채팅 출력 (`Logger:Debug()`)
- 로그 포맷: `[YYYY-MM-DD HH:MM:SS] [Module] message`
- 최대 로그 수: 500개 (초과 시 오래된 로그부터 삭제)

### 로그 확인 경로 (Windows)

```
C:\Program Files (x86)\World of Warcraft\_retail_\WTF\Account\<accountID>\SavedVariables\PvPster.lua
```

`PvPsterLogs.entries` 배열 확인.

---

## 12.0.5 API 핵심 메모

### 화폐 ID (`Constants.lua`)

```lua
HONOR_CURRENCY_ID = 1792
ACCOUNT_WIDE_HONOR_CURRENCY_ID = 1585
CONQUEST_CURRENCY_ID = 1602
```

### 레이팅 브래킷 (`CONQUEST_BRACKET_INDEXES = { 7, 9, 1, 2, 4 }`)

| Index | 종목 |
|-------|------|
| 1 | 2v2 |
| 2 | 3v3 |
| 4 | RBG (deprecated) |
| 7 | Solo Shuffle |
| 9 | Rated BG Blitz |

### `GetPersonalRatedInfo(bracketIndex)` 반환 (15개)

```lua
rating, seasonBest, weeklyBest,
seasonPlayed, seasonWon,
weeklyPlayed, weeklyWon,
lastWeeksBest, hasWon, pvpTier, ranking,
roundsSeasonPlayed, roundsSeasonWon,
roundsWeeklyPlayed, roundsWeeklyWon
```

> **주의**: warcraft.wiki.gg의 페이지는 5.4 버전 기준이라 신뢰 ❌
> Gethe/wow-ui-source가 라이브 빌드 정답.

### 권장 이벤트

- `PLAYER_ENTERING_WORLD` 첫 진입 + `RequestRatedInfo()`
- `PVP_RATED_STATS_UPDATE`
- `CURRENCY_DISPLAY_UPDATE`
- `PLAYER_EQUIPMENT_CHANGED` (debounce 0.5초)
- `PLAYER_LOGOUT`

---

## 테스트 흐름

### 1. 심볼릭 링크 설치 (최초 1회)

PowerShell 관리자 권한으로:

```powershell
.\setup-junctions.ps1
```

### 2. 게임 내 테스트

- WoW 실행
- `/reload` 또는 클라이언트 재시작
- `/pvpster` 명령으로 창 열기
- 다른 캐릭터로 로그인 → 다시 `/pvpster` → 행 추가 확인

### 3. SavedVariables 검증

`PvPster.lua` 직접 열어 데이터 구조 확인:

```
C:\Program Files (x86)\World of Warcraft\_retail_\WTF\Account\<id>\SavedVariables\PvPster.lua
```

---

## 참고 자료

- [WoW 12.0.5 API 변경](https://warcraft.wiki.gg/wiki/Patch_12.0.0/API_changes)
- [Blizzard UI Source (Gethe)](https://github.com/Gethe/wow-ui-source)
- [Rated Stats](https://www.curseforge.com/wow/addons/rated-stats) — 비슷한 컨셉의 참고 애드온
