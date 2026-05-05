--[[
    PvPster Locale: frFR (Français)
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


local KEY = "frFR"
table.insert(PvPster.LOCALE_REGISTRY.order, KEY)
PvPster.LOCALE_REGISTRY.names[KEY] = "Français"
PvPster.LOCALE_REGISTRY.strings[KEY] = {
    ["Sync"] = "Sync",
    ["Show"] = "Afficher",
    ["Hide"] = "Cacher",
    ["Reset"] = "Réinit.",
    ["Help"] = "Aide",
    ["Close"] = "Fermer",

    ["Name"] = "Nom",
    ["Realm"] = "Royaume",
    ["Level"] = "Niv.",
    ["Honor"] = "Honneur",
    ["Conquest"] = "Conquête",
    ["LastSeen"] = "M.à.j",

    ["NoCharactersTitle"] = "Aucune donnée de personnage",
    ["NoCharactersBody"] = "Connectez-vous une fois sur chaque personnage pour remplir la liste.",

    ["LastSync"] = "Dernière sync : %s",
    ["JustNow"] = "à l'instant",
    ["MinutesAgo"] = "il y a %d min",
    ["HoursAgo"] = "il y a %d h",
    ["DaysAgo"] = "il y a %d j",

    ["DataResetConfirm"] = "Tapez /pvpster reset confirm pour effacer toutes les données.",
    ["DataReset"] = "Toutes les données de personnage ont été effacées.",
    ["SyncDone"] = "%s synchronisé.",
    ["DebugOn"] = "Journal de débogage activé.",
    ["DebugOff"] = "Journal de débogage désactivé.",
    ["UnknownCommand"] = "Commande inconnue. Essayez /pvpster help.",
    ["HelpCommands"] = "Commandes :",

    ["AverageItemLevel"] = "iLvl moy.",
    ["Equipment"] = "Équipement",
    ["Currencies"] = "Monnaies",
    ["Ratings"] = "Cotes",
    ["WeeklyShort"] = "Sem.",
    ["SeasonShort"] = "Sai.",
    ["WinRate"] = "Taux de victoire",
    ["AccountHonor"] = "Honneur du compte",
    ["Enchant"] = "Enchantement",
    ["Gem"] = "Gemme",

    ["LeftClickToggle"] = "Clic gauche : afficher/masquer la fenêtre",
    ["RightClickDebug"] = "Clic droit : activer/désactiver le débogage",
    ["DragToReposition"] = "Glisser : repositionner",
    ["MinimapShown"] = "Bouton de la minicarte affiché.",
    ["MinimapHidden"] = "Bouton de la minicarte masqué.",
    ["ScaleLabel"] = "Échelle  %.2f",
    ["ScaleSet"] = "Échelle réglée à %.2f",
    ["Minimap"] = "Minicarte",
    ["ResetConfirmDialog"] = "Effacer toutes les données de personnage PvPster ?",
    ["Theme"] = "Thème",
    ["ThemeSet"] = "Thème : %s",

    ["Language"] = "Langue",
    ["LocaleCurrent"] = "Langue : %s (effective : %s)",
    ["LocaleSupported"] = "Prises en charge :",
    ["LocaleSet"] = "Langue réglée sur %s.",
    ["LocaleUnsupported"] = "Langue non prise en charge.",

    ["Slot_Head"] = "Tête",
    ["Slot_Neck"] = "Cou",
    ["Slot_Shoulder"] = "Épaules",
    ["Slot_Chest"] = "Torse",
    ["Slot_Waist"] = "Taille",
    ["Slot_Legs"] = "Jambes",
    ["Slot_Feet"] = "Pieds",
    ["Slot_Wrist"] = "Poignets",
    ["Slot_Hands"] = "Mains",
    ["Slot_Finger1"] = "Anneau 1",
    ["Slot_Finger2"] = "Anneau 2",
    ["Slot_Trinket1"] = "Bijou 1",
    ["Slot_Trinket2"] = "Bijou 2",
    ["Slot_Back"] = "Dos",
    ["Slot_MainHand"] = "Main droite",
    ["Slot_OffHand"] = "Main gauche",

    ["EnchantStat_7969"] = "+? Maîtrise",
    ["EnchantStat_7973"] = "+? Vitesse de déplacement",
    ["EnchantStat_7991"] = "+? Vitesse de déplacement",
    ["EnchantStat_8013"] = "+? Intelligence / +? Mana max.",
    ["EnchantStat_8019"] = "+? Vitesse de déplacement / +? Santé",
    ["EnchantStat_8039"] = "Les sorts ont une chance d'accorder Acuité du Ren'dorei",
}
