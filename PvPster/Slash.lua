--[[
    PvPster Slash Commands
    /pvpster, /pvps
]]

local _, PvPster = ...


-- Lua API Localization
local string = string

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
    chatPrint("  /pvpster help")
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
