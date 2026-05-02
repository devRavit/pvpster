--[[
    PvPster DB
    SavedVariables 관리 (PvPsterDB)
    캐릭터 데이터 + UI 상태
]]

local _, PvPster = ...


-- Lua API Localization
local pairs = pairs
local string = string
local type = type

-- WoW API Localization
local UnitName = UnitName
local GetNormalizedRealmName = GetNormalizedRealmName
local GetRealmName = GetRealmName


local Constants = PvPster.Constants
local Logger = PvPster.Logger


local DB = {}
PvPster.DB = DB


local function defaultStorage()
    return {
        version = Constants.DB_VERSION,
        characters = {},
        ui = {
            position = { point = "CENTER", x = 0, y = 0 },
            size = {
                width = Constants.UI_DEFAULTS.width,
                height = Constants.UI_DEFAULTS.height,
            },
            sortColumn = Constants.UI_DEFAULTS.sortColumn,
            sortDirection = Constants.UI_DEFAULTS.sortDirection,
            visible = false,
            minimapVisible = true,
            minimapAngle = 225,
            uiScale = 1.0,
            theme = "github",
            locale = "auto",
        },
    }
end


local function migrate(storage)
    if not storage.version then
        storage.version = 1
    end
    -- v1 → v2 마이그레이션 자리
end


local function ensureField(target, key, fallback)
    if target[key] == nil or type(target[key]) ~= type(fallback) then
        target[key] = fallback
    end
end


function DB:Initialize()
    if not _G.PvPsterDB then
        _G.PvPsterDB = defaultStorage()
    else
        local default = defaultStorage()
        ensureField(_G.PvPsterDB, "characters", {})
        ensureField(_G.PvPsterDB, "ui", default.ui)
        ensureField(_G.PvPsterDB, "version", default.version)
        ensureField(_G.PvPsterDB.ui, "position", default.ui.position)
        ensureField(_G.PvPsterDB.ui, "size", default.ui.size)
        ensureField(_G.PvPsterDB.ui, "sortColumn", default.ui.sortColumn)
        ensureField(_G.PvPsterDB.ui, "sortDirection", default.ui.sortDirection)
        if _G.PvPsterDB.ui.visible == nil then
            _G.PvPsterDB.ui.visible = false
        end
        if _G.PvPsterDB.ui.minimapVisible == nil then
            _G.PvPsterDB.ui.minimapVisible = true
        end
        if _G.PvPsterDB.ui.minimapAngle == nil then
            _G.PvPsterDB.ui.minimapAngle = 225
        end
        if _G.PvPsterDB.ui.uiScale == nil then
            _G.PvPsterDB.ui.uiScale = 1.0
        end
        if _G.PvPsterDB.ui.theme == nil then
            _G.PvPsterDB.ui.theme = "github"
        end
        if _G.PvPsterDB.ui.locale == nil then
            _G.PvPsterDB.ui.locale = "auto"
        end
        migrate(_G.PvPsterDB)
    end

    Logger:Log(
        "DB",
        string.format("Initialized v%d (%d characters)", _G.PvPsterDB.version, self:CountCharacters())
    )
end


function DB:Get()
    return _G.PvPsterDB
end


function DB:GetCharacterKey()
    local realm = GetNormalizedRealmName() or GetRealmName() or "Unknown"
    local name = UnitName("player") or "Unknown"
    return string.format("%s-%s", realm, name)
end


function DB:GetCharacter(key)
    return _G.PvPsterDB.characters[key]
end


function DB:UpsertCharacter(key, partial)
    local existing = _G.PvPsterDB.characters[key] or {}
    for k, v in pairs(partial) do
        existing[k] = v
    end
    _G.PvPsterDB.characters[key] = existing
end


function DB:RemoveCharacter(key)
    _G.PvPsterDB.characters[key] = nil
end


function DB:GetAllCharacters()
    return _G.PvPsterDB.characters
end


function DB:CountCharacters()
    local count = 0
    for _ in pairs(_G.PvPsterDB.characters) do
        count = count + 1
    end
    return count
end


function DB:Reset()
    -- Preserve UI preferences (window/minimap position, theme, scale, sort)
    -- so users don't lose their layout each time they wipe character data.
    _G.PvPsterDB.characters = {}
    Logger:Log("DB", "Reset")
end


function DB:GetUIState()
    return _G.PvPsterDB.ui
end


function DB:SaveUIState(field, value)
    _G.PvPsterDB.ui[field] = value
end


-- Propagate an account-shared currency value to every character entry.
-- Used when account-wide honor changes — every character should reflect
-- the latest value, since the source-of-truth lives on the account, not the char.
function DB:PropagateAccountCurrency(currencyKey, value)
    if not currencyKey or value == nil then return end
    for _, character in pairs(_G.PvPsterDB.characters) do
        if not character.currency then
            character.currency = {}
        end
        character.currency[currencyKey] = value
    end
end
