--[[
    PvPster Core
    진입점, 이벤트 등록, 모듈 초기화
]]

local addonName, PvPster = ...


-- WoW API Localization
local CreateFrame = CreateFrame
local C_AddOns = C_AddOns


-- Expose globally for debug/console access
_G.PvPster = PvPster


PvPster.Version = (C_AddOns and C_AddOns.GetAddOnMetadata)
        and C_AddOns.GetAddOnMetadata(addonName, "Version")
        or "0.0.1"


local Core = {}
PvPster.Core = Core


local handlers = {}


handlers.ADDON_LOADED = function(loadedName)
    if loadedName ~= addonName then return end

    PvPster.Logger:Initialize()
    PvPster.DB:Initialize()
    PvPster.Localization:Apply(PvPster.DB:GetUIState().locale)
    PvPster.Collector:Initialize()
    PvPster.UI:Initialize()
    PvPster.Minimap:Initialize()
    PvPster.Slash:Initialize()

    PvPster.Logger:Log("Core", "Addon loaded v" .. PvPster.Version)
end


handlers.PLAYER_LOGIN = function()
    if RequestRatedInfo then RequestRatedInfo() end
    if RequestPVPRewards then RequestPVPRewards() end
end


handlers.PLAYER_ENTERING_WORLD = function()
    PvPster.Collector:OnEnteringWorld()
end


handlers.PVP_RATED_STATS_UPDATE = function()
    PvPster.Collector:UpdateRatings()
end


handlers.CURRENCY_DISPLAY_UPDATE = function()
    PvPster.Collector:UpdateCurrencies()
end


handlers.PLAYER_EQUIPMENT_CHANGED = function()
    PvPster.Collector:UpdateEquipment()
end


handlers.PLAYER_AVG_ITEM_LEVEL_UPDATE = function()
    PvPster.Collector:UpdateEquipment()
end


handlers.PLAYER_LEVEL_UP = function()
    PvPster.Collector:UpdateCharacter()
end


handlers.PLAYER_LOGOUT = function()
    PvPster.Collector:RunFullSync()
end


local function onEvent(self, event, ...)
    local handler = handlers[event]
    if handler then
        handler(...)
    end
end


local eventFrame = CreateFrame("Frame", "PvPsterEventFrame")
eventFrame:SetScript("OnEvent", onEvent)
for event in pairs(handlers) do
    eventFrame:RegisterEvent(event)
end
