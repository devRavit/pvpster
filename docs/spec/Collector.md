# PvPster - Collector 명세

> 현재 캐릭의 PvP 관련 데이터를 수집해 DB에 저장하는 모듈

---

## 책임

- 현재 로그인한 캐릭터의 정체성/화폐/레이팅/장비 정보를 WoW API로 조회
- DB에 부분 업데이트 (다른 캐릭터의 데이터는 그대로 유지)
- 이벤트 단위로 갱신 함수 분리

## 인터페이스

```lua
function Collector:Initialize()
    -- 초기 상태 세팅, 이벤트는 Core가 등록
end

function Collector:RunFullSync()
    -- 모든 데이터 한 번에 갱신
    -- PLAYER_ENTERING_WORLD, PLAYER_LOGOUT, /pvpster sync 시 호출
end

function Collector:UpdateCharacter()
    -- 정체성 정보 (name, class, level, faction)
end

function Collector:UpdateCurrencies()
    -- 화폐 3종 갱신
end

function Collector:UpdateRatings()
    -- 5개 브래킷 레이팅 갱신
end

function Collector:UpdateEquipment()
    -- 평균 ilvl + 슬롯별 정보 갱신
end
```

각 Update* 함수는 마지막에 `UI:Refresh()` 호출.

---

## 정체성 수집

```lua
local name = UnitName("player")
local localizedClass, classFile = UnitClass("player")
local localizedRace, raceFile = UnitRace("player")
local faction = UnitFactionGroup("player")           -- "Alliance" / "Horde" / "Neutral"
local level = UnitLevel("player")
local gender = UnitSex("player")                     -- 1=알수없음, 2=남, 3=여
local realm = GetNormalizedRealmName()
```

DB 키: `string.format("%s-%s", realm, name)`

---

## 화폐 수집

### 대상

| 화폐명 | 상수 | ID |
|--------|------|-----|
| 명예 | `HONOR_CURRENCY_ID` | 1792 |
| 계정 공유 명예 | `ACCOUNT_WIDE_HONOR_CURRENCY_ID` | 1585 |
| 정복 | `CONQUEST_CURRENCY_ID` | 1602 |

### 호출

```lua
local function FetchCurrency(currencyID)
    local info = C_CurrencyInfo.GetCurrencyInfo(currencyID)
    if not info then return nil end

    return {
        quantity = info.quantity or 0,
        totalEarned = info.totalEarned or 0,
        maxQuantity = info.maxQuantity or 0,
        useTotalEarnedForMaxQty = info.useTotalEarnedForMaxQty or false,
    }
end
```

### 정복 캡 표시

`useTotalEarnedForMaxQty == true`인 경우 `quantity / maxQuantity`가 아니라
`totalEarned / maxQuantity` 기준으로 표시해야 한다 (Blizzard 기본 UI도 이 방식).

UI는 다음 형식으로 노출:
- 명예: `quantity / maxQuantity` (예: `1500 / 15000`)
- 정복: `totalEarned / maxQuantity` (예: `825 / 1350`) — 시즌 누적 / 시즌 캡

---

## 레이팅 수집

### 대상 브래킷

```lua
TRACKED_BRACKETS = {
    { index = 1, key = "2v2",        labelKey = "BRACKET_2V2" },
    { index = 2, key = "3v3",        labelKey = "BRACKET_3V3" },
    { index = 7, key = "shuffle",    labelKey = "BRACKET_SHUFFLE",  usesRounds = true },
    { index = 9, key = "blitz",      labelKey = "BRACKET_BLITZ",    usesRounds = true },
}
```

> RBG(4)는 v1에서 제외 — Solo Shuffle/Blitz로 대체된 콘텐츠라 거의 안 함.
> 필요 시 v2에서 옵션으로 토글 추가.

### 호출

```lua
local function FetchRating(bracketIndex)
    local rating, seasonBest, weeklyBest,
          seasonPlayed, seasonWon,
          weeklyPlayed, weeklyWon,
          lastWeeksBest, hasWon, pvpTier, ranking,
          roundsSeasonPlayed, roundsSeasonWon,
          roundsWeeklyPlayed, roundsWeeklyWon
        = GetPersonalRatedInfo(bracketIndex)

    return {
        rating = rating or 0,
        seasonBest = seasonBest or 0,
        weeklyBest = weeklyBest or 0,
        seasonPlayed = seasonPlayed or 0,
        seasonWon = seasonWon or 0,
        weeklyPlayed = weeklyPlayed or 0,
        weeklyWon = weeklyWon or 0,
        lastWeeksBest = lastWeeksBest or 0,
        pvpTier = pvpTier or 0,
        ranking = ranking or 0,
        roundsSeasonPlayed = roundsSeasonPlayed,
        roundsSeasonWon = roundsSeasonWon,
        roundsWeeklyPlayed = roundsWeeklyPlayed,
        roundsWeeklyWon = roundsWeeklyWon,
    }
end
```

### 워밍 호출

`PLAYER_LOGIN` 시 한 번 `RequestRatedInfo()` 호출. `PVP_RATED_STATS_UPDATE` 이벤트에서
실제 값 조회. 호출 없이 바로 `GetPersonalRatedInfo`를 부르면 0/nil 반환되는 경우가 있어
이벤트 기반 갱신을 우선시한다.

---

## 장비 수집

### 평균 ilvl

```lua
local overall, equipped, pvp = GetAverageItemLevel()
-- overall: 가방 포함 최고 장비 기준 평균
-- equipped: 현재 착용 중인 장비 평균
-- pvp: PvP 환경에서 적용되는 평균 (PvP 능력치 반영)
```

UI 표시는 `equipped` (착용 ilvl) 기준. `pvp`는 보조 정보로 툴팁.

### 슬롯별 정보

```lua
ITEM_SLOTS = {
    1, 2, 3, 5, 6, 7, 8, 9, 10,    -- 머리/목/어깨/가슴/허리/다리/발/손목/장갑
    11, 12,                          -- 반지 1, 2
    13, 14,                          -- 장신구 1, 2
    15,                              -- 등
    16, 17,                          -- 주무기, 보조무기
}
```

```lua
local function FetchSlot(slotID)
    local link = GetInventoryItemLink("player", slotID)
    if not link then return nil end

    local quality = GetInventoryItemQuality("player", slotID)
    local location = ItemLocation:CreateFromEquipmentSlot(slotID)
    local itemLevel = nil
    if C_Item.DoesItemExist(location) then
        itemLevel = C_Item.GetCurrentItemLevel(location)
    end

    return {
        itemLink = link,
        itemLevel = itemLevel or 0,
        quality = quality or 0,
    }
end
```

### 갱신 빈도

`PLAYER_EQUIPMENT_CHANGED` 발생 시마다 호출. 단, **debounce 0.5초** 적용 —
연속 장비 교체(세트 교체) 시 16번 다시 도는 걸 방지.

```lua
-- C_Timer.After를 이용한 단순 debounce
local pendingEquipmentUpdate = false

function Collector:UpdateEquipment()
    if pendingEquipmentUpdate then return end
    pendingEquipmentUpdate = true
    C_Timer.After(0.5, function()
        pendingEquipmentUpdate = false
        actuallyUpdateEquipment()
    end)
end
```

---

## 데이터 신선도

- 다른 캐릭터의 데이터는 해당 캐릭이 한 번이라도 로그인해야 갱신됨 (WoW 제약)
- DB의 `lastSeen`을 UI에서 "{N}일 전" 형식으로 표시
- 30일 이상 미접속 캐릭은 회색 처리 (옵션, v2 예정)

---

## 부재 데이터 처리

| 상황 | 동작 |
|------|------|
| 신규 캐릭, 레이팅 한 번도 못 함 | 모든 필드 0 / nil 그대로 저장 |
| 정복 캡 미해제 (시즌 초) | quantity=0 그대로 |
| API 호출 실패 (`GetPersonalRatedInfo` nil 반환) | 기존 DB 값 보존 (덮어쓰지 않음) |
