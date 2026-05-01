--[[
    PvPster Theme
    Modern web-style themes — GitHub Dark / Discord
    Replaces Blizzard's stone-textured backdrop with flat solid colors.
]]

local _, PvPster = ...


-- Lua API Localization
local pairs = pairs
local unpack = unpack

-- WoW API Localization
local CreateFrame = CreateFrame


local Theme = {}
PvPster.Theme = Theme


local PALETTE = {
    name = "GitHub Dark",
    background     = { 13/255,  17/255,  23/255, 0.97 },
    headerBg       = { 22/255,  27/255,  34/255, 1.0  },
    border         = { 48/255,  54/255,  61/255, 1.0  },
    separator      = { 48/255,  54/255,  61/255, 0.6  },
    rowHover       = { 1.0,     1.0,     1.0,    0.04 },
    rowAlt         = { 1.0,     1.0,     1.0,    0.02 },
    text           = { 201/255, 209/255, 217/255, 1.0 },
    textSecondary  = { 139/255, 148/255, 158/255, 1.0 },
    textDim        = { 110/255, 118/255, 129/255, 1.0 },
    accent         = { 88/255,  166/255, 255/255, 1.0 },
    accentDim      = { 88/255,  166/255, 255/255, 0.6 },
    success        = { 86/255,  211/255, 100/255, 1.0 },
    warning        = { 219/255, 109/255,  40/255, 1.0 },
    danger         = { 248/255,  81/255,  73/255, 1.0 },
    buttonBg       = { 33/255,  38/255,  45/255, 1.0  },
    buttonBgHover  = { 48/255,  54/255,  61/255, 1.0  },
}


function Theme:GetCurrent()
    return PALETTE
end


-- Apply solid background + 1px borders to a frame.
-- Reuses textures across calls so it's safe to call repeatedly on theme switch.
function Theme:ApplyFrameBackground(frame, palette)
    palette = palette or self:GetCurrent()

    if not frame.themeBg then
        frame.themeBg = frame:CreateTexture(nil, "BACKGROUND", nil, -7)
        frame.themeBg:SetAllPoints(frame)
    end
    frame.themeBg:SetColorTexture(unpack(palette.background))

    if not frame.themeBorders then
        local borders = {}
        local function makeEdge(point1, point2, isHorizontal)
            local t = frame:CreateTexture(nil, "BORDER")
            t:SetPoint(point1, frame, point1, 0, 0)
            t:SetPoint(point2, frame, point2, 0, 0)
            if isHorizontal then
                t:SetHeight(1)
            else
                t:SetWidth(1)
            end
            return t
        end
        borders.top    = makeEdge("TOPLEFT", "TOPRIGHT", true)
        borders.bottom = makeEdge("BOTTOMLEFT", "BOTTOMRIGHT", true)
        borders.left   = makeEdge("TOPLEFT", "BOTTOMLEFT", false)
        borders.right  = makeEdge("TOPRIGHT", "BOTTOMRIGHT", false)
        frame.themeBorders = borders
    end
    for _, edge in pairs(frame.themeBorders) do
        edge:SetColorTexture(unpack(palette.border))
    end
end


-- Apply theme styling to a button (replaces Blizzard textures with flat colors).
function Theme:ApplyButton(button, palette)
    palette = palette or self:GetCurrent()

    -- Strip Blizzard textures
    if button.SetNormalTexture then button:SetNormalTexture("") end
    if button.SetHighlightTexture then button:SetHighlightTexture("") end
    if button.SetPushedTexture then button:SetPushedTexture("") end
    if button.SetDisabledTexture then button:SetDisabledTexture("") end

    -- Custom flat background
    if not button.themeBg then
        button.themeBg = button:CreateTexture(nil, "BACKGROUND")
        button.themeBg:SetAllPoints(button)
    end
    button.themeBg:SetColorTexture(unpack(palette.buttonBg))

    if not button.themeHover then
        button.themeHover = button:CreateTexture(nil, "BACKGROUND", nil, 1)
        button.themeHover:SetAllPoints(button)
        button.themeHover:Hide()
    end
    button.themeHover:SetColorTexture(unpack(palette.buttonBgHover))

    if not button.themeBorder then
        button.themeBorder = {}
        local function makeEdge(point1, point2, isHorizontal)
            local t = button:CreateTexture(nil, "BORDER")
            t:SetPoint(point1, button, point1, 0, 0)
            t:SetPoint(point2, button, point2, 0, 0)
            if isHorizontal then t:SetHeight(1) else t:SetWidth(1) end
            return t
        end
        button.themeBorder.top    = makeEdge("TOPLEFT", "TOPRIGHT", true)
        button.themeBorder.bottom = makeEdge("BOTTOMLEFT", "BOTTOMRIGHT", true)
        button.themeBorder.left   = makeEdge("TOPLEFT", "BOTTOMLEFT", false)
        button.themeBorder.right  = makeEdge("TOPRIGHT", "BOTTOMRIGHT", false)
    end
    for _, edge in pairs(button.themeBorder) do
        edge:SetColorTexture(unpack(palette.border))
    end

    if not button._themeHookInstalled then
        button._themeHookInstalled = true
        button:HookScript("OnEnter", function(self)
            if self.themeHover then self.themeHover:Show() end
        end)
        button:HookScript("OnLeave", function(self)
            if self.themeHover then self.themeHover:Hide() end
        end)
    end

    local label = button:GetFontString()
    if label then
        label:SetTextColor(unpack(palette.text))
    end
end
