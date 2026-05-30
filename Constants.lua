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


-- Conquest weekly cap fallback. The 12.0 API returns maxQuantity=0 for conquest
-- when useTotalEarnedForMaxQty=true, so row color compares totalEarned against
-- this value when the API doesn't surface a cap.
Constants.CONQUEST_WEEKLY_CAP_FALLBACK = 8000


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


-- Per-locale stat keyword patterns used to translate gem stat tooltip text
-- (collected in client locale) into the active addon locale at render time.
-- Each entry maps a literal source word → an L key. Order matters: longer
-- substrings must precede shorter ones so multi-word stats ("Critical Strike",
-- "최대 마나") aren't partially matched by their suffix ("Strike", "마나").
--
-- Sources cross-checked against VgerMods/Pawn (per-locale Localization files),
-- which has battle-tested patterns for actual in-game gem/item tooltip text.
-- Some locales include multiple inflections (Russian dative, Spanish/Portuguese
-- alternates) since gems use different forms than character pane.
Constants.STAT_KEYWORDS = {
    enUS = {
        { "Critical Strike", "Stat_CritStrike" },
        { "Movement Speed", "Stat_MovementSpeed" },
        { "Max Mana", "Stat_MaxMana" },
        { "Versatility", "Stat_Versatility" },
        { "Intellect", "Stat_Intellect" },
        { "Strength", "Stat_Strength" },
        { "Agility", "Stat_Agility" },
        { "Stamina", "Stat_Stamina" },
        { "Mastery", "Stat_Mastery" },
        { "Health", "Stat_Health" },
        { "Haste", "Stat_Haste" },
        { "Mana", "Stat_Mana" },
    },
    koKR = {
        { "이동 속도", "Stat_MovementSpeed" },
        { "이동속도", "Stat_MovementSpeed" },
        { "최대 마나", "Stat_MaxMana" },
        { "치명타", "Stat_CritStrike" },
        { "유연성", "Stat_Versatility" },
        { "민첩성", "Stat_Agility" },
        { "생명력", "Stat_Health" },
        { "지능", "Stat_Intellect" },
        { "특화", "Stat_Mastery" },
        { "체력", "Stat_Stamina" },
        { "가속", "Stat_Haste" },
        { "마나", "Stat_Mana" },
        { "힘", "Stat_Strength" },
    },
    deDE = {
        { "Bewegungsgeschwindigkeit", "Stat_MovementSpeed" },
        { "Kritische Trefferchance", "Stat_CritStrike" },
        { "Kritischer Trefferwert", "Stat_CritStrike" },  -- gem text form
        { "kritischer Trefferwert", "Stat_CritStrike" },
        { "Kritische Treffer", "Stat_CritStrike" },
        { "Vielseitigkeit", "Stat_Versatility" },
        { "Meisterschaft", "Stat_Mastery" },
        { "Beweglichkeit", "Stat_Agility" },
        { "Intelligenz", "Stat_Intellect" },
        { "Gesundheit", "Stat_Health" },
        { "Max. Mana", "Stat_MaxMana" },
        { "Ausdauer", "Stat_Stamina" },
        { "Stärke", "Stat_Strength" },
        { "Tempo", "Stat_Haste" },
        { "Mana", "Stat_Mana" },
    },
    frFR = {
        { "Vitesse de déplacement", "Stat_MovementSpeed" },
        { "Score de coup critique", "Stat_CritStrike" },  -- full gem rating form
        { "Score de critique", "Stat_CritStrike" },
        { "Coup critique", "Stat_CritStrike" },
        { "Score de crit", "Stat_CritStrike" },  -- abbreviated gem form per Pawn
        { "Polyvalence", "Stat_Versatility" },
        { "Intelligence", "Stat_Intellect" },
        { "Mana max.", "Stat_MaxMana" },
        { "Maîtrise", "Stat_Mastery" },
        { "Endurance", "Stat_Stamina" },
        { "Agilité", "Stat_Agility" },
        { "Santé", "Stat_Health" },
        { "Force", "Stat_Strength" },
        { "Hâte", "Stat_Haste" },
        { "Mana", "Stat_Mana" },
    },
    esES = {
        { "Velocidad de movimiento", "Stat_MovementSpeed" },
        { "Golpe crítico", "Stat_CritStrike" },
        { "Versatilidad", "Stat_Versatility" },
        { "Maná máx.", "Stat_MaxMana" },
        { "Maestría", "Stat_Mastery" },
        { "Celeridad", "Stat_Haste" },
        { "Intelecto", "Stat_Intellect" },
        { "Agilidad", "Stat_Agility" },
        { "Aguante", "Stat_Stamina" },
        { "Fuerza", "Stat_Strength" },
        { "Salud", "Stat_Health" },
        { "Maná", "Stat_Mana" },
    },
    esMX = {
        { "Velocidad de movimiento", "Stat_MovementSpeed" },
        { "Golpe crítico", "Stat_CritStrike" },
        { "Versatilidad", "Stat_Versatility" },
        { "Maná máx.", "Stat_MaxMana" },
        { "Maestría", "Stat_Mastery" },
        { "Celeridad", "Stat_Haste" },
        { "Intelecto", "Stat_Intellect" },
        { "Agilidad", "Stat_Agility" },
        { "Aguante", "Stat_Stamina" },
        { "Fuerza", "Stat_Strength" },
        { "Salud", "Stat_Health" },
        { "Maná", "Stat_Mana" },
    },
    ptBR = {
        { "Velocidade de Movimento", "Stat_MovementSpeed" },
        { "Acerto Crítico", "Stat_CritStrike" },  -- gem text form per Pawn
        { "Ataque crítico", "Stat_CritStrike" },
        { "Golpe Crítico", "Stat_CritStrike" },
        { "Versatilidade", "Stat_Versatility" },
        { "Aceleração", "Stat_Haste" },
        { "Mana Máx.", "Stat_MaxMana" },
        { "Maestria", "Stat_Mastery" },
        { "Intelecto", "Stat_Intellect" },
        { "Agilidade", "Stat_Agility" },
        { "Força", "Stat_Strength" },
        { "Vigor", "Stat_Stamina" },
        { "Vida", "Stat_Health" },
        { "Mana", "Stat_Mana" },
    },
    ruRU = {
        -- Russian gem tooltips use "+N к <stat-in-dative>" form, so dative-case
        -- patterns (with "к " prefix) come first to consume the entire phrase
        -- including "к ". Nominative variants follow for header/standalone use.
        -- Per Pawn ruRU patterns: "%+?# к ловкости", "%+?# к критическому удару".
        { "к скорости передвижения", "Stat_MovementSpeed" },
        { "к универсальности", "Stat_Versatility" },
        { "к выносливости", "Stat_Stamina" },
        { "к критическому удару", "Stat_CritStrike" },
        { "к искусности", "Stat_Mastery" },
        { "к интеллекту", "Stat_Intellect" },
        { "к ловкости", "Stat_Agility" },
        { "к скорости", "Stat_Haste" },
        { "к здоровью", "Stat_Health" },
        { "к силе", "Stat_Strength" },
        { "к мане", "Stat_Mana" },

        { "Скорость передвижения", "Stat_MovementSpeed" },
        { "Универсальность", "Stat_Versatility" },
        { "Выносливость", "Stat_Stamina" },
        { "Критический удар", "Stat_CritStrike" },
        { "Крит. удар", "Stat_CritStrike" },
        { "Макс. мана", "Stat_MaxMana" },
        { "Искусность", "Stat_Mastery" },
        { "Интеллект", "Stat_Intellect" },
        { "Здоровье", "Stat_Health" },
        { "Ловкость", "Stat_Agility" },
        { "Скорость", "Stat_Haste" },
        { "Сила", "Stat_Strength" },
        { "Мана", "Stat_Mana" },
    },
    zhCN = {
        { "移动速度", "Stat_MovementSpeed" },
        { "法力上限", "Stat_MaxMana" },
        { "生命值", "Stat_Health" },
        { "精通", "Stat_Mastery" },
        { "急速", "Stat_Haste" },
        { "爆击", "Stat_CritStrike" },  -- Blizzard's localization (Pawn/ElvUI)
        { "暴击", "Stat_CritStrike" },  -- common alternative spelling
        { "全能", "Stat_Versatility" },
        { "智力", "Stat_Intellect" },
        { "力量", "Stat_Strength" },
        { "敏捷", "Stat_Agility" },
        { "耐力", "Stat_Stamina" },
        { "生命", "Stat_Health" },  -- shorter form sometimes seen
        { "法力", "Stat_Mana" },
    },
    zhTW = {
        { "移動速度", "Stat_MovementSpeed" },
        { "法力上限", "Stat_MaxMana" },
        { "致命一擊", "Stat_CritStrike" },
        { "臨機應變", "Stat_Versatility" },
        { "精通", "Stat_Mastery" },
        { "加速", "Stat_Haste" },
        { "智力", "Stat_Intellect" },
        { "力量", "Stat_Strength" },
        { "敏捷", "Stat_Agility" },
        { "耐力", "Stat_Stamina" },
        { "生命力", "Stat_Health" },  -- longer form must precede shorter
        { "生命", "Stat_Health" },
        { "法力", "Stat_Mana" },
    },
}
