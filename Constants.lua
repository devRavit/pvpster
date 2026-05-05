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


-- DB schema version (bump on breaking changes, add migration in DB.lua).
-- v2 (2026-05): enchant stat overrides moved from Collector merge-time to UI
--               render-time, so v1 enchantName strings (which had the override
--               appended) are incompatible. DB.lua wipes characters on mismatch.
Constants.DB_VERSION = 2


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


-- Enchant ID → Localization key. Enchant ID is at position 2 of the item link
-- payload and is locale-independent; the resolved string lives in
-- Localization.lua under the same key, so a UI language switch updates the
-- displayed stat without needing to re-collect equipment.
--
-- Sources: Wowhead live 12.0.5 spell pages (per-language). When adding a new
-- locale, switch language on Wowhead and use the displayed stat wording:
--   7969 (spell 1236060) Zul'jin's Mastery               https://www.wowhead.com/spell=1236060
--   7973 (spell 1236062) Akil'zon's Swiftness            https://www.wowhead.com/spell=1236062
--   7991 (spell 1236071) Empowered Blessing of Speed     https://www.wowhead.com/spell=1236071
--   8013 (spell 1236082) Mark of the Magister            https://www.wowhead.com/spell=1236082
--   8019 (spell 1236085) Farstrider's Hunt               https://www.wowhead.com/spell=1236085
--   8039 (spell 1236095) Acuity of the Ren'dorei         https://www.wowhead.com/spell=1236095
--
-- "+?" placeholders mean the stat *type* is verified but the magnitude needs
-- an in-game tooltip check (Wowhead JS-renders the numbers).
-- Note: leg enchants (7937 etc.) are intentionally absent — Tailoring
-- spellthreads / LW armor kits expose their stat values directly in the
-- tooltip's "Enchanted:" line, so no override is needed for that slot.
Constants.ENCHANT_STATS_BY_ID = {
    [7969] = "EnchantStat_7969",  -- Ring
    [7973] = "EnchantStat_7973",  -- Shoulder (Movement Speed, NOT Haste)
    [7991] = "EnchantStat_7991",  -- Helm
    [8013] = "EnchantStat_8013",  -- Chest
    [8019] = "EnchantStat_8019",  -- Boots
    [8039] = "EnchantStat_8039",  -- Weapon (proc)
}
