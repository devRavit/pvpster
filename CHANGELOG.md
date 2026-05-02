# Changelog

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
