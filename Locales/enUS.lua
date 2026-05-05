--[[
    PvPster Locale: enUS (English) — default fallback
    All other locales overlay this one, so any key missing from a non-enUS
    locale resolves here. enUS must contain every key that the addon reads.
]]

local _, PvPster = ...

PvPster.LOCALE_REGISTRY = PvPster.LOCALE_REGISTRY or {
    strings = {},
    names = {},
    order = {},
}


local KEY = "enUS"
table.insert(PvPster.LOCALE_REGISTRY.order, KEY)
PvPster.LOCALE_REGISTRY.names[KEY] = "English"
PvPster.LOCALE_REGISTRY.strings[KEY] = {
    -- General
    ["PvPster"] = "PvPster",
    ["Sync"] = "Sync",
    ["Show"] = "Show",
    ["Hide"] = "Hide",
    ["Reset"] = "Reset",
    ["Help"] = "Help",
    ["Close"] = "Close",

    -- Columns
    ["Name"] = "Name",
    ["Realm"] = "Realm",
    ["Level"] = "Lv",
    ["iLvl"] = "iLvl",
    ["Honor"] = "Honor",
    ["Conquest"] = "Conquest",
    ["BRACKET_2V2"] = "2v2",
    ["BRACKET_3V3"] = "3v3",
    ["BRACKET_SHUFFLE"] = "Shuffle",
    ["BRACKET_BLITZ"] = "Blitz",
    ["LastSeen"] = "Updated",

    -- Empty state
    ["NoCharactersTitle"] = "No character data yet",
    ["NoCharactersBody"] = "Log into each character once to populate this list.",

    -- Footer
    ["LastSync"] = "Last sync: %s",
    ["JustNow"] = "just now",
    ["MinutesAgo"] = "%dm ago",
    ["HoursAgo"] = "%dh ago",
    ["DaysAgo"] = "%dd ago",

    -- Slash messages
    ["DataResetConfirm"] = "Type /pvpster reset confirm to wipe all character data.",
    ["DataReset"] = "All character data wiped.",
    ["SyncDone"] = "Synced %s.",
    ["DebugOn"] = "Debug logging enabled.",
    ["DebugOff"] = "Debug logging disabled.",
    ["UnknownCommand"] = "Unknown command. Try /pvpster help.",
    ["HelpCommands"] = "Commands:",

    -- Tooltip headings
    ["AverageItemLevel"] = "Avg iLvl",
    ["Equipment"] = "Equipment",
    ["Currencies"] = "Currencies",
    ["Ratings"] = "Ratings",
    ["WeeklyShort"] = "Wk",
    ["SeasonShort"] = "Se",
    ["WinRate"] = "Win rate",
    ["WinLossRecord"] = "%sW %sL",
    ["AccountHonor"] = "Account Honor",
    ["Enchant"] = "Enchant",
    ["Gem"] = "Gem",

    -- Minimap
    ["LeftClickToggle"] = "Left-click: Toggle window",
    ["RightClickDebug"] = "Right-click: Toggle debug",
    ["DragToReposition"] = "Drag: Reposition",
    ["MinimapShown"] = "Minimap button shown.",
    ["MinimapHidden"] = "Minimap button hidden.",
    ["ScaleLabel"] = "Scale  %.2f",
    ["ScaleSet"] = "Scale set to %.2f",
    ["Minimap"] = "Minimap",
    ["ResetConfirmDialog"] = "Wipe all PvPster character data?",
    ["Theme"] = "Theme",
    ["ThemeSet"] = "Theme: %s",

    -- Language
    ["Language"] = "Language",
    ["LocaleAuto"] = "Auto",
    ["LocaleCurrent"] = "Language: %s (effective: %s)",
    ["LocaleSupported"] = "Supported:",
    ["LocaleSet"] = "Language set to %s.",
    ["LocaleUnsupported"] = "Unsupported language.",

    -- Equipment slot labels
    ["Slot_Head"] = "Head",
    ["Slot_Neck"] = "Neck",
    ["Slot_Shoulder"] = "Shoulder",
    ["Slot_Chest"] = "Chest",
    ["Slot_Waist"] = "Waist",
    ["Slot_Legs"] = "Legs",
    ["Slot_Feet"] = "Feet",
    ["Slot_Wrist"] = "Wrist",
    ["Slot_Hands"] = "Hands",
    ["Slot_Finger1"] = "Ring 1",
    ["Slot_Finger2"] = "Ring 2",
    ["Slot_Trinket1"] = "Trinket 1",
    ["Slot_Trinket2"] = "Trinket 2",
    ["Slot_Back"] = "Back",
    ["Slot_MainHand"] = "Main Hand",
    ["Slot_OffHand"] = "Off Hand",

    -- Toggle state labels (minimap on/off button etc.)
    ["StateOn"] = "ON",
    ["StateOff"] = "OFF",

    -- Enchant stat overrides — keyed by enchant ID. Stat words follow Blizzard's
    -- official localized terms (same vocabulary Wowhead uses for each language).
    -- "+?" placeholders are kept where the magnitude needs an in-game tooltip
    -- check (Wowhead JS-renders the numeric values).
    ["EnchantStat_7969"] = "+? Mastery",
    ["EnchantStat_7973"] = "+? Movement Speed",
    ["EnchantStat_7991"] = "+? Movement Speed",
    ["EnchantStat_8013"] = "+? Intellect / +? Max Mana",
    ["EnchantStat_8019"] = "+? Movement Speed / +? Health",
    ["EnchantStat_8039"] = "On spell hit, grants Acuity of the Ren'dorei",

    -- Classes (keyed by classFile uppercased — value of UnitClass()'s 2nd return)
    ["CLASS_WARRIOR"] = "Warrior",
    ["CLASS_PALADIN"] = "Paladin",
    ["CLASS_HUNTER"] = "Hunter",
    ["CLASS_ROGUE"] = "Rogue",
    ["CLASS_PRIEST"] = "Priest",
    ["CLASS_DEATHKNIGHT"] = "Death Knight",
    ["CLASS_SHAMAN"] = "Shaman",
    ["CLASS_MAGE"] = "Mage",
    ["CLASS_WARLOCK"] = "Warlock",
    ["CLASS_MONK"] = "Monk",
    ["CLASS_DRUID"] = "Druid",
    ["CLASS_DEMONHUNTER"] = "Demon Hunter",
    ["CLASS_EVOKER"] = "Evoker",

    -- Races (keyed by raceFile uppercased — value of UnitRace()'s 2nd return)
    ["RACE_HUMAN"] = "Human",
    ["RACE_DWARF"] = "Dwarf",
    ["RACE_NIGHTELF"] = "Night Elf",
    ["RACE_GNOME"] = "Gnome",
    ["RACE_DRAENEI"] = "Draenei",
    ["RACE_WORGEN"] = "Worgen",
    ["RACE_PANDAREN"] = "Pandaren",
    ["RACE_ORC"] = "Orc",
    ["RACE_SCOURGE"] = "Undead",
    ["RACE_TAUREN"] = "Tauren",
    ["RACE_TROLL"] = "Troll",
    ["RACE_BLOODELF"] = "Blood Elf",
    ["RACE_GOBLIN"] = "Goblin",
    ["RACE_VOIDELF"] = "Void Elf",
    ["RACE_LIGHTFORGEDDRAENEI"] = "Lightforged Draenei",
    ["RACE_DARKIRONDWARF"] = "Dark Iron Dwarf",
    ["RACE_KULTIRAN"] = "Kul Tiran",
    ["RACE_MECHAGNOME"] = "Mechagnome",
    ["RACE_NIGHTBORNE"] = "Nightborne",
    ["RACE_HIGHMOUNTAINTAUREN"] = "Highmountain Tauren",
    ["RACE_MAGHARORC"] = "Mag'har Orc",
    ["RACE_ZANDALARITROLL"] = "Zandalari Troll",
    ["RACE_VULPERA"] = "Vulpera",
    ["RACE_DRACTHYR"] = "Dracthyr",
    ["RACE_EARTHENDWARF"] = "Earthen",

    -- Stat names (used to translate gem stat text from client locale to addon
    -- locale at render time). Keep in sync with Constants.STAT_KEYWORDS so the
    -- pattern table can find every stat we want to translate.
    ["Stat_Mastery"] = "Mastery",
    ["Stat_Haste"] = "Haste",
    ["Stat_CritStrike"] = "Critical Strike",
    ["Stat_Versatility"] = "Versatility",
    ["Stat_Intellect"] = "Intellect",
    ["Stat_Strength"] = "Strength",
    ["Stat_Agility"] = "Agility",
    ["Stat_Stamina"] = "Stamina",
    ["Stat_Health"] = "Health",
    ["Stat_Mana"] = "Mana",
    ["Stat_MaxMana"] = "Max Mana",
    ["Stat_MovementSpeed"] = "Movement Speed",
}
