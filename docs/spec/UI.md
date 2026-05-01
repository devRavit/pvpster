# PvPster - UI 명세

> 독자적인 메인 창 — Blizzard 패널/탭 통합 없이 별도 프레임으로 동작

---

## 디자인 원칙

- **자체 창**: `UIParent`에 부착된 독립 프레임. Blizzard 인터페이스 옵션이나
  `PVEFrame` 등에 통합하지 않는다.
- **드래그 가능**: 사용자가 위치 조정 후 자동 저장
- **닫힘 가능**: ESC로 닫히고, `/pvpster`로 토글
- **숨김 시 무비용**: `visible=false`이면 데이터 갱신 시 UI Refresh 스킵
- **테이블 형식**: 캐릭터를 행으로, 정보를 컬럼으로 표시 (스프레드시트 느낌)

## 프레임 계층

```
PvPsterMainFrame (Frame, BackdropTemplate)
├── TitleBar (Frame)
│   ├── TitleText (FontString)
│   ├── CloseButton (Button)
│   └── (드래그 핸들로 사용)
├── HeaderRow (Frame)
│   └── ColumnHeader[] (Button) — 클릭 시 정렬
├── ScrollFrame (ScrollFrame)
│   └── ScrollChild (Frame)
│       └── CharacterRow[] (Frame)  — 캐릭터당 1행
│           ├── NameText (클래스 색)
│           ├── RealmText
│           ├── ItemLevelText
│           ├── HonorText
│           ├── ConquestText
│           ├── Bracket2v2Text
│           ├── Bracket3v3Text
│           ├── BracketShuffleText
│           ├── BracketBlitzText
│           └── LastSeenText
└── FooterBar (Frame)
    ├── SyncStatusText  ("마지막 갱신: 2분 전")
    └── HelpText        ("/pvpster help")
```

## 컬럼 정의

| 컬럼 키 | 헤더 라벨 | 너비 | 정렬 가능 | 표시 형식 |
|---------|----------|------|-----------|-----------|
| `name` | 이름 | 130 | ✅ | 클래스 색 텍스트 |
| `realm` | 서버 | 90 | ✅ | 회색 텍스트 |
| `level` | Lv | 30 | ✅ | 숫자 |
| `itemLevel` | iLvl | 50 | ✅ | `642` (정수, 반올림) |
| `honor` | 명예 | 90 | ✅ | `1500/15000` |
| `conquest` | 정복 | 90 | ✅ | `825/1350` (totalEarned/cap) |
| `bracket_1` | 2v2 | 70 | ✅ | `1850` (없으면 `-`) |
| `bracket_2` | 3v3 | 70 | ✅ | `1850` |
| `bracket_7` | Shuffle | 80 | ✅ | `1850` |
| `bracket_9` | Blitz | 70 | ✅ | `1850` |
| `lastSeen` | 갱신 | 80 | ✅ | `2시간 전` |

총 너비: 약 880 (+ 패딩) → 기본 창 너비 920.

## 정렬

- 컬럼 헤더 클릭 → 해당 컬럼 기준 정렬
- 같은 컬럼 재클릭 → 방향 토글 (asc ↔ desc)
- 정렬 상태 (`sortColumn`, `sortDirection`)는 DB의 `ui` 섹션에 저장 → 다음 세션 유지
- 헤더에 정렬 표시 (▲/▼)

기본값: `name asc`

## 색상

### 클래스 색

`RAID_CLASS_COLORS[classFile]` 사용. 12.0에서도 유지되는 전역.

```lua
local color = RAID_CLASS_COLORS[character.classFile] or { r=1, g=1, b=1 }
nameText:SetTextColor(color.r, color.g, color.b)
```

### 진영 표시

서버명 옆에 작은 아이콘 (선택, v1.1):
- Alliance: `Interface\\Icons\\Inv_BannersAlliance_A_01`
- Horde: `Interface\\Icons\\Inv_BannersHorde_C_01`

v1 단계에서는 진영 표시 생략. 서버명만 표시.

### 레이팅 색상 (티어 기반)

```lua
TIER_COLORS = {
    [0] = { r=0.7, g=0.7, b=0.7 },    -- Unranked (회색)
    [1] = { r=0.6, g=0.4, b=0.2 },    -- Combatant
    [2] = { r=0.7, g=0.7, b=0.7 },    -- Challenger
    [3] = { r=1.0, g=0.85, b=0.0 },   -- Rival
    [4] = { r=0.6, g=0.8, b=1.0 },    -- Duelist
    [5] = { r=1.0, g=0.5, b=1.0 },    -- Elite
    [6] = { r=1.0, g=0.0, b=0.5 },    -- Gladiator
    [7] = { r=1.0, g=0.0, b=0.0 },    -- R1
}
```

`pvpTier` 값으로 매핑. 정확한 티어 상수는 `C_PvP.GetPvpTierInfo()` 참조 (v1.1에서 정밀화).

## 행 (CharacterRow)

```lua
function CreateCharacterRow(parent, characterData)
    local row = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    row:SetHeight(22)

    -- 마우스오버 하이라이트
    row:SetScript("OnEnter", function() row.bg:Show() end)
    row:SetScript("OnLeave", function() row.bg:Hide() end)

    -- 클릭 동작 v2 예정 (캐릭터 상세 패널 등)
    return row
end
```

행 높이 22px, 패딩 2px. 한 캐릭터당 1행.

## 빈 상태

캐릭터 데이터가 0개일 때:

```
PvPster

  아직 수집된 캐릭터 데이터가 없습니다.

  각 캐릭터로 한 번씩 로그인해주세요.

```

가운데 정렬, 회색 텍스트.

## 토글 동작

```lua
function UI:Toggle()
    if PvPsterMainFrame:IsShown() then
        UI:Hide()
    else
        UI:Show()
    end
end

function UI:Show()
    PvPsterMainFrame:Show()
    PvPsterDB.ui.visible = true
    UI:Refresh()  -- 표시 직전에만 데이터 갱신
end

function UI:Hide()
    PvPsterMainFrame:Hide()
    PvPsterDB.ui.visible = false
end

function UI:Refresh()
    if not PvPsterMainFrame:IsShown() then return end  -- 숨김 시 스킵
    -- 정렬 → 행 재배치 → 컬럼 텍스트 업데이트
end
```

## 위치 저장

```lua
PvPsterMainFrame:SetMovable(true)
PvPsterMainFrame:SetClampedToScreen(true)
PvPsterMainFrame:RegisterForDrag("LeftButton")
PvPsterMainFrame:SetScript("OnDragStart", PvPsterMainFrame.StartMoving)
PvPsterMainFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, _, x, y = self:GetPoint()
    PvPsterDB.ui.position = { point = point, x = x, y = y }
end)
```

## 리사이즈 (v1.1 예정)

v1에서는 고정 크기 (920x420). 리사이즈는 컬럼 너비 재배분 로직이 필요해 v1.1로 미룸.

## ESC 닫기

```lua
table.insert(UISpecialFrames, "PvPsterMainFrame")
```

UISpecialFrames에 등록하면 ESC 키로 자동 닫힘.

## Refresh 흐름

```
UI:Refresh()
  └─ 1. DB에서 모든 캐릭터 조회
  └─ 2. sortColumn/Direction에 따라 정렬
  └─ 3. 행 풀에서 N개 행 가져오기 (부족하면 새로 생성)
  └─ 4. 각 행에 데이터 할당
  └─ 5. 사용 안 하는 행 숨김
  └─ 6. ScrollChild 높이 = N * 22
  └─ 7. 푸터의 "마지막 갱신" 텍스트 업데이트
```

행 풀 사용 — 매번 CreateFrame 하지 않고 재활용.

## 푸터의 시간 표시

`PvPsterDB.characters[현재캐릭].lastSeen`을 기준으로 "방금 전" / "{N}분 전" / "{N}시간 전" /
"{N}일 전" 표시. 1분마다 자동 갱신 (창이 보일 때만 ticker).
