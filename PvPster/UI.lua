--[[
    PvPster UI
    독자적인 메인 창 (Blizzard 패널 통합 없이)
    캐릭터 행 단위 테이블, 컬럼 정렬, 드래그 가능
]]

local _, PvPster = ...


-- Lua API Localization
local pairs = pairs
local ipairs = ipairs
local string = string
local table = table
local math = math
local tostring = tostring
local tonumber = tonumber
local time = time

-- WoW API Localization
local CreateFrame = CreateFrame
local C_Timer = C_Timer
local UIParent = UIParent
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local UISpecialFrames = UISpecialFrames
local GameTooltip = GameTooltip


local Constants = PvPster.Constants
local Logger = PvPster.Logger
local DB = PvPster.DB
local L = PvPster.L


local UI = {}
PvPster.UI = UI


local mainFrame
local headerFrame
local scrollChild
local footerSyncText
local emptyText
local scaleValueText
local minimapButton

local rowPool = {}
local headerButtons = {}
local clockTicker


local COLUMNS = {
    { key = "name",       width = 160, labelKey = "Name",          align = "LEFT"   },
    { key = "realm",      width = 120, labelKey = "Realm",         align = "LEFT"   },
    { key = "level",      width = 40,  labelKey = "Level",         align = "CENTER" },
    { key = "itemLevel",  width = 60,  labelKey = "iLvl",          align = "CENTER" },
    { key = "honor",      width = 124, labelKey = "Honor",         align = "CENTER" },
    { key = "conquest",   width = 124, labelKey = "Conquest",      align = "CENTER" },
    { key = "bracket_1",  width = 86,  labelKey = "BRACKET_2V2",   align = "CENTER" },
    { key = "bracket_2",  width = 86,  labelKey = "BRACKET_3V3",   align = "CENTER" },
    { key = "bracket_7",  width = 96,  labelKey = "BRACKET_SHUFFLE", align = "CENTER" },
    { key = "bracket_9",  width = 86,  labelKey = "BRACKET_BLITZ", align = "CENTER" },
    { key = "lastSeen",   width = 96,  labelKey = "LastSeen",      align = "RIGHT"  },
}


local function computeColumnXOffsets()
    local offsets = {}
    local x = 0
    for _, col in ipairs(COLUMNS) do
        offsets[col.key] = x
        x = x + col.width + 4
    end
    return offsets, x
end


local COLUMN_X, TOTAL_COLUMN_WIDTH = computeColumnXOffsets()


local function formatNumber(value)
    if not value then return "0" end
    local formatted = tostring(math.floor(value + 0.5))
    while true do
        local replaced
        formatted, replaced = formatted:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
        if replaced == 0 then break end
    end
    return formatted
end


-- Right-pad a number with regular spaces. Works for monospace fonts
-- (NumberFontNormalSmall etc.) where digit and space widths are uniform.
local function padNumber(num, width)
    return string.format("%" .. width .. "d", num or 0)
end


local function formatRelativeTime(timestamp)
    if not timestamp or timestamp == 0 then return "-" end
    local diff = time() - timestamp
    if diff < 60 then return L["JustNow"] end
    if diff < 3600 then return string.format(L["MinutesAgo"], math.floor(diff / 60)) end
    if diff < 86400 then return string.format(L["HoursAgo"], math.floor(diff / 3600)) end
    return string.format(L["DaysAgo"], math.floor(diff / 86400))
end


local function formatCurrency(currencyData, useTotalEarned)
    if not currencyData then return "-" end
    local current = useTotalEarned and currencyData.totalEarned or currencyData.quantity
    return formatNumber(current or 0)
end


local function formatCurrencyWithMax(currencyData, useTotalEarned, maxOverride)
    if not currencyData then return "-" end
    local current = useTotalEarned and currencyData.totalEarned or currencyData.quantity
    current = current or 0
    local max = maxOverride or currencyData.maxQuantity or 0
    if max > 0 then
        return string.format("%s / %s", formatNumber(current), formatNumber(max))
    end
    return formatNumber(current)
end


local function formatConquest(conquestData)
    if not conquestData then return "-" end
    local owned = conquestData.quantity or 0
    local earned = conquestData.totalEarned or 0
    return string.format("%s (%s)", formatNumber(owned), formatNumber(earned))
end


local function formatConquestWithMax(conquestData, maxOverride)
    if not conquestData then return "-" end
    local owned = conquestData.quantity or 0
    local earned = conquestData.totalEarned or 0
    local max = maxOverride or conquestData.maxQuantity or 0
    if max > 0 then
        return string.format(
            "%s (%s) / %s",
            formatNumber(owned), formatNumber(earned), formatNumber(max)
        )
    end
    return string.format("%s (%s)", formatNumber(owned), formatNumber(earned))
end


local function formatRating(ratingData)
    if not ratingData or not ratingData.rating or ratingData.rating == 0 then
        return "-"
    end
    return formatNumber(ratingData.rating)
end


local function formatWinRate(won, played)
    if not played or played == 0 then return nil end
    local pct = math.floor((won or 0) / played * 100 + 0.5)
    return string.format("%3d%%", pct)
end


local function getCurrencyMaxForCurrentCharacter(currencyKey)
    local key = DB:GetCharacterKey()
    local character = DB:GetCharacter(key)
    if not character or not character.currency then return nil end
    local data = character.currency[currencyKey]
    if not data or not data.maxQuantity or data.maxQuantity == 0 then return nil end
    return data.maxQuantity
end


local function getHeaderLabel(column)
    local base = L[column.labelKey] or column.labelKey
    if column.key == "honor" then
        local max = getCurrencyMaxForCurrentCharacter("honor")
        if max then return string.format("%s (%s)", base, formatNumber(max)) end
    elseif column.key == "conquest" then
        local max = getCurrencyMaxForCurrentCharacter("conquest")
        if max then return string.format("%s (%s)", base, formatNumber(max)) end
    end
    return base
end


local function getCharacterSortValue(character, columnKey)
    if columnKey == "name" then
        return (character.name or ""):lower()
    elseif columnKey == "realm" then
        return (character.realm or ""):lower()
    elseif columnKey == "level" then
        return character.level or 0
    elseif columnKey == "itemLevel" then
        return (character.equipment and character.equipment.averageItemLevelPvP) or 0
    elseif columnKey == "honor" then
        return (character.currency and character.currency.honor and character.currency.honor.quantity) or 0
    elseif columnKey == "conquest" then
        local conquest = character.currency and character.currency.conquest
        return conquest and conquest.totalEarned or 0
    elseif columnKey == "lastSeen" then
        return character.lastSeen or 0
    elseif columnKey:sub(1, 8) == "bracket_" then
        local idx = tonumber(columnKey:sub(9))
        return (character.ratings and character.ratings[idx] and character.ratings[idx].rating) or 0
    end
    return 0
end


local function sortCharacters(list, sortColumn, sortDirection)
    table.sort(list, function(a, b)
        local av = getCharacterSortValue(a, sortColumn)
        local bv = getCharacterSortValue(b, sortColumn)
        if av == bv then
            return (a.name or "") < (b.name or "")
        end
        if sortDirection == "desc" then
            return av > bv
        end
        return av < bv
    end)
end


local function createMainFrame()
    local frame = CreateFrame("Frame", "PvPsterMainFrame", UIParent)
    frame:SetSize(Constants.UI_DEFAULTS.width, Constants.UI_DEFAULTS.height)
    frame:SetFrameStrata("HIGH")
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, _, x, y = self:GetPoint()
        DB:SaveUIState("position", { point = point, x = x, y = y })
    end)

    PvPster.Theme:ApplyFrameBackground(frame)

    local pos = DB:GetUIState().position or { point = "CENTER", x = 0, y = 0 }
    frame:ClearAllPoints()
    frame:SetPoint(pos.point, UIParent, pos.point, pos.x, pos.y)

    local palette = PvPster.Theme:GetCurrent()

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", frame, "TOP", 0, -12)
    title:SetText("PvPster")
    title:SetTextColor(palette.text[1], palette.text[2], palette.text[3])
    frame.titleText = title

    -- Custom close button (flat, themed)
    local closeButton = CreateFrame("Button", nil, frame)
    closeButton:SetSize(24, 24)
    closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -8, -8)

    local closeText = closeButton:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    closeText:SetPoint("CENTER")
    closeText:SetText("×")
    closeText:SetTextColor(palette.textSecondary[1], palette.textSecondary[2], palette.textSecondary[3])

    closeButton:SetScript("OnEnter", function()
        closeText:SetTextColor(palette.danger[1], palette.danger[2], palette.danger[3])
    end)
    closeButton:SetScript("OnLeave", function()
        closeText:SetTextColor(palette.textSecondary[1], palette.textSecondary[2], palette.textSecondary[3])
    end)
    closeButton:SetScript("OnClick", function() UI:Hide() end)
    frame.closeButton = closeButton
    frame.closeText = closeText

    table.insert(UISpecialFrames, "PvPsterMainFrame")

    -- Reset confirmation popup
    StaticPopupDialogs["PVPSTER_RESET_CONFIRM"] = {
        text = L["ResetConfirmDialog"],
        button1 = YES,
        button2 = NO,
        OnAccept = function()
            PvPster.DB:Reset()
            UI:Refresh()
            DEFAULT_CHAT_FRAME:AddMessage("|cff5599ff[PvPster]|r " .. L["DataReset"])
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }

    return frame
end


local function refreshMinimapButtonLabel()
    if not minimapButton then return end
    local visible = DB:GetUIState().minimapVisible
    if visible == nil then visible = true end
    local stateText = visible and "ON" or "OFF"
    local color = visible and "|cff66ff66" or "|cffff6666"
    minimapButton:SetText(string.format("%s  %s%s|r", L["Minimap"], color, stateText))
end


local function refreshScaleText()
    if not scaleValueText then return end
    local current = DB:GetUIState().uiScale or 1.0
    scaleValueText:SetText(string.format("%.2f", current))
end


local titleBarButtons = {}


local function makeThemedButton(parent, label)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(60, 22)

    local text = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("CENTER")
    text:SetText(label)
    button:SetFontString(text)

    PvPster.Theme:ApplyButton(button)
    return button, text
end


local function createTitleBarButtons()
    local syncButton = makeThemedButton(mainFrame, L["Sync"])
    syncButton:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 14, -10)
    syncButton:SetScript("OnClick", function()
        PvPster.Collector:RunFullSync()
        local key = PvPster.DB:GetCharacterKey()
        DEFAULT_CHAT_FRAME:AddMessage(
            "|cff5599ff[PvPster]|r " .. string.format(L["SyncDone"], key)
        )
    end)
    titleBarButtons.sync = syncButton

    local resetButton = makeThemedButton(mainFrame, L["Reset"])
    resetButton:SetPoint("LEFT", syncButton, "RIGHT", 4, 0)
    resetButton:SetScript("OnClick", function()
        StaticPopup_Show("PVPSTER_RESET_CONFIRM")
    end)
    titleBarButtons.reset = resetButton

    minimapButton = makeThemedButton(mainFrame, L["Minimap"])
    minimapButton:SetSize(110, 22)
    minimapButton:SetPoint("LEFT", resetButton, "RIGHT", 4, 0)
    minimapButton:SetScript("OnClick", function()
        if PvPster.Minimap and PvPster.Minimap.Toggle then
            PvPster.Minimap:Toggle()
            refreshMinimapButtonLabel()
        end
    end)
    titleBarButtons.minimap = minimapButton
    refreshMinimapButtonLabel()

    -- Scale controls: [-] [value] [+]
    local scaleMinus = makeThemedButton(mainFrame, "-")
    scaleMinus:SetSize(22, 22)
    scaleMinus:SetPoint("LEFT", minimapButton, "RIGHT", 12, 0)
    scaleMinus:SetScript("OnClick", function()
        local current = DB:GetUIState().uiScale or 1.0
        UI:ApplyScale(current - 0.05)
    end)
    titleBarButtons.scaleMinus = scaleMinus

    scaleValueText = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    scaleValueText:SetPoint("LEFT", scaleMinus, "RIGHT", 6, 0)
    scaleValueText:SetWidth(36)
    scaleValueText:SetJustifyH("CENTER")

    local scalePlus = makeThemedButton(mainFrame, "+")
    scalePlus:SetSize(22, 22)
    scalePlus:SetPoint("LEFT", scaleValueText, "RIGHT", 6, 0)
    scalePlus:SetScript("OnClick", function()
        local current = DB:GetUIState().uiScale or 1.0
        UI:ApplyScale(current + 0.05)
    end)
    titleBarButtons.scalePlus = scalePlus

    refreshScaleText()
end


local function createHeaderButton(parent, column)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(column.width, 18)
    button:SetPoint("TOPLEFT", parent, "TOPLEFT", COLUMN_X[column.key], 0)
    button:RegisterForClicks("LeftButtonUp")
    button:SetScript("OnClick", function()
        local ui = DB:GetUIState()
        if ui.sortColumn == column.key then
            ui.sortDirection = ui.sortDirection == "asc" and "desc" or "asc"
        else
            ui.sortColumn = column.key
            ui.sortDirection = "asc"
        end
        UI:Refresh()
    end)

    local label = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    label:SetAllPoints(button)
    label:SetJustifyH(column.align or "LEFT")
    label:SetWordWrap(false)
    button.label = label

    local sortIcon = button:CreateTexture(nil, "OVERLAY")
    sortIcon:SetSize(8, 8)
    sortIcon:SetPoint("RIGHT", button, "RIGHT", -2, 0)
    sortIcon:SetTexture("Interface\\Buttons\\UI-SortArrow")
    sortIcon:Hide()
    button.sortIcon = sortIcon

    button:SetScript("OnEnter", function() label:SetTextColor(1, 1, 0.5) end)
    button:SetScript("OnLeave", function() label:SetTextColor(1, 1, 1) end)

    return button
end


local function refreshHeaderLabels()
    local ui = DB:GetUIState()
    for _, col in ipairs(COLUMNS) do
        local btn = headerButtons[col.key]
        if btn then
            btn.label:SetText(getHeaderLabel(col))

            if ui.sortColumn == col.key then
                btn.sortIcon:Show()
                if ui.sortDirection == "asc" then
                    btn.sortIcon:SetTexCoord(0, 0.5625, 1, 0)
                else
                    btn.sortIcon:SetTexCoord(0, 0.5625, 0, 1)
                end
            else
                btn.sortIcon:Hide()
            end
        end
    end
end


local function showCharacterTooltip(row)
    local character = row.character
    if not character then return end

    GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
    GameTooltip:SetMinimumWidth(500)

    local color = RAID_CLASS_COLORS[character.classFile] or { r = 1, g = 1, b = 1 }
    local subtitleParts = {}
    if character.level then table.insert(subtitleParts, "Lv " .. character.level) end
    if character.raceLocalized then table.insert(subtitleParts, character.raceLocalized) end
    if character.classLocalized then table.insert(subtitleParts, character.classLocalized) end

    GameTooltip:AddDoubleLine(
        character.name or "?",
        table.concat(subtitleParts, " "),
        color.r, color.g, color.b,
        0.7, 0.7, 0.7
    )
    if character.realm then
        GameTooltip:AddLine(character.realm, 0.55, 0.55, 0.55)
    end

    local equipment = character.equipment
    if equipment then
        GameTooltip:AddLine(" ")
        local pvp = math.floor((equipment.averageItemLevelPvP or 0) + 0.5)
        local equipped = math.floor((equipment.averageItemLevelEquipped or 0) + 0.5)
        local detail = string.format("%d  (%s %d)", pvp, L["Equipment"], equipped)
        GameTooltip:AddDoubleLine(L["AverageItemLevel"], detail, 1, 0.85, 0.3, 1, 1, 1)

        if equipment.slots and next(equipment.slots) then
            GameTooltip:AddLine(" ")
            for _, slotID in ipairs(Constants.ITEM_SLOTS) do
                local slot = equipment.slots[slotID]
                if slot and slot.itemLink then
                    local labelKey = Constants.SLOT_LABEL_KEYS[slotID] or "Slot_Unknown"

                    local _, _, _, _, itemIcon = C_Item.GetItemInfoInstant(slot.itemLink)
                    local itemIconStr = itemIcon
                            and string.format("|T%d:12:12:0:0|t ", itemIcon)
                            or ""
                    local displayLevel = slot.pvpItemLevel or slot.itemLevel or 0

                    -- Main row: slot label LEFT, item info RIGHT
                    GameTooltip:AddDoubleLine(
                        L[labelKey] or labelKey,
                        string.format(
                            "%s%s  (%d)",
                            itemIconStr,
                            slot.itemLink,
                            displayLevel
                        ),
                        0.7, 0.7, 0.7,
                        1, 1, 1
                    )

                    -- Each gem on its own row, right-aligned
                    if slot.gemLinks and #slot.gemLinks > 0 then
                        for i, gemLink in ipairs(slot.gemLinks) do
                            local _, _, _, _, gemIcon = C_Item.GetItemInfoInstant(gemLink)
                            local gemIconStr = gemIcon
                                    and string.format("|T%d:12:12:0:0|t ", gemIcon)
                                    or ""
                            local stats = slot.gemStats and slot.gemStats[i] or ""
                            local rightText = stats ~= ""
                                    and string.format(
                                        "%s%s  |cffcccccc%s|r",
                                        gemIconStr, gemLink, stats
                                    )
                                    or string.format("%s%s", gemIconStr, gemLink)
                            GameTooltip:AddDoubleLine(
                                " ", rightText,
                                0, 0, 0,
                                1, 1, 1
                            )
                        end
                    end

                    -- Enchant on its own row, right-aligned
                    if slot.enchantName then
                        GameTooltip:AddDoubleLine(
                            " ",
                            string.format(
                                "|TInterface\\Icons\\inv_misc_enchantedscroll:12:12:0:0|t %s",
                                slot.enchantName
                            ),
                            0, 0, 0,
                            0.4, 0.7, 1
                        )
                    end
                end
            end
        end
    end

    local currency = character.currency
    if currency and (currency.honor or currency.conquest or currency.accountHonor) then
        local sharedHonorMax = getCurrencyMaxForCurrentCharacter("honor")
        local sharedConquestMax = getCurrencyMaxForCurrentCharacter("conquest")

        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(L["Currencies"], 1, 0.82, 0)
        if currency.honor then
            GameTooltip:AddDoubleLine(
                L["Honor"], formatCurrencyWithMax(currency.honor, false, sharedHonorMax),
                0.85, 0.85, 0.85, 1, 1, 1
            )
        end
        if currency.conquest then
            GameTooltip:AddDoubleLine(
                L["Conquest"], formatConquestWithMax(currency.conquest, sharedConquestMax),
                1, 0.6, 0.6, 1, 1, 1
            )
        end
    end

    local ratings = character.ratings
    if ratings and next(ratings) then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(L["Ratings"], 1, 0.82, 0)
        for _, bracket in ipairs(Constants.TRACKED_BRACKETS) do
            local data = ratings[bracket.index]
            if data and data.rating and data.rating > 0 then
                local played = bracket.usesRounds and data.roundsSeasonPlayed or data.seasonPlayed
                local won = bracket.usesRounds and data.roundsSeasonWon or data.seasonWon
                played = played or 0
                won = won or 0

                local recordText
                if played > 0 then
                    local rate = formatWinRate(won, played) or padNumber(0, 3) .. "%"
                    recordText = string.format(
                        L["WinLossRecord"] .. "  (%s)",
                        padNumber(won, 4), padNumber(played - won, 4), rate
                    )
                else
                    recordText = string.format(
                        L["WinLossRecord"] .. "  (%s)",
                        padNumber(0, 4), padNumber(0, 4), padNumber(0, 3) .. "%"
                    )
                end

                local right = string.format(
                    "%s    %s",
                    formatNumber(data.rating), recordText
                )
                GameTooltip:AddDoubleLine(
                    L[bracket.labelKey] or bracket.labelKey, right,
                    0.6, 0.85, 1, 1, 1, 1
                )
                local lineIndex = GameTooltip:NumLines()
                local rightFontString = _G["GameTooltipTextRight" .. lineIndex]
                if rightFontString then
                    -- ConsoleFont is truly monospace (digits, letters, spaces all same width).
                    -- Falls back to NumberFontNormalSmall if not available.
                    if _G.ConsoleFont then
                        rightFontString:SetFontObject(_G.ConsoleFont)
                    elseif NumberFontNormalSmall then
                        rightFontString:SetFontObject(NumberFontNormalSmall)
                    end
                end
            end
        end
    end

    GameTooltip:Show()
end


local function createRow(parent)
    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(Constants.UI_DEFAULTS.rowHeight)
    row:SetWidth(TOTAL_COLUMN_WIDTH)

    local bg = row:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(row)
    bg:SetColorTexture(1, 1, 1, 0.05)
    bg:Hide()
    row.bg = bg

    row:EnableMouse(true)
    row:SetScript("OnEnter", function(self)
        bg:Show()
        showCharacterTooltip(self)
    end)
    row:SetScript("OnLeave", function()
        bg:Hide()
        GameTooltip:Hide()
    end)

    row.texts = {}
    for _, col in ipairs(COLUMNS) do
        local fs = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        fs:SetPoint("LEFT", row, "LEFT", COLUMN_X[col.key], 0)
        fs:SetSize(col.width, Constants.UI_DEFAULTS.rowHeight - 4)
        fs:SetJustifyH(col.align or "LEFT")
        fs:SetWordWrap(false)
        row.texts[col.key] = fs
    end

    return row
end


local function getOrCreateRow(parent, index)
    local row = rowPool[index]
    if not row then
        row = createRow(parent)
        rowPool[index] = row
    end
    return row
end


local function fillRow(row, character, index)
    row.character = character

    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", row:GetParent(), "TOPLEFT", 0, -((index - 1) * Constants.UI_DEFAULTS.rowHeight))
    row:Show()

    local color = RAID_CLASS_COLORS[character.classFile] or { r = 1, g = 1, b = 1 }
    row.texts.name:SetText(character.name or "?")
    row.texts.name:SetTextColor(color.r, color.g, color.b)

    row.texts.realm:SetText(character.realm or "?")
    row.texts.realm:SetTextColor(0.7, 0.7, 0.7)

    row.texts.level:SetText(tostring(character.level or 0))
    row.texts.level:SetTextColor(1, 1, 1)

    local equipment = character.equipment
    local ilvl = equipment and equipment.averageItemLevelPvP or 0
    row.texts.itemLevel:SetText(string.format("%d", math.floor(ilvl + 0.5)))
    row.texts.itemLevel:SetTextColor(1, 0.85, 0.3)

    local currency = character.currency or {}
    row.texts.honor:SetText(formatCurrency(currency.honor, false))
    row.texts.honor:SetTextColor(0.95, 0.95, 0.95)

    row.texts.conquest:SetText(formatConquest(currency.conquest))
    row.texts.conquest:SetTextColor(1, 0.6, 0.6)

    local ratings = character.ratings or {}
    row.texts.bracket_1:SetText(formatRating(ratings[1]))
    row.texts.bracket_2:SetText(formatRating(ratings[2]))
    row.texts.bracket_7:SetText(formatRating(ratings[7]))
    row.texts.bracket_9:SetText(formatRating(ratings[9]))
    for _, key in ipairs({ "bracket_1", "bracket_2", "bracket_7", "bracket_9" }) do
        row.texts[key]:SetTextColor(0.6, 0.85, 1)
    end

    row.texts.lastSeen:SetText(formatRelativeTime(character.lastSeen))
    row.texts.lastSeen:SetTextColor(0.6, 0.6, 0.6)
end


local function buildLayout()
    createTitleBarButtons()

    headerFrame = CreateFrame("Frame", nil, mainFrame)
    headerFrame:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 14, -36)
    headerFrame:SetSize(TOTAL_COLUMN_WIDTH, 20)

    for _, col in ipairs(COLUMNS) do
        headerButtons[col.key] = createHeaderButton(headerFrame, col)
    end

    local separator = headerFrame:CreateTexture(nil, "ARTWORK")
    separator:SetPoint("TOPLEFT", headerFrame, "BOTTOMLEFT", 0, -2)
    separator:SetPoint("TOPRIGHT", headerFrame, "BOTTOMRIGHT", 0, -2)
    separator:SetHeight(1)
    headerFrame.separator = separator

    local scrollFrame = CreateFrame(
        "ScrollFrame",
        "PvPsterScrollFrame",
        mainFrame,
        "UIPanelScrollFrameTemplate"
    )
    scrollFrame:SetPoint("TOPLEFT", headerFrame, "BOTTOMLEFT", 0, -6)
    scrollFrame:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -32, 30)

    scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(TOTAL_COLUMN_WIDTH, 1)
    scrollFrame:SetScrollChild(scrollChild)

    footerSyncText = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    footerSyncText:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 14, 12)

    local helpText = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    helpText:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -14, 12)
    helpText:SetText("/pvpster help")

    emptyText = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    emptyText:SetPoint("CENTER", mainFrame, "CENTER", 0, 0)
    emptyText:SetText(L["NoCharactersTitle"] .. "\n\n" .. L["NoCharactersBody"])
    emptyText:SetTextColor(0.7, 0.7, 0.7)
    emptyText:SetJustifyH("CENTER")
    emptyText:Hide()
end


function UI:Initialize()
    mainFrame = createMainFrame()
    buildLayout()
    local savedScale = DB:GetUIState().uiScale or 1.0
    mainFrame:SetScale(savedScale)
    UI:ApplyTheme()
    mainFrame:Hide()
    Logger:Log("UI", "Initialized")
end


function UI:ApplyScale(value)
    if not mainFrame then return end
    local rounded = math.floor(value * 20 + 0.5) / 20
    if rounded < 0.5 then rounded = 0.5 end
    if rounded > 2.0 then rounded = 2.0 end
    mainFrame:SetScale(rounded)
    DB:SaveUIState("uiScale", rounded)
    refreshScaleText()
end


function UI:RefreshMinimapButton()
    refreshMinimapButtonLabel()
end


function UI:ApplyTheme()
    if not mainFrame then return end
    local palette = PvPster.Theme:GetCurrent()

    PvPster.Theme:ApplyFrameBackground(mainFrame, palette)

    if mainFrame.titleText then
        mainFrame.titleText:SetTextColor(palette.text[1], palette.text[2], palette.text[3])
    end
    if mainFrame.closeText then
        mainFrame.closeText:SetTextColor(
            palette.textSecondary[1], palette.textSecondary[2], palette.textSecondary[3]
        )
    end

    for _, button in pairs(titleBarButtons) do
        PvPster.Theme:ApplyButton(button, palette)
    end

    refreshMinimapButtonLabel()

    if headerFrame and headerFrame.separator then
        headerFrame.separator:SetColorTexture(
            palette.separator[1], palette.separator[2], palette.separator[3], palette.separator[4]
        )
    end

    -- Row hover backgrounds use theme color
    for _, row in pairs(rowPool) do
        if row.bg then
            row.bg:SetColorTexture(
                palette.rowHover[1], palette.rowHover[2], palette.rowHover[3], palette.rowHover[4]
            )
        end
    end

    if scaleValueText then
        scaleValueText:SetTextColor(palette.text[1], palette.text[2], palette.text[3])
    end
    if footerSyncText then
        footerSyncText:SetTextColor(palette.textDim[1], palette.textDim[2], palette.textDim[3])
    end
    if emptyText then
        emptyText:SetTextColor(palette.textSecondary[1], palette.textSecondary[2], palette.textSecondary[3])
    end

    UI:Refresh()
end


function UI:Refresh()
    if not mainFrame or not mainFrame:IsShown() then return end

    refreshHeaderLabels()

    local list = {}
    for _, character in pairs(DB:GetAllCharacters()) do
        table.insert(list, character)
    end

    if #list == 0 then
        for _, row in ipairs(rowPool) do row:Hide() end
        emptyText:Show()
        scrollChild:SetSize(TOTAL_COLUMN_WIDTH, 1)
        if footerSyncText then footerSyncText:SetText("") end
        return
    end

    emptyText:Hide()

    local uiState = DB:GetUIState()
    sortCharacters(list, uiState.sortColumn, uiState.sortDirection)

    for i, character in ipairs(list) do
        local row = getOrCreateRow(scrollChild, i)
        fillRow(row, character, i)
    end

    for i = #list + 1, #rowPool do
        rowPool[i]:Hide()
    end

    scrollChild:SetSize(TOTAL_COLUMN_WIDTH, #list * Constants.UI_DEFAULTS.rowHeight)

    local currentKey = DB:GetCharacterKey()
    local current = DB:GetCharacter(currentKey)
    if current and current.lastSeen then
        footerSyncText:SetText(string.format(L["LastSync"], formatRelativeTime(current.lastSeen)))
    else
        footerSyncText:SetText("")
    end
end


function UI:Show()
    if not mainFrame then return end
    mainFrame:Show()
    DB:SaveUIState("visible", true)
    UI:Refresh()
    if not clockTicker then
        clockTicker = C_Timer.NewTicker(60, function() UI:Refresh() end)
    end
end


function UI:Hide()
    if not mainFrame then return end
    mainFrame:Hide()
    DB:SaveUIState("visible", false)
    if clockTicker then
        clockTicker:Cancel()
        clockTicker = nil
    end
end


function UI:Toggle()
    if mainFrame and mainFrame:IsShown() then
        UI:Hide()
    else
        UI:Show()
    end
end
