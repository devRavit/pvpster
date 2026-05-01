# PvPster

> Account-wide PvP tracker for World of Warcraft Midnight (12.0.5)
> 계정 내 모든 캐릭터의 PvP 현황을 한눈에

PvPster는 한 계정에 여러 캐릭을 굴리는 PvP 유저를 위한 트래커 애드온입니다.
각 캐릭의 정복점수, 명예점수, 평균 아이템 레벨, 종목별 레이팅(2v2, 3v3, Solo Shuffle, Blitz)을
독립 창 하나에서 한눈에 확인할 수 있습니다.

## 주요 기능

- 계정 단위 캐릭터 데이터 자동 수집 (로그인 시)
- 정복/명예/계정 명예 점수 표시
- 4개 PvP 종목 레이팅 표시 (2v2, 3v3, Solo Shuffle, Blitz)
- 평균 아이템 레벨 + 슬롯별 장비 정보 저장
- 컬럼 정렬 가능한 테이블 뷰
- 드래그/토글 가능한 독립 창
- 한국어/영어 지원

## 설치

### 개발 빌드 (현재)

PowerShell:
```powershell
.\setup-junctions.ps1
```

WoW 클라이언트 재시작 또는 `/reload`.

### CurseForge

준비 중.

## 사용법

| 명령 | 동작 |
|------|------|
| `/pvpster` | 창 토글 |
| `/pvpster show` | 창 열기 |
| `/pvpster hide` | 창 닫기 |
| `/pvpster sync` | 현재 캐릭 강제 재수집 |
| `/pvpster reset` | DB 초기화 |
| `/pvpster help` | 도움말 |

## Recent Changes

자세한 변경 이력은 [CHANGELOG.md](./CHANGELOG.md) 참조.

## License

TBD
