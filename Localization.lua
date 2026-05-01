--[[
    PvPster Localization
    enUS (default) + koKR
]]

local _, PvPster = ...


-- Lua API Localization
local pairs = pairs
local setmetatable = setmetatable

-- WoW API Localization
local GetLocale = GetLocale


local L = {}
PvPster.L = L


local LOCALES = {}


LOCALES["enUS"] = {
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
}


LOCALES["koKR"] = {
    ["PvPster"] = "PvPster",
    ["Sync"] = "동기화",
    ["Show"] = "열기",
    ["Hide"] = "닫기",
    ["Reset"] = "초기화",
    ["Help"] = "도움말",
    ["Close"] = "닫기",

    ["Name"] = "이름",
    ["Realm"] = "서버",
    ["Level"] = "Lv",
    ["iLvl"] = "iLvl",
    ["Honor"] = "명예",
    ["Conquest"] = "정복",
    ["BRACKET_2V2"] = "2v2",
    ["BRACKET_3V3"] = "3v3",
    ["BRACKET_SHUFFLE"] = "1인전",
    ["BRACKET_BLITZ"] = "대공세",
    ["LastSeen"] = "갱신",

    ["NoCharactersTitle"] = "아직 수집된 캐릭터 데이터가 없습니다",
    ["NoCharactersBody"] = "각 캐릭터로 한 번씩 로그인해주세요.",

    ["LastSync"] = "마지막 갱신: %s",
    ["JustNow"] = "방금 전",
    ["MinutesAgo"] = "%d분 전",
    ["HoursAgo"] = "%d시간 전",
    ["DaysAgo"] = "%d일 전",

    ["DataResetConfirm"] = "전체 데이터를 삭제하려면 /pvpster reset confirm 을 입력하세요.",
    ["DataReset"] = "전체 캐릭터 데이터가 삭제되었습니다.",
    ["SyncDone"] = "%s 동기화 완료.",
    ["DebugOn"] = "디버그 로그가 활성화되었습니다.",
    ["DebugOff"] = "디버그 로그가 비활성화되었습니다.",
    ["UnknownCommand"] = "알 수 없는 명령입니다. /pvpster help 를 입력해보세요.",
    ["HelpCommands"] = "명령어:",

    ["AverageItemLevel"] = "평균 iLvl",
    ["Equipment"] = "장비",
    ["Currencies"] = "화폐",
    ["Ratings"] = "레이팅",
    ["WeeklyShort"] = "주간",
    ["SeasonShort"] = "시즌",
    ["WinRate"] = "승률",
    ["WinLossRecord"] = "%sW %sL",
    ["AccountHonor"] = "계정 명예",
    ["Enchant"] = "마법부여",
    ["Gem"] = "보석",

    ["LeftClickToggle"] = "좌클릭: 창 토글",
    ["RightClickDebug"] = "우클릭: 디버그 토글",
    ["DragToReposition"] = "드래그: 위치 이동",
    ["MinimapShown"] = "미니맵 아이콘이 표시됩니다.",
    ["MinimapHidden"] = "미니맵 아이콘이 숨겨졌습니다.",
    ["ScaleLabel"] = "크기  %.2f",
    ["ScaleSet"] = "크기 %.2f 적용",
    ["Minimap"] = "미니맵",
    ["ResetConfirmDialog"] = "PvPster 캐릭터 데이터를 전부 삭제할까요?",
    ["Theme"] = "테마",
    ["ThemeSet"] = "테마: %s",

    ["Slot_Head"] = "머리",
    ["Slot_Neck"] = "목",
    ["Slot_Shoulder"] = "어깨",
    ["Slot_Chest"] = "가슴",
    ["Slot_Waist"] = "허리",
    ["Slot_Legs"] = "다리",
    ["Slot_Feet"] = "발",
    ["Slot_Wrist"] = "손목",
    ["Slot_Hands"] = "손",
    ["Slot_Finger1"] = "반지 1",
    ["Slot_Finger2"] = "반지 2",
    ["Slot_Trinket1"] = "장신구 1",
    ["Slot_Trinket2"] = "장신구 2",
    ["Slot_Back"] = "등",
    ["Slot_MainHand"] = "주무기",
    ["Slot_OffHand"] = "보조무기",
}


local locale = GetLocale and GetLocale() or "enUS"
local source = LOCALES[locale] or LOCALES["enUS"]

for key, value in pairs(source) do
    L[key] = value
end

-- Fallback to key when missing
setmetatable(L, {
    __index = function(_, key) return key end,
})
