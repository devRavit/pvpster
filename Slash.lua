--[[
    PvPster Slash Commands
    /pvpster, /pvps
]]

local _, PvPster = ...


-- Lua API Localization
local string = string
local table = table
local ipairs = ipairs

-- WoW API Localization
local DEFAULT_CHAT_FRAME = DEFAULT_CHAT_FRAME


local L = PvPster.L
local Logger = PvPster.Logger


local Slash = {}
PvPster.Slash = Slash


local function chatPrint(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cff5599ff[PvPster]|r " .. (message or ""))
end


-- Build the "auto|enUS|koKR|..." segment from the supported-locale list so
-- adding a new locale to Localization.lua propagates to the help text and
-- lowercase alias map automatically.
local function listSupportedLocaleKeys()
    local keys = { "auto" }
    for _, entry in ipairs(PvPster.Localization:GetSupportedLocales()) do
        keys[#keys + 1] = entry.key
    end
    return keys
end


local function showHelp()
    chatPrint(L["HelpCommands"])
    chatPrint("  /pvpster — " .. L["Show"] .. " / " .. L["Hide"])
    chatPrint("  /pvpster show")
    chatPrint("  /pvpster hide")
    chatPrint("  /pvpster sync — " .. L["Sync"])
    chatPrint("  /pvpster reset — " .. L["Reset"])
    chatPrint("  /pvpster debug on|off")
    chatPrint(string.format(
        "  /pvpster lang [%s] — %s",
        table.concat(listSupportedLocaleKeys(), "|"),
        L["Language"]
    ))
    chatPrint("  /pvpster help")
end


-- WoW locale codes are case-sensitive (enUS, koKR). Accept lowercase input
-- for ergonomics and normalize back to the canonical casing. Built lazily
-- from SUPPORTED_LOCALES so new locales don't need a manual entry here.
local function normalizeLocaleArg(input)
    local lowered = (input or ""):lower()
    if lowered == "auto" then return "auto" end
    for _, entry in ipairs(PvPster.Localization:GetSupportedLocales()) do
        if entry.key:lower() == lowered then
            return entry.key
        end
    end
    return input
end


local commandHandlers = {
    [""] = function()
        PvPster.UI:Toggle()
    end,
    show = function()
        PvPster.UI:Show()
    end,
    hide = function()
        PvPster.UI:Hide()
    end,
    sync = function()
        PvPster.Collector:RunFullSync()
        local key = PvPster.DB:GetCharacterKey()
        chatPrint(string.format(L["SyncDone"], key))
    end,
    reset = function(arg)
        if arg == "confirm" then
            PvPster.DB:Reset()
            chatPrint(L["DataReset"])
            PvPster.UI:Refresh()
        else
            chatPrint(L["DataResetConfirm"])
        end
    end,
    debug = function(arg)
        if arg == "on" then
            Logger:SetDebug(true)
            chatPrint(L["DebugOn"])
        elseif arg == "off" then
            Logger:SetDebug(false)
            chatPrint(L["DebugOff"])
        else
            chatPrint("usage: /pvpster debug on|off")
        end
    end,
    minimap = function()
        if PvPster.Minimap and PvPster.Minimap.Toggle then
            PvPster.Minimap:Toggle()
        else
            chatPrint("Minimap module is not loaded yet.")
        end
    end,
    scale = function(arg)
        local value = tonumber(arg)
        if not value then
            local current = PvPster.DB:GetUIState().uiScale or 1.0
            chatPrint(string.format(L["ScaleLabel"], current))
            return
        end
        PvPster.UI:ApplyScale(value)
        chatPrint(string.format(L["ScaleSet"], value))
    end,
    lang = function(arg)
        local Localization = PvPster.Localization
        local supportedList = table.concat(listSupportedLocaleKeys(), ", ")

        if arg == "" then
            local saved = PvPster.DB:GetUIState().locale or "auto"
            local effective = Localization:Resolve(saved)
            chatPrint(string.format(L["LocaleCurrent"], saved, effective))
            chatPrint(L["LocaleSupported"] .. " " .. supportedList)
            return
        end

        local normalized = normalizeLocaleArg(arg)
        if not Localization:IsSupported(normalized) then
            chatPrint(L["LocaleUnsupported"])
            chatPrint(L["LocaleSupported"] .. " " .. supportedList)
            return
        end

        PvPster.DB:SaveUIState("locale", normalized)
        Localization:Apply(normalized)
        if PvPster.UI and PvPster.UI.RefreshLocalizedText then
            PvPster.UI:RefreshLocalizedText()
        end
        chatPrint(string.format(L["LocaleSet"], normalized))
    end,
    help = showHelp,
}


local function dispatch(input)
    input = (input or ""):match("^%s*(.-)%s*$") or ""
    local command, rest = input:match("^(%S*)%s*(.*)$")
    command = (command or ""):lower()
    rest = (rest or ""):match("^%s*(.-)%s*$") or ""

    local handler = commandHandlers[command]
    if handler then
        handler(rest)
    else
        chatPrint(L["UnknownCommand"])
    end
end


function Slash:Initialize()
    SLASH_PVPSTER1 = "/pvpster"
    SLASH_PVPSTER2 = "/pvps"
    SlashCmdList["PVPSTER"] = dispatch
    Logger:Log("Slash", "Registered /pvpster, /pvps")
end
