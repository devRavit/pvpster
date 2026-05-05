--[[
    PvPster Locale: koKR (한국어)
    Keys missing from this table fall back to enUS via Localization.lua's
    per-key merge.
]]

local _, PvPster = ...

PvPster.LOCALE_REGISTRY = PvPster.LOCALE_REGISTRY or {
    strings = {},
    names = {},
    order = {},
}


local KEY = "koKR"
table.insert(PvPster.LOCALE_REGISTRY.order, KEY)
PvPster.LOCALE_REGISTRY.names[KEY] = "한국어"
PvPster.LOCALE_REGISTRY.strings[KEY] = {
    ["Sync"] = "동기화",
    ["Show"] = "열기",
    ["Hide"] = "닫기",
    ["Reset"] = "초기화",
    ["Help"] = "도움말",
    ["Close"] = "닫기",

    ["Name"] = "이름",
    ["Realm"] = "서버",
    ["Honor"] = "명예",
    ["Conquest"] = "정복",
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

    ["Language"] = "언어",
    ["LocaleAuto"] = "자동",
    ["LocaleCurrent"] = "언어 설정: %s (적용: %s)",
    ["LocaleSupported"] = "지원 목록:",
    ["LocaleSet"] = "언어를 %s 로 변경했습니다.",
    ["LocaleUnsupported"] = "지원하지 않는 언어입니다.",

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

    ["StateOn"] = "켜짐",
    ["StateOff"] = "꺼짐",

    ["EnchantStat_7969"] = "+? 특화",
    ["EnchantStat_7973"] = "+? 이동 속도",
    ["EnchantStat_7991"] = "+? 이동 속도",
    ["EnchantStat_8013"] = "+? 지능 / +? 최대 마나",
    ["EnchantStat_8019"] = "+? 이동 속도 / +? 체력",
    ["EnchantStat_8039"] = "주문 적중 시 공허의 위력 부여",
}
