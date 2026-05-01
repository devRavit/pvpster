--[[
    PvPster Minimap
    미니맵 버튼 — 좌클릭 창 토글, 우클릭 디버그 토글, 드래그로 미니맵 가장자리 이동
]]

local _, PvPster = ...


-- Lua API Localization
local math = math
local tostring = tostring

-- WoW API Localization
local CreateFrame = CreateFrame
local C_Timer = C_Timer
local GetCursorPosition = GetCursorPosition
local MinimapFrame = Minimap
local GameTooltip = GameTooltip
local DEFAULT_CHAT_FRAME = DEFAULT_CHAT_FRAME


local Logger = PvPster.Logger
local DB = PvPster.DB
local L = PvPster.L


local MinimapModule = {}
PvPster.Minimap = MinimapModule


local minimapButton
local hideTimer
local DEFAULT_ANGLE = 225
local EDGE_PADDING = 6
local HIDE_DELAY = 0.3


local function getAngle()
    local ui = DB:GetUIState()
    return ui.minimapAngle or DEFAULT_ANGLE
end


local function isHoverEnabled()
    local ui = DB:GetUIState()
    local v = ui.minimapVisible
    if v == nil then return true end
    return v
end


local function cancelHideTimer()
    if hideTimer then
        hideTimer:Cancel()
        hideTimer = nil
    end
end


local function shouldRemainVisible()
    if not minimapButton then return false end
    return MinimapFrame:IsMouseOver() or minimapButton:IsMouseOver()
end


local function checkAndHide()
    hideTimer = nil
    if not minimapButton then return end
    if shouldRemainVisible() then return end
    minimapButton:Hide()
end


local function scheduleHide()
    cancelHideTimer()
    hideTimer = C_Timer.NewTimer(HIDE_DELAY, checkAndHide)
end


local function showOnHover()
    if not minimapButton then return end
    if not isHoverEnabled() then return end
    cancelHideTimer()
    minimapButton:Show()
end


local function getRadius()
    local size = MinimapFrame:GetWidth()
    if not size or size <= 0 then return 80 end
    return (size / 2) + EDGE_PADDING
end


local function applyPositionByAngle(button, angle)
    local rad = math.rad(angle)
    local radius = getRadius()
    local x = radius * math.cos(rad)
    local y = radius * math.sin(rad)
    button:ClearAllPoints()
    button:SetPoint("CENTER", MinimapFrame, "CENTER", x, y)
end


local function onDragMove(button)
    local mx, my = MinimapFrame:GetCenter()
    if not mx then return end
    local scale = MinimapFrame:GetEffectiveScale()
    local px, py = GetCursorPosition()
    px = px / scale
    py = py / scale
    local angle = math.deg(math.atan2(py - my, px - mx))
    DB:SaveUIState("minimapAngle", angle)
    applyPositionByAngle(button, angle)
end


local function showButtonTooltip(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("PvPster")
    GameTooltip:AddLine(L["LeftClickToggle"], 1, 1, 1)
    GameTooltip:AddLine(L["RightClickDebug"], 1, 1, 1)
    GameTooltip:AddLine(L["DragToReposition"], 0.7, 0.7, 0.7)
    GameTooltip:Show()
end


function MinimapModule:Initialize()
    if minimapButton then return end

    minimapButton = CreateFrame("Button", "PvPsterMinimapButton", MinimapFrame)
    minimapButton:SetSize(32, 32)
    minimapButton:SetFrameStrata("MEDIUM")
    minimapButton:SetFrameLevel(8)

    local icon = minimapButton:CreateTexture(nil, "BACKGROUND")
    icon:SetTexture("Interface\\Icons\\Achievement_Bg_Winsoa")
    icon:SetSize(20, 20)
    icon:SetPoint("CENTER", 0, 0)
    icon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask")

    local border = minimapButton:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetSize(54, 54)
    border:SetPoint("TOPLEFT", -1, 1)

    minimapButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    minimapButton:SetScript("OnClick", function(self, button)
        if button == "RightButton" then
            local enabled = not Logger:IsDebug()
            Logger:SetDebug(enabled)
            DEFAULT_CHAT_FRAME:AddMessage(
                "|cff5599ff[PvPster]|r " .. (enabled and L["DebugOn"] or L["DebugOff"])
            )
        else
            PvPster.UI:Toggle()
        end
    end)

    minimapButton:SetMovable(true)
    minimapButton:RegisterForDrag("LeftButton")
    minimapButton:SetScript("OnDragStart", function(self)
        self:LockHighlight()
        self:SetScript("OnUpdate", function() onDragMove(self) end)
    end)
    minimapButton:SetScript("OnDragStop", function(self)
        self:UnlockHighlight()
        self:SetScript("OnUpdate", nil)
    end)

    minimapButton:SetScript("OnEnter", function(self)
        cancelHideTimer()
        showButtonTooltip(self)
    end)
    minimapButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
        scheduleHide()
    end)

    MinimapFrame:HookScript("OnEnter", showOnHover)
    MinimapFrame:HookScript("OnLeave", scheduleHide)

    applyPositionByAngle(minimapButton, getAngle())
    self:UpdateVisibility()

    Logger:Log("Minimap", "Initialized")
end


function MinimapModule:UpdateVisibility()
    if not minimapButton then return end
    -- Hover-only: button starts hidden and shows when cursor enters minimap.
    -- minimapVisible controls whether hover-display is enabled at all.
    minimapButton:Hide()
    cancelHideTimer()
end


function MinimapModule:Toggle()
    local ui = DB:GetUIState()
    local current = ui.minimapVisible
    if current == nil then current = true end
    local newState = not current
    DB:SaveUIState("minimapVisible", newState)
    self:UpdateVisibility()

    if PvPster.UI and PvPster.UI.RefreshMinimapButton then
        PvPster.UI:RefreshMinimapButton()
    end

    DEFAULT_CHAT_FRAME:AddMessage(
        "|cff5599ff[PvPster]|r " .. (newState and L["MinimapShown"] or L["MinimapHidden"])
    )
    Logger:Log("Minimap", "Visibility: " .. tostring(newState))
end
