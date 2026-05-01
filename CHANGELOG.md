# Changelog

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
