--[[
    PvPster Locale: ptBR (Português do Brasil)
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


local KEY = "ptBR"
table.insert(PvPster.LOCALE_REGISTRY.order, KEY)
PvPster.LOCALE_REGISTRY.names[KEY] = "Português (BR)"
PvPster.LOCALE_REGISTRY.strings[KEY] = {
    ["Sync"] = "Sinc.",
    ["Show"] = "Mostrar",
    ["Hide"] = "Ocultar",
    ["Reset"] = "Resetar",
    ["Help"] = "Ajuda",
    ["Close"] = "Fechar",

    ["Name"] = "Nome",
    ["Realm"] = "Reino",
    ["Level"] = "Nv.",
    ["Honor"] = "Honra",
    ["Conquest"] = "Conquista",
    ["LastSeen"] = "Atualiz.",

    ["NoCharactersTitle"] = "Sem dados de personagens",
    ["NoCharactersBody"] = "Entre uma vez com cada personagem para preencher esta lista.",

    ["LastSync"] = "Última sinc: %s",
    ["JustNow"] = "agora mesmo",
    ["MinutesAgo"] = "há %d min",
    ["HoursAgo"] = "há %d h",
    ["DaysAgo"] = "há %d d",

    ["DataResetConfirm"] = "Digite /pvpster reset confirm para apagar todos os dados.",
    ["DataReset"] = "Todos os dados dos personagens apagados.",
    ["SyncDone"] = "%s sincronizado.",
    ["DebugOn"] = "Log de depuração ativado.",
    ["DebugOff"] = "Log de depuração desativado.",
    ["UnknownCommand"] = "Comando desconhecido. Tente /pvpster help.",
    ["HelpCommands"] = "Comandos:",

    ["AverageItemLevel"] = "iLvl méd.",
    ["Equipment"] = "Equipamento",
    ["Currencies"] = "Moedas",
    ["Ratings"] = "Classificações",
    ["WeeklyShort"] = "Sem.",
    ["SeasonShort"] = "Tem.",
    ["WinRate"] = "Taxa de vitórias",
    ["AccountHonor"] = "Honra da conta",
    ["Enchant"] = "Encantamento",
    ["Gem"] = "Gema",

    ["LeftClickToggle"] = "Clique esq.: alternar janela",
    ["RightClickDebug"] = "Clique dir.: alternar depuração",
    ["DragToReposition"] = "Arrastar: reposicionar",
    ["MinimapShown"] = "Botão do minimapa exibido.",
    ["MinimapHidden"] = "Botão do minimapa oculto.",
    ["ScaleLabel"] = "Escala  %.2f",
    ["ScaleSet"] = "Escala definida em %.2f",
    ["Minimap"] = "Minimapa",
    ["ResetConfirmDialog"] = "Apagar todos os dados de personagens do PvPster?",
    ["Theme"] = "Tema",
    ["ThemeSet"] = "Tema: %s",

    ["Language"] = "Idioma",
    ["LocaleCurrent"] = "Idioma: %s (ativo: %s)",
    ["LocaleSupported"] = "Suportados:",
    ["LocaleSet"] = "Idioma alterado para %s.",
    ["LocaleUnsupported"] = "Idioma não suportado.",

    ["Slot_Head"] = "Cabeça",
    ["Slot_Neck"] = "Pescoço",
    ["Slot_Shoulder"] = "Ombros",
    ["Slot_Chest"] = "Peito",
    ["Slot_Waist"] = "Cintura",
    ["Slot_Legs"] = "Pernas",
    ["Slot_Feet"] = "Pés",
    ["Slot_Wrist"] = "Pulsos",
    ["Slot_Hands"] = "Mãos",
    ["Slot_Finger1"] = "Anel 1",
    ["Slot_Finger2"] = "Anel 2",
    ["Slot_Trinket1"] = "Berloque 1",
    ["Slot_Trinket2"] = "Berloque 2",
    ["Slot_Back"] = "Costas",
    ["Slot_MainHand"] = "Mão direita",
    ["Slot_OffHand"] = "Mão esquerda",

    ["EnchantStat_7969"] = "+? Maestria",
    ["EnchantStat_7973"] = "+? Velocidade de Movimento",
    ["EnchantStat_7991"] = "+? Velocidade de Movimento",
    ["EnchantStat_8013"] = "+? Intelecto / +? Mana Máx.",
    ["EnchantStat_8019"] = "+? Velocidade de Movimento / +? Vida",
    ["EnchantStat_8039"] = "Acertos de magia concedem Acuidade dos Ren'dorei",
}
