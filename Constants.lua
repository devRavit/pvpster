--[[
    PvPster Constants
    Currency IDs, bracket indices, equipment slot IDs (12.0.5 verified)
]]

local _, PvPster = ...


local Constants = {}
PvPster.Constants = Constants


-- Currency IDs (verified from Blizzard_APIDocumentationGenerated/CurrencyConstantsDocumentation.lua)
Constants.HONOR_CURRENCY_ID = 1792
Constants.ACCOUNT_WIDE_HONOR_CURRENCY_ID = 1585
Constants.CONQUEST_CURRENCY_ID = 1602


-- PvP Bracket Indices (verified from Blizzard_FrameXMLBase/Constants.lua)
-- CONQUEST_BRACKET_INDEXES = { 7, 9, 1, 2, 4 }
Constants.BRACKET_2V2 = 1
Constants.BRACKET_3V3 = 2
Constants.BRACKET_RBG = 4
Constants.BRACKET_SHUFFLE = 7
Constants.BRACKET_BLITZ = 9


-- Tracked brackets in display order
-- usesRounds: Solo Shuffle is round-based (each match = 6 rounds, win/loss tracked per round).
-- Blitz is a single 8v8 BG match, so uses regular seasonPlayed/Won.
Constants.TRACKED_BRACKETS = {
    { index = 1, key = "bracket_1", labelKey = "BRACKET_2V2" },
    { index = 2, key = "bracket_2", labelKey = "BRACKET_3V3" },
    { index = 7, key = "bracket_7", labelKey = "BRACKET_SHUFFLE", usesRounds = true },
    { index = 9, key = "bracket_9", labelKey = "BRACKET_BLITZ" },
}


-- Item slots that contribute to average ilvl (excludes shirt=4, tabard=19)
Constants.ITEM_SLOTS = {
    1, 2, 3, 5, 6, 7, 8, 9, 10,
    11, 12,
    13, 14,
    15,
    16, 17,
}


Constants.SLOT_NAMES = {
    [1] = "Head",
    [2] = "Neck",
    [3] = "Shoulder",
    [5] = "Chest",
    [6] = "Waist",
    [7] = "Legs",
    [8] = "Feet",
    [9] = "Wrist",
    [10] = "Hands",
    [11] = "Finger1",
    [12] = "Finger2",
    [13] = "Trinket1",
    [14] = "Trinket2",
    [15] = "Back",
    [16] = "MainHand",
    [17] = "OffHand",
}


-- Localization keys for tooltip display
Constants.SLOT_LABEL_KEYS = {
    [1] = "Slot_Head",
    [2] = "Slot_Neck",
    [3] = "Slot_Shoulder",
    [5] = "Slot_Chest",
    [6] = "Slot_Waist",
    [7] = "Slot_Legs",
    [8] = "Slot_Feet",
    [9] = "Slot_Wrist",
    [10] = "Slot_Hands",
    [11] = "Slot_Finger1",
    [12] = "Slot_Finger2",
    [13] = "Slot_Trinket1",
    [14] = "Slot_Trinket2",
    [15] = "Slot_Back",
    [16] = "Slot_MainHand",
    [17] = "Slot_OffHand",
}


-- DB schema version (bump on breaking changes, add migration)
Constants.DB_VERSION = 1


-- UI defaults
Constants.UI_DEFAULTS = {
    width = 1180,
    height = 460,
    rowHeight = 22,
    sortColumn = "name",
    sortDirection = "asc",
}


-- Equipment update debounce (seconds)
Constants.EQUIPMENT_DEBOUNCE = 0.5


-- Item class ID for gems (Enum.ItemClass.Gem in modern API)
Constants.ITEM_CLASS_GEM = (Enum and Enum.ItemClass and Enum.ItemClass.Gem) or 3


-- Enchant ID → stat description.
-- Enchant ID is at position 2 of the item link payload and is locale-independent.
-- Sources: Wowhead live 12.0.5, method.gg (2026-03-02), wow-professions.com,
--          icy-veins.com (2026-04-21).
-- Wowhead tooltip stat magnitudes are JS-rendered and cannot be scraped
-- automatically; "+?" placeholders below mean the stat *type* is verified but
-- the exact magnitude needs an in-game tooltip check (or Wowhead with JS).
-- Note: leg enchants (7937 etc.) are intentionally absent — Tailoring
-- spellthreads / LW armor kits expose their stat values directly in the
-- tooltip's "Enchanted:" line, so no override is needed for that slot.
Constants.ENCHANT_STATS_BY_ID = {
    -- ===== Enchanting (Midnight 12.0.5) =====
    -- Ring (반지)
    [7969] = "+? 특화",                       -- Zul'jin's Mastery (spell 1236060)

    -- Shoulder (어깨) — Speed = 이동속도, NOT Haste
    [7973] = "+? 이속",                       -- Akil'zon's Swiftness (spell 1236062)

    -- Helm (머리) — Speed + Midnight skyriding charge effect outdoor
    [7991] = "+? 이속",                       -- Empowered Blessing of Speed (spell 1236071)

    -- Chest (가슴)
    [8013] = "+? 지능 / +? 최대 마나",        -- Mark of the Magister (spell 1236082)

    -- Boots (발)
    [8019] = "+? 이속 / +? 체력",             -- Farstrider's Hunt (spell 1236085)

    -- Weapon (무기) — proc-based
    [8039] = "주문 적중 시 공허의 위력 부여", -- Acuity of the Ren'dorei (spell 1236095)
}
