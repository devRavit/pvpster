--[[
    PvPster Locale: esMX (Español de México)
    WoW's Latin American Spanish localization is largely identical to esES
    for game terminology, so this file mirrors esES. Diverge only when an
    actual term differs in the official client.
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


local KEY = "esMX"
table.insert(PvPster.LOCALE_REGISTRY.order, KEY)
PvPster.LOCALE_REGISTRY.names[KEY] = "Español (MX)"
PvPster.LOCALE_REGISTRY.strings[KEY] = {
    ["Sync"] = "Sinc.",
    ["Show"] = "Mostrar",
    ["Hide"] = "Ocultar",
    ["Reset"] = "Reset",
    ["Help"] = "Ayuda",
    ["Close"] = "Cerrar",

    ["Name"] = "Nombre",
    ["Realm"] = "Reino",
    ["Level"] = "Niv.",
    ["Honor"] = "Honor",
    ["Conquest"] = "Conquista",
    ["LastSeen"] = "Actual.",

    ["NoCharactersTitle"] = "Aún no hay datos de personajes",
    ["NoCharactersBody"] = "Inicia sesión una vez con cada personaje para llenar esta lista.",

    ["LastSync"] = "Última sinc.: %s",
    ["JustNow"] = "ahora mismo",
    ["MinutesAgo"] = "hace %d min",
    ["HoursAgo"] = "hace %d h",
    ["DaysAgo"] = "hace %d d",

    ["DataResetConfirm"] = "Escribe /pvpster reset confirm para borrar todos los datos.",
    ["DataReset"] = "Todos los datos de personajes borrados.",
    ["SyncDone"] = "%s sincronizado.",
    ["DebugOn"] = "Registro de depuración activado.",
    ["DebugOff"] = "Registro de depuración desactivado.",
    ["UnknownCommand"] = "Comando desconocido. Prueba /pvpster help.",
    ["HelpCommands"] = "Comandos:",

    ["AverageItemLevel"] = "iLvl med.",
    ["Equipment"] = "Equipo",
    ["Currencies"] = "Monedas",
    ["Ratings"] = "Clasificaciones",
    ["WeeklyShort"] = "Sem.",
    ["SeasonShort"] = "Tem.",
    ["WinRate"] = "Tasa de victorias",
    ["AccountHonor"] = "Honor de cuenta",
    ["Enchant"] = "Encantamiento",
    ["Gem"] = "Gema",

    ["LeftClickToggle"] = "Clic izq.: alternar ventana",
    ["RightClickDebug"] = "Clic der.: alternar depuración",
    ["DragToReposition"] = "Arrastrar: reposicionar",
    ["MinimapShown"] = "Botón del minimapa mostrado.",
    ["MinimapHidden"] = "Botón del minimapa oculto.",
    ["ScaleLabel"] = "Escala  %.2f",
    ["ScaleSet"] = "Escala ajustada a %.2f",
    ["Minimap"] = "Minimapa",
    ["ResetConfirmDialog"] = "¿Borrar todos los datos de personajes de PvPster?",
    ["Theme"] = "Tema",
    ["ThemeSet"] = "Tema: %s",

    ["Language"] = "Idioma",
    ["LocaleCurrent"] = "Idioma: %s (efectivo: %s)",
    ["LocaleSupported"] = "Compatibles:",
    ["LocaleSet"] = "Idioma cambiado a %s.",
    ["LocaleUnsupported"] = "Idioma no compatible.",

    ["Slot_Head"] = "Cabeza",
    ["Slot_Neck"] = "Cuello",
    ["Slot_Shoulder"] = "Hombros",
    ["Slot_Chest"] = "Pecho",
    ["Slot_Waist"] = "Cintura",
    ["Slot_Legs"] = "Piernas",
    ["Slot_Feet"] = "Pies",
    ["Slot_Wrist"] = "Muñecas",
    ["Slot_Hands"] = "Manos",
    ["Slot_Finger1"] = "Anillo 1",
    ["Slot_Finger2"] = "Anillo 2",
    ["Slot_Trinket1"] = "Abalorio 1",
    ["Slot_Trinket2"] = "Abalorio 2",
    ["Slot_Back"] = "Espalda",
    ["Slot_MainHand"] = "Mano derecha",
    ["Slot_OffHand"] = "Mano izquierda",

    ["EnchantStat_7969"] = "+? Maestría",
    ["EnchantStat_7973"] = "+? Velocidad de movimiento",
    ["EnchantStat_7991"] = "+? Velocidad de movimiento",
    ["EnchantStat_8013"] = "+? Intelecto / +? Maná máx.",
    ["EnchantStat_8019"] = "+? Velocidad de movimiento / +? Salud",
    ["EnchantStat_8039"] = "Los hechizos pueden otorgar Agudeza de los ren'dorei",
}
