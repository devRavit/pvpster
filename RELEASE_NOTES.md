# PvPster

이 파일은 CurseForge 페이지에 표시될 **현재 릴리즈의 user-facing 변경사항**입니다.
릴리즈마다 이 파일 내용을 갱신하세요. 전체 히스토리는 [CHANGELOG.md](CHANGELOG.md) 참조.

---

## 장비 툴팁 개선

- **보석 stat 표시 정상화** — 이전엔 `자수정` 같은 보석 분류 라인이 표시되던 문제 해결, 이제 `+가속 / +특화` 등 실제 능력치 노출
- **마법부여 stat 매핑 추가** — Midnight 인쳔트 6종(반지/어깨/머리/가슴/발/무기) ID 기반 매핑으로 stat 타입 표시
- **PvP iLvl 슬롯별 표시** — 한국어/영어/기타 클라이언트 자동 지원 (locale-independent prefix 매칭)
- **인지의 머위 등 multi-line 보석** — `\n` 임베드된 라인을 한 줄로 정규화

## UI 개선

- **미니맵 버튼 위치 보존** — `/reload` 후 위치 초기화되던 문제 수정
- **정복 점수 색상 구분** — 캡 도달 시 파랑, 미달 시 빨강
- **데이터 Reset이 UI 환경설정 보존** — 창 위치/스케일/테마/정렬 상태 유지

## CI/내부

- main 푸시 시 release 태그 자동 생성
- CurseForge changelog가 user-facing 마크다운으로 노출되도록 빌드 설정 변경
