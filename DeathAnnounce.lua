-------------------------------------------------------------------------------
--  DeathAnnounce.lua
--  Counts your deaths locally and announces them in Guild chat.
--  Set your starting count once with /da set <number>, then forget about it.
--
--  WoW 3.3.5a (Wrath of the Lich King)
-------------------------------------------------------------------------------

local ADDON_NAME     = "DeathAnnounce"
local ANNOUNCE_DELAY = 2.0   -- seconds to wait after death before sending

-------------------------------------------------------------------------------
-- SavedVariables defaults
-------------------------------------------------------------------------------
local DB_DEFAULTS = {
    deaths      = 0,
    enabled     = true,
    message     = "{name} died for the {ordinal} time — killed by {killer}",
    env_message = "{name} died for the {ordinal} time — Killed by being bad ({env_type})",
}

-------------------------------------------------------------------------------
-- Killer tracking
-------------------------------------------------------------------------------
local lastKillerName  = nil
local lastKillerLevel = nil
local lastEnvType     = nil   -- set when death was environmental

-- Maps WoW's internal environment strings to human-readable ones.
local ENV_STRINGS = {
    Falling  = "fell off something",
    Drowning = "forgot to breathe",
    Fatigue  = "swam too far out",
    Fire     = "stood in the fire",
    Lava     = "touched the lava",
    Slime    = "walked into the slime",
}

-- Attempt to resolve a GUID to a level by scanning common unit IDs.
local UNIT_IDS = {
    "target", "focus", "mouseover",
    "targettarget", "focustarget",
}
local function GetLevelFromGUID(guid)
    for _, unitID in ipairs(UNIT_IDS) do
        if UnitExists(unitID) and UnitGUID(unitID) == guid then
            local level = UnitLevel(unitID)
            if level and level > 0 then
                return level
            end
        end
    end
    return nil
end

-------------------------------------------------------------------------------
-- Utility helpers
-------------------------------------------------------------------------------

local function OrdinalSuffix(n)
    n = math.abs(n)
    local mod100 = n % 100
    if mod100 >= 11 and mod100 <= 13 then return "th" end
    local mod10 = n % 10
    if     mod10 == 1 then return "st"
    elseif mod10 == 2 then return "nd"
    elseif mod10 == 3 then return "rd"
    else                    return "th"
    end
end

-- Builds the killer portion of the message:
--   env death  → nil  (caller uses env_message instead)
--   mob + lvl  → "Kel'Thuzad (lvl 80)"
--   mob no lvl → "Kel'Thuzad"
local function BuildKillerString()
    if lastEnvType then return nil end
    if not lastKillerName then return "something" end
    if lastKillerLevel then
        return lastKillerName .. " (lvl " .. lastKillerLevel .. ")"
    end
    return lastKillerName
end

-- Builds the full message string from the appropriate template.
local function BuildMessage(count)
    local name    = UnitName("player")
    local ordinal = count .. OrdinalSuffix(count)
    local msg

    if lastEnvType then
        local envStr = ENV_STRINGS[lastEnvType] or lastEnvType:lower()
        msg = DeathAnnounceDB.env_message
        msg = msg:gsub("{env_type}", envStr)
    else
        local killer = BuildKillerString()
        msg = DeathAnnounceDB.message
        msg = msg:gsub("{killer}", killer or "something")
    end

    msg = msg:gsub("{name}",    name)
    msg = msg:gsub("{count}",   tostring(count))
    msg = msg:gsub("{ordinal}", ordinal)
    return msg
end

-- Sends the death announcement to Guild chat.
local function AnnounceToGuild(count)
    if not IsInGuild() then
        print("|cffFF4444[DeathAnnounce]|r Not in a guild – announcement skipped.")
        return
    end
    SendChatMessage(BuildMessage(count), "GUILD")
end

-------------------------------------------------------------------------------
-- Main frame + timer
-------------------------------------------------------------------------------
local frame       = CreateFrame("Frame", "DeathAnnounceFrame")
local countdown   = -1
local deathQueued = false

frame:SetScript("OnUpdate", function(self, elapsed)
    if not deathQueued then return end
    countdown = countdown - elapsed
    if countdown <= 0 then
        deathQueued = false
        countdown   = -1
        AnnounceToGuild(DeathAnnounceDB.deaths)
    end
end)

-------------------------------------------------------------------------------
-- Event handling
-------------------------------------------------------------------------------
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_DEAD")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

frame:SetScript("OnEvent", function(self, event, ...)
    -----------------------------------------------------------------------
    if event == "ADDON_LOADED" then
        local name = ...
        if name ~= ADDON_NAME then return end

        if type(DeathAnnounceDB) ~= "table" then
            DeathAnnounceDB = {}
        end
        for k, v in pairs(DB_DEFAULTS) do
            if DeathAnnounceDB[k] == nil then
                DeathAnnounceDB[k] = v
            end
        end

    -----------------------------------------------------------------------
    elseif event == "PLAYER_LOGIN" then
        print("|cffFF4444[DeathAnnounce]|r|cffFFFFFF Loaded.|r  "
              .. "Deaths on record: |cffFFD700" .. DeathAnnounceDB.deaths .. "|r")
        if DeathAnnounceDB.deaths == 0 then
            print("|cff888888First time? Set your count: |cffFFD700/da set <number>|r")
        end
        print("|cff888888Type /da for commands.|r")

    -----------------------------------------------------------------------
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        -- 3.3.5a combat log signature (no raidFlags):
        -- timestamp, subevent, sourceGUID, sourceName, sourceFlags,
        -- destGUID, destName, destFlags, ...
        local _, subevent, sourceGUID, sourceName, _,
              destGUID = ...

        local playerGUID = UnitGUID("player")
        if destGUID ~= playerGUID then return end

        if subevent == "ENVIRONMENTAL_DAMAGE" then
            -- arg after destFlags is the environment type
            local envType = select(9, ...)
            lastEnvType     = envType
            lastKillerName  = nil
            lastKillerLevel = nil

        elseif subevent == "SWING_DAMAGE"
            or subevent == "SPELL_DAMAGE"
            or subevent == "SPELL_PERIODIC_DAMAGE"
            or subevent == "RANGE_DAMAGE"
            or subevent == "SPELL_BUILDING_DAMAGE" then

            if sourceName and sourceGUID ~= playerGUID then
                lastEnvType    = nil
                lastKillerName  = sourceName
                lastKillerLevel = GetLevelFromGUID(sourceGUID)
            end
        end

    -----------------------------------------------------------------------
    elseif event == "PLAYER_DEAD" then
        if not DeathAnnounceDB.enabled then return end
        DeathAnnounceDB.deaths = DeathAnnounceDB.deaths + 1
        deathQueued = true
        countdown   = ANNOUNCE_DELAY
    end
end)

-------------------------------------------------------------------------------
-- Slash commands   /deathannounce  |  /da
-------------------------------------------------------------------------------
SLASH_DEATHANNOUNCE1 = "/deathannounce"
SLASH_DEATHANNOUNCE2 = "/da"

SlashCmdList["DEATHANNOUNCE"] = function(input)
    local msg    = strtrim(input)
    local msgLow = msg:lower()

    ----------------------------------------------------
    if msgLow == "enable" then
        DeathAnnounceDB.enabled = true
        print("|cffFF4444[DeathAnnounce]|r Announcements |cff00FF00ENABLED|r.")

    ----------------------------------------------------
    elseif msgLow == "disable" then
        DeathAnnounceDB.enabled = false
        print("|cffFF4444[DeathAnnounce]|r Announcements |cffFF0000DISABLED|r.")

    ----------------------------------------------------
    elseif msgLow:match("^set %d+$") then
        local num = tonumber(msgLow:match("%d+"))
        DeathAnnounceDB.deaths = num
        print("|cffFF4444[DeathAnnounce]|r Death count set to |cffFFD700" .. num .. "|r.")

    ----------------------------------------------------
    elseif msgLow == "count" then
        print("|cffFF4444[DeathAnnounce]|r Deaths on record: |cffFFD700"
              .. DeathAnnounceDB.deaths .. "|r")

    ----------------------------------------------------
    elseif msgLow == "test" then
        print("|cffFF4444[DeathAnnounce]|r Preview (not sent to guild):")
        print("|cffFFD700" .. BuildMessage(DeathAnnounceDB.deaths) .. "|r")

    ----------------------------------------------------
    elseif msgLow == "send" then
        AnnounceToGuild(DeathAnnounceDB.deaths)

    ----------------------------------------------------
    elseif msgLow == "message reset" then
        DeathAnnounceDB.message     = DB_DEFAULTS.message
        DeathAnnounceDB.env_message = DB_DEFAULTS.env_message
        print("|cffFF4444[DeathAnnounce]|r Messages reset to defaults.")

    ----------------------------------------------------
    elseif msg:lower():match("^message env ") then
        local template = strtrim(msg:sub(13))
        DeathAnnounceDB.env_message = template
        print("|cffFF4444[DeathAnnounce]|r Env message updated.")
        print("|cff888888Preview: |cffFFFFFF"
              .. template
                  :gsub("{name}",     UnitName("player"))
                  :gsub("{ordinal}",  DeathAnnounceDB.deaths .. OrdinalSuffix(DeathAnnounceDB.deaths))
                  :gsub("{count}",    tostring(DeathAnnounceDB.deaths))
                  :gsub("{env_type}", "fell off something")
              .. "|r")

    ----------------------------------------------------
    elseif msg:lower():match("^message ") then
        local template = strtrim(msg:sub(9))
        if template == "" then
            print("|cffFF4444[DeathAnnounce]|r Current message templates:")
            print("|cff888888  Mob: |cffFFFFFF"     .. DeathAnnounceDB.message .. "|r")
            print("|cff888888  Env: |cffFFFFFF" .. DeathAnnounceDB.env_message .. "|r")
            print("|cff888888Tokens: {name}  {count}  {ordinal}  {killer}  {env_type}|r")
        else
            DeathAnnounceDB.message = template
            print("|cffFF4444[DeathAnnounce]|r Message updated.")
            print("|cff888888Preview: |cffFFFFFF" .. BuildMessage(DeathAnnounceDB.deaths) .. "|r")
        end

    ----------------------------------------------------
    else
        print("|cffFF4444[DeathAnnounce]|r |cffFFFFFFCommands:|r")
        print("  |cffFFD700/da set <number>|r         – Set your death count (do this once on first install)")
        print("  |cffFFD700/da message <template>|r   – Set custom mob-death message")
        print("  |cffFFD700/da message env <template>|r – Set custom env-death message")
        print("  |cffFFD700/da message|r               – Show current message templates")
        print("  |cffFFD700/da message reset|r         – Restore both messages to defaults")
        print("  |cffFFD700/da count|r                 – Print your current death count")
        print("  |cffFFD700/da test|r                  – Preview the message locally")
        print("  |cffFFD700/da send|r                  – Force-send to guild right now")
        print("  |cffFFD700/da enable|r                – Turn announcements on")
        print("  |cffFFD700/da disable|r               – Turn announcements off")
        print("|cff888888Mob tokens:  {name}  {count}  {ordinal}  {killer}|r")
        print("|cff888888Env tokens:  {name}  {count}  {ordinal}  {env_type}|r")
    end
end
