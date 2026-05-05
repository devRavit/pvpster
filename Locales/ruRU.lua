--[[
    PvPster Locale: ruRU (Русский)
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


local KEY = "ruRU"
table.insert(PvPster.LOCALE_REGISTRY.order, KEY)
PvPster.LOCALE_REGISTRY.names[KEY] = "Русский"
PvPster.LOCALE_REGISTRY.strings[KEY] = {
    ["Sync"] = "Синхр.",
    ["Show"] = "Показать",
    ["Hide"] = "Скрыть",
    ["Reset"] = "Сброс",
    ["Help"] = "Помощь",
    ["Close"] = "Закрыть",

    ["Name"] = "Имя",
    ["Realm"] = "Сервер",
    ["Level"] = "Ур.",
    ["Honor"] = "Честь",
    ["Conquest"] = "Завоевание",
    ["BRACKET_BLITZ"] = "Блиц",
    ["LastSeen"] = "Обнов.",

    ["NoCharactersTitle"] = "Данные персонажей отсутствуют",
    ["NoCharactersBody"] = "Войдите в игру каждым персонажем, чтобы заполнить список.",

    ["LastSync"] = "Последняя синхр.: %s",
    ["JustNow"] = "только что",
    ["MinutesAgo"] = "%d мин назад",
    ["HoursAgo"] = "%d ч назад",
    ["DaysAgo"] = "%d дн назад",

    ["DataResetConfirm"] = "Введите /pvpster reset confirm для удаления всех данных.",
    ["DataReset"] = "Все данные персонажей удалены.",
    ["SyncDone"] = "%s синхронизирован.",
    ["DebugOn"] = "Отладочный журнал включён.",
    ["DebugOff"] = "Отладочный журнал выключён.",
    ["UnknownCommand"] = "Неизвестная команда. Попробуйте /pvpster help.",
    ["HelpCommands"] = "Команды:",

    ["AverageItemLevel"] = "Ср. ур. предм.",
    ["Equipment"] = "Снаряжение",
    ["Currencies"] = "Валюты",
    ["Ratings"] = "Рейтинги",
    ["WeeklyShort"] = "Нед.",
    ["SeasonShort"] = "Сез.",
    ["WinRate"] = "Процент побед",
    ["AccountHonor"] = "Честь учётной записи",
    ["Enchant"] = "Чары",
    ["Gem"] = "Самоцвет",

    ["LeftClickToggle"] = "ЛКМ: показать/скрыть окно",
    ["RightClickDebug"] = "ПКМ: переключить отладку",
    ["DragToReposition"] = "Перетащить: изменить положение",
    ["MinimapShown"] = "Кнопка миникарты показана.",
    ["MinimapHidden"] = "Кнопка миникарты скрыта.",
    ["ScaleLabel"] = "Масштаб  %.2f",
    ["ScaleSet"] = "Масштаб установлен на %.2f",
    ["Minimap"] = "Миникарта",
    ["ResetConfirmDialog"] = "Удалить все данные персонажей PvPster?",
    ["Theme"] = "Тема",
    ["ThemeSet"] = "Тема: %s",

    ["Language"] = "Язык",
    ["LocaleAuto"] = "Авто",
    ["LocaleCurrent"] = "Язык: %s (активен: %s)",
    ["LocaleSupported"] = "Поддерживаемые:",
    ["LocaleSet"] = "Язык изменён на %s.",
    ["LocaleUnsupported"] = "Неподдерживаемый язык.",

    ["Slot_Head"] = "Голова",
    ["Slot_Neck"] = "Шея",
    ["Slot_Shoulder"] = "Плечи",
    ["Slot_Chest"] = "Грудь",
    ["Slot_Waist"] = "Пояс",
    ["Slot_Legs"] = "Ноги",
    ["Slot_Feet"] = "Ступни",
    ["Slot_Wrist"] = "Запястья",
    ["Slot_Hands"] = "Кисти",
    ["Slot_Finger1"] = "Кольцо 1",
    ["Slot_Finger2"] = "Кольцо 2",
    ["Slot_Trinket1"] = "Аксессуар 1",
    ["Slot_Trinket2"] = "Аксессуар 2",
    ["Slot_Back"] = "Спина",
    ["Slot_MainHand"] = "Правая рука",
    ["Slot_OffHand"] = "Левая рука",

    ["StateOn"] = "ВКЛ",
    ["StateOff"] = "ВЫКЛ",

    ["EnchantStat_7969"] = "+? искусность",
    ["EnchantStat_7973"] = "+? скорость передвижения",
    ["EnchantStat_7991"] = "+? скорость передвижения",
    ["EnchantStat_8013"] = "+? интеллект / +? макс. мана",
    ["EnchantStat_8019"] = "+? скорость передвижения / +? здоровье",
    ["EnchantStat_8039"] = "Заклинания дают «Остроту рен'дорай»",
}
