--[[
    PvPster Collector
    현재 캐릭터의 정체성, 화폐, 레이팅, 장비 정보 수집
    이벤트별 부분 갱신 + 전체 동기화 지원
]]

local _, PvPster = ...


-- Lua API Localization
local string = string
local ipairs = ipairs
local time = time

-- WoW API Localization
local C_CurrencyInfo = C_CurrencyInfo
local C_Item = C_Item
local C_Timer = C_Timer
local CreateFrame = CreateFrame
local ItemLocation = ItemLocation
local GetPersonalRatedInfo = GetPersonalRatedInfo
local GetAverageItemLevel = GetAverageItemLevel
local GetInventoryItemLink = GetInventoryItemLink
local GetInventoryItemQuality = GetInventoryItemQuality
local GetItemGem = GetItemGem
local UnitName = UnitName
local UnitClass = UnitClass
local UnitRace = UnitRace
local UnitFactionGroup = UnitFactionGroup
local UnitLevel = UnitLevel
local UnitSex = UnitSex
local GetNormalizedRealmName = GetNormalizedRealmName
local WorldFrame = WorldFrame
local ENCHANTED_TOOLTIP_LINE = ENCHANTED_TOOLTIP_LINE
local math = math


local Constants = PvPster.Constants
local Logger = PvPster.Logger
local DB = PvPster.DB


local Collector = {}
PvPster.Collector = Collector


local equipmentDebouncePending = false


local function fetchIdentity()
    local name = UnitName("player")
    local localizedClass, classFile = UnitClass("player")
    local localizedRace, raceFile = UnitRace("player")
    local faction = UnitFactionGroup("player")
    local level = UnitLevel("player")
    local gender = UnitSex("player")
    local realm = GetNormalizedRealmName()

    return {
        name = name,
        realm = realm,
        classFile = classFile,
        classLocalized = localizedClass,
        raceFile = raceFile,
        raceLocalized = localizedRace,
        faction = faction,
        level = level,
        gender = gender,
        lastSeen = time(),
    }
end


local function fetchCurrency(currencyID)
    local info = C_CurrencyInfo.GetCurrencyInfo(currencyID)
    if not info then return nil end

    return {
        quantity = info.quantity or 0,
        totalEarned = info.totalEarned or 0,
        maxQuantity = info.maxQuantity or 0,
        useTotalEarnedForMaxQty = info.useTotalEarnedForMaxQty or false,
    }
end


local function fetchAllCurrencies()
    return {
        honor = fetchCurrency(Constants.HONOR_CURRENCY_ID),
        accountHonor = fetchCurrency(Constants.ACCOUNT_WIDE_HONOR_CURRENCY_ID),
        conquest = fetchCurrency(Constants.CONQUEST_CURRENCY_ID),
    }
end


local function fetchRating(bracketIndex)
    local rating, seasonBest, weeklyBest,
          seasonPlayed, seasonWon,
          weeklyPlayed, weeklyWon,
          lastWeeksBest, hasWon, pvpTier, ranking,
          roundsSeasonPlayed, roundsSeasonWon,
          roundsWeeklyPlayed, roundsWeeklyWon
        = GetPersonalRatedInfo(bracketIndex)

    if rating == nil then return nil end

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


local function fetchAllRatings()
    local ratings = {}
    for _, bracket in ipairs(Constants.TRACKED_BRACKETS) do
        local data = fetchRating(bracket.index)
        if data then
            ratings[bracket.index] = data
        end
    end
    return ratings
end


local enchantScanner


local function ensureScanner()
    if not enchantScanner then
        enchantScanner = CreateFrame(
            "GameTooltip",
            "PvPsterEnchantScanner",
            nil,
            "GameTooltipTemplate"
        )
        enchantScanner:SetOwner(WorldFrame, "ANCHOR_NONE")
    end
    return enchantScanner
end


local function getEnchantNameFromItem(itemLink)
    if not itemLink then return nil end
    local scanner = ensureScanner()
    scanner:ClearLines()
    scanner:SetHyperlink(itemLink)

    local pattern = ENCHANTED_TOOLTIP_LINE
    if pattern then
        pattern = pattern:gsub("%%", "%%%%"):gsub("%%%%s", "(.+)")
    end

    for i = 2, scanner:NumLines() do
        local left = _G["PvPsterEnchantScannerTextLeft" .. i]
        if left then
            local text = left:GetText()
            if text and pattern then
                local match = text:match(pattern)
                if match then return match end
            end
        end
    end
    return nil
end


local function getGemStatText(gemLink)
    if not gemLink then return nil end
    local scanner = ensureScanner()
    scanner:ClearLines()
    scanner:SetHyperlink(gemLink)

    -- Line 1 is the item name. Stats usually live on line 2 (sometimes line 3).
    for i = 2, math.min(4, scanner:NumLines()) do
        local left = _G["PvPsterEnchantScannerTextLeft" .. i]
        if left then
            local text = left:GetText() or ""
            -- Skip empty / item-type lines, keep lines with numbers (stats)
            if text:match("%d") and not text:lower():find("required") then
                return text
            end
        end
    end
    return nil
end


local function getPvPItemLevel(itemLink)
    if not itemLink then return nil end
    local scanner = ensureScanner()
    scanner:ClearLines()
    scanner:SetHyperlink(itemLink)

    -- Use global constant first (locale-aware), then fall back to manual patterns
    local globalPattern
    if PVP_ITEM_LEVEL_TOOLTIP then
        globalPattern = PVP_ITEM_LEVEL_TOOLTIP
            :gsub("%%", "%%%%")
            :gsub("%%%%s", "(%%d+)")
    end

    for i = 2, scanner:NumLines() do
        local left = _G["PvPsterEnchantScannerTextLeft" .. i]
        if left then
            local text = left:GetText() or ""
            local match
            if globalPattern then
                match = text:match(globalPattern)
            end
            match = match
                or text:match("PvP%s*[Ii]tem%s*[Ll]evel%s*[:：]%s*(%d+)")
                or text:match("PvP%s*아이템%s*레벨%s*[:：]%s*(%d+)")
            if match then return tonumber(match) end
        end
    end
    return nil
end


local function parseGemIDs(itemLink)
    if not itemLink then return {} end
    local payload = itemLink:match("|H[%w]+:([^|]+)|h")
    if not payload then return {} end

    local parts = {}
    for part in payload:gmatch("([^:]*)") do
        parts[#parts + 1] = part
    end

    local gems = {}
    for i = 3, 6 do
        local gemID = tonumber(parts[i])
        if gemID and gemID > 0 then
            gems[#gems + 1] = gemID
        end
    end
    return gems
end


local function fetchSlotGems(itemLink)
    local gemLinks = {}
    local gemStats = {}
    if not itemLink or not GetItemGem then
        return gemLinks, gemStats
    end
    for i = 1, 4 do
        local _, gemLink = GetItemGem(itemLink, i)
        if gemLink then
            gemLinks[#gemLinks + 1] = gemLink
            gemStats[#gemStats + 1] = getGemStatText(gemLink) or ""
        end
    end
    return gemLinks, gemStats
end


local function fetchSlot(slotID)
    local link = GetInventoryItemLink("player", slotID)
    if not link then return nil end

    local quality = GetInventoryItemQuality("player", slotID)
    local location = ItemLocation:CreateFromEquipmentSlot(slotID)
    local itemLevel = 0
    if C_Item.DoesItemExist(location) then
        itemLevel = C_Item.GetCurrentItemLevel(location) or 0
    end

    local gemLinks, gemStats = fetchSlotGems(link)

    return {
        itemLink = link,
        itemLevel = itemLevel,
        pvpItemLevel = getPvPItemLevel(link),
        quality = quality or 0,
        enchantName = getEnchantNameFromItem(link),
        gemLinks = gemLinks,
        gemStats = gemStats,
    }
end


local function fetchEquipment()
    local overall, equipped, pvp = GetAverageItemLevel()

    local slots = {}
    for _, slotID in ipairs(Constants.ITEM_SLOTS) do
        local data = fetchSlot(slotID)
        if data then
            slots[slotID] = data
        end
    end

    return {
        averageItemLevel = overall or 0,
        averageItemLevelEquipped = equipped or 0,
        averageItemLevelPvP = pvp or 0,
        slots = slots,
    }
end


local function isEquipmentValid(equipment)
    if not equipment then return false end
    if (equipment.averageItemLevelEquipped or 0) > 0 then return true end
    if equipment.slots and next(equipment.slots) then return true end
    return false
end


local function notifyUI()
    if PvPster.UI and PvPster.UI.Refresh then
        PvPster.UI:Refresh()
    end
end


function Collector:Initialize()
    self._firstEntered = false
    Logger:Log("Collector", "Initialized")
end


function Collector:RunFullSync()
    local key = DB:GetCharacterKey()
    DB:UpsertCharacter(key, fetchIdentity())

    local currencies = fetchAllCurrencies()
    DB:UpsertCharacter(key, { currency = currencies })
    if currencies.accountHonor then
        DB:PropagateAccountCurrency("accountHonor", currencies.accountHonor)
    end

    DB:UpsertCharacter(key, { ratings = fetchAllRatings() })

    local equipment = fetchEquipment()
    if isEquipmentValid(equipment) then
        DB:UpsertCharacter(key, { equipment = equipment })
    else
        Logger:Log("Collector", "Skipped equipment save: not ready yet")
    end

    Logger:Log("Collector", "Full sync: " .. key)
    notifyUI()
end


function Collector:OnEnteringWorld()
    if not self._firstEntered then
        self._firstEntered = true
        if RequestRatedInfo then
            RequestRatedInfo()
        end
        self:RunFullSync()
    else
        self:UpdateCharacter()
    end
end


function Collector:UpdateCharacter()
    local key = DB:GetCharacterKey()
    DB:UpsertCharacter(key, fetchIdentity())
    notifyUI()
end


function Collector:UpdateCurrencies()
    local key = DB:GetCharacterKey()
    local currencies = fetchAllCurrencies()
    DB:UpsertCharacter(key, { currency = currencies })
    DB:UpsertCharacter(key, { lastSeen = time() })
    if currencies.accountHonor then
        DB:PropagateAccountCurrency("accountHonor", currencies.accountHonor)
    end
    notifyUI()
end


function Collector:UpdateRatings()
    local key = DB:GetCharacterKey()
    DB:UpsertCharacter(key, { ratings = fetchAllRatings() })
    DB:UpsertCharacter(key, { lastSeen = time() })
    notifyUI()
end


function Collector:UpdateEquipment()
    if equipmentDebouncePending then return end
    equipmentDebouncePending = true

    C_Timer.After(Constants.EQUIPMENT_DEBOUNCE, function()
        equipmentDebouncePending = false
        local key = DB:GetCharacterKey()
        local equipment = fetchEquipment()
        if isEquipmentValid(equipment) then
            DB:UpsertCharacter(key, { equipment = equipment })
            DB:UpsertCharacter(key, { lastSeen = time() })
            notifyUI()
        end
    end)
end
