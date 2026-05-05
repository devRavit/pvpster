--[[
    PvPster Locale: zhCN (简体中文)
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


local KEY = "zhCN"
table.insert(PvPster.LOCALE_REGISTRY.order, KEY)
PvPster.LOCALE_REGISTRY.names[KEY] = "简体中文"
PvPster.LOCALE_REGISTRY.strings[KEY] = {
    ["Sync"] = "同步",
    ["Show"] = "显示",
    ["Hide"] = "隐藏",
    ["Reset"] = "重置",
    ["Help"] = "帮助",
    ["Close"] = "关闭",

    ["Name"] = "姓名",
    ["Realm"] = "服务器",
    ["Level"] = "等",
    ["Honor"] = "荣誉",
    ["Conquest"] = "征服",
    ["BRACKET_SHUFFLE"] = "乱斗",
    ["BRACKET_BLITZ"] = "闪电战",
    ["LastSeen"] = "更新",

    ["NoCharactersTitle"] = "暂无角色数据",
    ["NoCharactersBody"] = "请使用每个角色登录一次以填充此列表。",

    ["LastSync"] = "上次同步：%s",
    ["JustNow"] = "刚刚",
    ["MinutesAgo"] = "%d 分钟前",
    ["HoursAgo"] = "%d 小时前",
    ["DaysAgo"] = "%d 天前",

    ["DataResetConfirm"] = "输入 /pvpster reset confirm 清除所有角色数据。",
    ["DataReset"] = "所有角色数据已清除。",
    ["SyncDone"] = "%s 同步完成。",
    ["DebugOn"] = "调试日志已启用。",
    ["DebugOff"] = "调试日志已禁用。",
    ["UnknownCommand"] = "未知命令。请尝试 /pvpster help。",
    ["HelpCommands"] = "命令：",

    ["AverageItemLevel"] = "平均装等",
    ["Equipment"] = "装备",
    ["Currencies"] = "货币",
    ["Ratings"] = "评分",
    ["WeeklyShort"] = "周",
    ["SeasonShort"] = "赛季",
    ["WinRate"] = "胜率",
    ["AccountHonor"] = "战网荣誉",
    ["Enchant"] = "附魔",
    ["Gem"] = "宝石",

    ["LeftClickToggle"] = "左键：切换窗口",
    ["RightClickDebug"] = "右键：切换调试",
    ["DragToReposition"] = "拖动：调整位置",
    ["MinimapShown"] = "小地图按钮已显示。",
    ["MinimapHidden"] = "小地图按钮已隐藏。",
    ["ScaleLabel"] = "缩放  %.2f",
    ["ScaleSet"] = "缩放已设置为 %.2f",
    ["Minimap"] = "小地图",
    ["ResetConfirmDialog"] = "清除所有 PvPster 角色数据？",
    ["Theme"] = "主题",
    ["ThemeSet"] = "主题:%s",

    ["Language"] = "语言",
    ["LocaleAuto"] = "自动",
    ["LocaleCurrent"] = "语言:%s(生效:%s)",
    ["LocaleSupported"] = "支持的语言:",
    ["LocaleSet"] = "语言已设置为 %s。",
    ["LocaleUnsupported"] = "不支持的语言。",

    ["Slot_Head"] = "头部",
    ["Slot_Neck"] = "颈部",
    ["Slot_Shoulder"] = "肩部",
    ["Slot_Chest"] = "胸甲",
    ["Slot_Waist"] = "腰部",
    ["Slot_Legs"] = "腿部",
    ["Slot_Feet"] = "脚",
    ["Slot_Wrist"] = "手腕",
    ["Slot_Hands"] = "手",
    ["Slot_Finger1"] = "戒指 1",
    ["Slot_Finger2"] = "戒指 2",
    ["Slot_Trinket1"] = "饰品 1",
    ["Slot_Trinket2"] = "饰品 2",
    ["Slot_Back"] = "背部",
    ["Slot_MainHand"] = "主手",
    ["Slot_OffHand"] = "副手",

    ["StateOn"] = "开",
    ["StateOff"] = "关",

    ["EnchantStat_7969"] = "+? 精通",
    ["EnchantStat_7973"] = "+? 移动速度",
    ["EnchantStat_7991"] = "+? 移动速度",
    ["EnchantStat_8013"] = "+? 智力 / +? 法力上限",
    ["EnchantStat_8019"] = "+? 移动速度 / +? 生命值",
    ["EnchantStat_8039"] = "法术命中时获得伦多雷敏锐",
}
