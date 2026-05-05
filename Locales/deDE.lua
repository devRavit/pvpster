--[[
    PvPster Locale: deDE (Deutsch)
    Translations follow standard Blizzard WoW terminology where verified;
    longer sentences are best-effort and warrant a native-speaker review
    pass before release. Missing keys fall back to enUS.
]]

local _, PvPster = ...

PvPster.LOCALE_REGISTRY = PvPster.LOCALE_REGISTRY or {
    strings = {},
    names = {},
    order = {},
}


local KEY = "deDE"
table.insert(PvPster.LOCALE_REGISTRY.order, KEY)
PvPster.LOCALE_REGISTRY.names[KEY] = "Deutsch"
PvPster.LOCALE_REGISTRY.strings[KEY] = {
    ["Sync"] = "Sync",
    ["Show"] = "Anzeigen",
    ["Hide"] = "Verbergen",
    ["Reset"] = "Reset",
    ["Help"] = "Hilfe",
    ["Close"] = "Schließen",

    ["Name"] = "Name",
    ["Level"] = "Stf.",
    ["Honor"] = "Ehre",
    ["Conquest"] = "Eroberung",
    ["LastSeen"] = "Aktuell.",

    ["NoCharactersTitle"] = "Noch keine Charakterdaten",
    ["NoCharactersBody"] = "Loggt euch einmal mit jedem Charakter ein, um die Liste zu füllen.",

    ["LastSync"] = "Letzte Sync: %s",
    ["JustNow"] = "soeben",
    ["MinutesAgo"] = "vor %d Min.",
    ["HoursAgo"] = "vor %d Std.",
    ["DaysAgo"] = "vor %d Tg.",

    ["DataResetConfirm"] = "Tippt /pvpster reset confirm, um alle Charakterdaten zu löschen.",
    ["DataReset"] = "Alle Charakterdaten gelöscht.",
    ["SyncDone"] = "%s synchronisiert.",
    ["DebugOn"] = "Debug-Logging aktiviert.",
    ["DebugOff"] = "Debug-Logging deaktiviert.",
    ["UnknownCommand"] = "Unbekannter Befehl. Versucht /pvpster help.",
    ["HelpCommands"] = "Befehle:",

    ["AverageItemLevel"] = "Ø GS",
    ["Equipment"] = "Ausrüstung",
    ["Currencies"] = "Währungen",
    ["Ratings"] = "Wertungen",
    ["WeeklyShort"] = "Wch.",
    ["SeasonShort"] = "Sai.",
    ["WinRate"] = "Siegquote",
    ["AccountHonor"] = "Account-Ehre",
    ["Enchant"] = "Verzauberung",
    ["Gem"] = "Edelstein",

    ["LeftClickToggle"] = "Linksklick: Fenster ein-/ausblenden",
    ["RightClickDebug"] = "Rechtsklick: Debug ein-/ausschalten",
    ["DragToReposition"] = "Ziehen: Position ändern",
    ["MinimapShown"] = "Minimap-Button angezeigt.",
    ["MinimapHidden"] = "Minimap-Button ausgeblendet.",
    ["ScaleLabel"] = "Skalierung  %.2f",
    ["ScaleSet"] = "Skalierung auf %.2f gesetzt",
    ["Minimap"] = "Minimap",
    ["ResetConfirmDialog"] = "Alle PvPster-Charakterdaten löschen?",
    ["Theme"] = "Design",
    ["ThemeSet"] = "Design: %s",

    ["Language"] = "Sprache",
    ["LocaleCurrent"] = "Sprache: %s (aktiv: %s)",
    ["LocaleSupported"] = "Verfügbar:",
    ["LocaleSet"] = "Sprache auf %s gesetzt.",
    ["LocaleUnsupported"] = "Nicht unterstützte Sprache.",

    ["Slot_Head"] = "Kopf",
    ["Slot_Neck"] = "Hals",
    ["Slot_Shoulder"] = "Schultern",
    ["Slot_Chest"] = "Brust",
    ["Slot_Waist"] = "Taille",
    ["Slot_Legs"] = "Beine",
    ["Slot_Feet"] = "Füße",
    ["Slot_Wrist"] = "Handgelenke",
    ["Slot_Hands"] = "Hände",
    ["Slot_Finger1"] = "Ring 1",
    ["Slot_Finger2"] = "Ring 2",
    ["Slot_Trinket1"] = "Schmuckstück 1",
    ["Slot_Trinket2"] = "Schmuckstück 2",
    ["Slot_Back"] = "Rücken",
    ["Slot_MainHand"] = "Haupthand",
    ["Slot_OffHand"] = "Schildhand",

    ["StateOn"] = "AN",
    ["StateOff"] = "AUS",

    ["EnchantStat_7969"] = "+? Meisterschaft",
    ["EnchantStat_7973"] = "+? Bewegungsgeschwindigkeit",
    ["EnchantStat_7991"] = "+? Bewegungsgeschwindigkeit",
    ["EnchantStat_8013"] = "+? Intelligenz / +? Max. Mana",
    ["EnchantStat_8019"] = "+? Bewegungsgeschwindigkeit / +? Gesundheit",
    ["EnchantStat_8039"] = "Zaubertreffer gewähren Schärfe der Ren'dorei",
}
