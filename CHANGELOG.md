# Changelog

## v20260505.1
`2026.05.05 (KST)`

i18n 리팩터 + WoW 클라이언트 지원 locale 8종(frFR/deDE/esES/esMX/ptBR/ruRU/zhCN/zhTW) 추가.

- `Locales/` 디렉토리로 locale 데이터 분리 — `Localization.lua`는 `PvPster.LOCALE_REGISTRY` 기반 엔진만 담당, 새 locale 추가는 파일 1개 + `.toc` 한 줄로 완결
- per-key fallback 머지: 비-enUS locale에서 누락된 키는 enUS로 폴백 (이전엔 raw key 문자열 노출되던 버그)
- 슬래시 / 드롭다운의 지원 locale 리스트 자동 도출 (`Slash.lua`의 정적 `LOCALE_ALIASES`, 메시지 내 하드코딩 locale 리스트 제거)
- 인챈트 스탯 오버라이드 렌더 시점 처리 — `Constants.ENCHANT_STATS_BY_ID`를 enchant ID → L 키 매핑으로, locale 변경 시 재수집 없이 바로 반영. `rawget`으로 누락 키의 raw 노출 방지
- 인챈트 stat 번역은 ElvUI/RatingBuster 교차 검증된 Blizzard 공식 용어 기반 (deDE는 Wowhead spell 페이지 직접 확인)
- DB schema v2 + v1→v2 자동 wipe 마이그레이션: enchantName에 stat 오버라이드가 합쳐 저장된 v1 데이터를 wipe, UI 설정(창 위치/테마/scale/locale/미니맵)은 보존
- UI 정리: `"Lv "` → `L["Level"]`, 미니맵 `"ON/OFF"` → `L["StateOn/Off"]`, 언어 버튼 라벨에서 `L["Language"]` 프리픽스 제거(native name만 표시)
- 데드 코드 `Constants.SLOT_NAMES` 제거 (`SLOT_LABEL_KEYS`만 사용 중)
- **종족/직업명 현지화**: 캐릭터 툴팁 부제목의 race/class를 `classFile`/`raceFile`(로케일-무관 ID) 기반 `L["CLASS_*"]`/`L["RACE_*"]` 룩업으로 — 13 직업 + ~25 종족 × 10 locale 추가. 누락 시 클라이언트 locale 문자열로 폴백
- **보석 stat 텍스트 번역**: 캡처된 보석 툴팁 텍스트(`"특화 +16 / 가속 +7"` 등)에서 stat 키워드를 클라이언트 locale에서 활성 애드온 locale로 치환 — `Constants.STAT_KEYWORDS` 패턴 테이블(10 locale × 12 stat) + `Localization:GetCurrent()` 추가

---

## v20260502.3
`2026.05.02 (KST)`

언어 설정 기능 추가.

- `Localization` 모듈 신규 — `Apply(preference)` API, L 테이블 in-place 갱신으로 다른 모듈의 `local L = PvPster.L` 참조 유지
- DB `ui.locale` 추가, default `"auto"` (저장값 없거나 `"auto"`면 `GetLocale()` 따라감)
- 클라이언트 locale이 enUS/koKR 외(예: deDE, zhCN)면 enUS로 fallback
- `/pvpster lang [auto|enUS|koKR]` 슬래시 명령
- 메인 UI 타이틀 바 미니맵 버튼 옆에 select 형태 언어 드롭다운 — 저장값 없으면 클라이언트 locale에 해당하는 옵션이 체크된 상태로 표시
- 언어 변경 시 정적으로 박힌 라벨(Sync/Reset/empty/리셋 다이얼로그)도 hot-swap (별도 `/reload` 불필요)
- fix: 부캐 정복점수 cap 도달 색상 — 헤더/툴팁과 동일하게 현재 캐릭터의 maxQuantity를 공유 cap으로 사용해, 접속 안 한 부캐도 totalEarned가 이번 주 한도에 도달하면 파란색으로 표시

---

## v20260502.2
`2026.05.02 (KST)`

CurseForge 첫 자동 배포 (end-to-end 검증).

- README: CurseForge 설치 안내 + 배지 추가, "준비 중" 문구 제거
- 호환 표기: `12.0.5` → `12.0.5+`

---

## v0.0.1
`2026.05.01 (KST)`

초기 프로젝트 셋업 및 명세 작성.

- 프로젝트 구조 생성 (PvPster 단일 애드온, 8개 Lua 파일 분리)
- 명세서 작성: Overview, Core, Collector, UI
- 12.0.5 API 검증 (화폐 ID, 브래킷 인덱스, GetPersonalRatedInfo 15필드 반환)
- setup-junctions.ps1 (Windows 심볼릭 링크 설치 스크립트)
- CLAUDE.md (개발 가이드라인)
- BigWigs Packager 빌드 셋업 (`.pkgmeta`, TOC `Version` 토큰화, 영문 Notes 정리)
- 리포 구조 평탄화: `PvPster/*` 파일들을 리포 루트로 이동 (BigWigs Packager 표준 단일 모듈 구조 준수). `setup-junctions.ps1`은 리포 루트 자체를 `WoW\AddOns\PvPster`로 symlink 하도록 수정.
- TOC에 `## X-Curse-Project-ID: 1530687` 추가 (CurseForge 프로젝트 https://www.curseforge.com/wow/addons/pvpster 등록 완료)

---
