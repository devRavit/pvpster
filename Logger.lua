--[[
    PvPster Logger
    SavedVariables-based logging (PvPsterLogs)
    print() 직접 호출 금지 — 모든 로그는 이 모듈을 통해
]]

local _, PvPster = ...


-- Lua API Localization
local table = table
local string = string
local pcall = pcall
local date = date

-- WoW API Localization
local DEFAULT_CHAT_FRAME = DEFAULT_CHAT_FRAME


local Logger = {}
PvPster.Logger = Logger


local MAX_LOGS = 500


local function getTimestamp()
    return date and date("%Y-%m-%d %H:%M:%S") or "NODATE"
end


function Logger:Initialize()
    if not _G.PvPsterLogs then
        _G.PvPsterLogs = {
            debugEnabled = false,
            entries = {},
        }
    end
    if not _G.PvPsterLogs.entries then
        _G.PvPsterLogs.entries = {}
    end
end


function Logger:Log(module, message)
    if not _G.PvPsterLogs or not _G.PvPsterLogs.entries then return end

    local entry = string.format(
        "[%s] [%s] %s",
        getTimestamp(),
        module or "Unknown",
        message or ""
    )

    pcall(function()
        table.insert(_G.PvPsterLogs.entries, entry)
    end)

    if #_G.PvPsterLogs.entries > MAX_LOGS then
        table.remove(_G.PvPsterLogs.entries, 1)
    end
end


function Logger:Debug(module, message)
    self:Log(module, message)
    if _G.PvPsterLogs and _G.PvPsterLogs.debugEnabled then
        DEFAULT_CHAT_FRAME:AddMessage(string.format(
            "|cff5599ff[PvPster]|r %s: %s",
            module or "?",
            message or ""
        ))
    end
end


function Logger:SetDebug(enabled)
    if not _G.PvPsterLogs then return end
    _G.PvPsterLogs.debugEnabled = enabled and true or false
end


function Logger:IsDebug()
    return _G.PvPsterLogs and _G.PvPsterLogs.debugEnabled or false
end


function Logger:Clear()
    if _G.PvPsterLogs then
        _G.PvPsterLogs.entries = {}
    end
end


function Logger:GetEntries()
    return _G.PvPsterLogs and _G.PvPsterLogs.entries or {}
end
