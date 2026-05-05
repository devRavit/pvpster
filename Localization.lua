--[[
    PvPster Localization (engine)

    Locale data lives in `Locales/<locale>.lua`. Each locale file pushes its
    table into `PvPster.LOCALE_REGISTRY`. The .toc must load every locale
    file BEFORE this one so the registry is populated when we read it here.

    Resolution order:
      1. User preference saved in DB (ui.locale) — explicit value if supported
      2. Client locale (GetLocale()) — used when preference is nil/"auto"
      3. enUS — whole-locale fallback when the resolved locale has no table
      4. enUS — per-key fallback for any keys missing in the active locale
         (applyLocale lays enUS down first, then overlays the active locale)

    The L table is mutated in-place when locale changes so existing
    `local L = PvPster.L` captures in other modules stay valid.

    Adding a new locale: drop a `Locales/<key>.lua` file following the
    pattern of the existing ones, add it to PvPster.toc — that's it.
    Partial translations are safe; missing keys fall back to enUS.
]]

local _, PvPster = ...


-- Lua API Localization
local pairs = pairs
local ipairs = ipairs
local setmetatable = setmetatable

-- WoW API Localization
local GetLocale = GetLocale


local L = {}
PvPster.L = L


local Localization = {}
PvPster.Localization = Localization


local DEFAULT_LOCALE = "enUS"
local AUTO_KEY = "auto"


-- Pulled from the registry that locale files populated. We snapshot the
-- references rather than copying the data, so locale tables can still be
-- mutated by their owning files if needed.
local registry = PvPster.LOCALE_REGISTRY or { strings = {}, names = {}, order = {} }
local LOCALES = registry.strings


-- Build the dropdown list from the registry's insertion order, which is
-- driven by the .toc loading order. enUS should be first in the .toc so
-- it appears first in the dropdown.
local SUPPORTED_LOCALES = {}
for _, key in ipairs(registry.order) do
    if registry.names[key] then
        SUPPORTED_LOCALES[#SUPPORTED_LOCALES + 1] = {
            key = key,
            nativeName = registry.names[key],
        }
    end
end


if not LOCALES[DEFAULT_LOCALE] then
    -- enUS is mandatory — without it there's no fallback and the metatable
    -- below would leak raw keys for everything. Surface this as a real
    -- error rather than silently degrading.
    error("PvPster: required locale '" .. DEFAULT_LOCALE
            .. "' is missing. Check that Locales/enUS.lua loads before Localization.lua.")
end


setmetatable(L, {
    __index = function(_, key) return key end,
})


local function clearTable(target)
    for key in pairs(target) do
        target[key] = nil
    end
end


local function getClientLocale()
    local raw = GetLocale and GetLocale() or DEFAULT_LOCALE
    if LOCALES[raw] then return raw end
    return DEFAULT_LOCALE
end


local function resolveLocale(preference)
    if preference == nil or preference == AUTO_KEY then
        return getClientLocale()
    end
    if LOCALES[preference] then
        return preference
    end
    return getClientLocale()
end


local function applyLocale(localeKey)
    clearTable(L)
    -- Lay down enUS first so any key missing from the active locale resolves
    -- to English instead of leaking the raw key through the metatable fallback.
    for key, value in pairs(LOCALES[DEFAULT_LOCALE]) do
        L[key] = value
    end
    if localeKey ~= DEFAULT_LOCALE then
        local overlay = LOCALES[localeKey]
        if overlay then
            for key, value in pairs(overlay) do
                L[key] = value
            end
        end
    end
end


function Localization:GetClientLocale()
    return getClientLocale()
end


function Localization:GetSupportedLocales()
    return SUPPORTED_LOCALES
end


function Localization:IsSupported(localeKey)
    if localeKey == AUTO_KEY then return true end
    return LOCALES[localeKey] ~= nil
end


function Localization:Resolve(preference)
    return resolveLocale(preference)
end


function Localization:Apply(preference)
    local effective = resolveLocale(preference)
    applyLocale(effective)
    return effective
end


function Localization:GetNativeName(localeKey)
    for _, entry in ipairs(SUPPORTED_LOCALES) do
        if entry.key == localeKey then
            return entry.nativeName
        end
    end
    return localeKey
end


-- Apply client locale at file-load time so any module that reads L from
-- a top-level expression (rather than inside a function) sees populated
-- strings immediately. The saved preference is re-applied during
-- ADDON_LOADED once DB is ready.
applyLocale(getClientLocale())
