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


local function showHelp()
    chatPrint(L["HelpCommands"])
    chatPrint("  /pvpster — " .. L["Show"] .. " / " .. L["Hide"])
    chatPrint("  /pvpster show")
    chatPrint("  /pvpster hide")
    chatPrint("  /pvpster sync — " .. L["Sync"])
    chatPrint("  /pvpster reset — " .. L["Reset"])
    chatPrint("  /pvpster debug on|off")
    chatPrint("  /pvpster lang [auto|enUS|koKR] — " .. L["Language"])
    chatPrint("  /pvpster help")
end


-- WoW locale codes are case-sensitive (enUS, koKR). Accept lowercase input
-- for ergonomics and normalize back to the canonical casing.
local LOCALE_ALIASES = {
    auto = "auto",
    enus = "enUS",
    kokr = "koKR",
}


local function normalizeLocaleArg(input)
    local lowered = (input or ""):lower()
    return LOCALE_ALIASES[lowered] or input
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
        if arg == "" then
            local saved = PvPster.DB:GetUIState().locale or "auto"
            local effective = Localization:Resolve(saved)
            chatPrint(string.format(L["LocaleCurrent"], saved, effective))
            local supported = { "auto" }
            for _, entry in ipairs(Localization:GetSupportedLocales()) do
                table.insert(supported, entry.key)
            end
            chatPrint(L["LocaleSupported"] .. " " .. table.concat(supported, ", "))
            return
        end

        local normalized = normalizeLocaleArg(arg)
        if not Localization:IsSupported(normalized) then
            chatPrint(L["LocaleUnsupported"])
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
