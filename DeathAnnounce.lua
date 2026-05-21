-------------------------------------------------------------------------------
--  DeathAnnounce.lua
--  Counts your deaths locally and announces them in Guild chat.
--  Set your starting count once with /da set <number>, then forget about it.
--
--  WoW 3.3.5a (Wrath of the Lich King)
-------------------------------------------------------------------------------

local ADDON_NAME    = "DeathAnnounce"
local ANNOUNCE_DELAY = 2.0   -- seconds to wait after death before sending

-------------------------------------------------------------------------------
-- SavedVariables defaults
-------------------------------------------------------------------------------
local DB_DEFAULTS = {
    deaths  = 0,     -- manually seeded + incremented each death
    enabled = true,  -- master on/off switch
    message = "{name} has died for the {count} time LOL",  -- custom message template
}

-------------------------------------------------------------------------------
-- Utility helpers
-------------------------------------------------------------------------------

-- Returns "st", "nd", "rd", or "th" for a given integer.
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

-- Builds the final message string from the template.
-- Supported tokens:  {name}   → character name
--                    {count}  → plain number  (e.g. 42)
--                    {ordinal}→ number + suffix (e.g. 42nd)
local function BuildMessage(count)
    local name    = UnitName("player")
    local ordinal = count .. OrdinalSuffix(count)
    local msg = DeathAnnounceDB.message
    msg = msg:gsub("{name}",    name)
    msg = msg:gsub("{count}",   tostring(count))
    msg = msg:gsub("{ordinal}", ordinal)
    return msg
end

-- Sends the death announcement to Guild chat (silently skipped if not in a guild).
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

frame:SetScript("OnEvent", function(self, event, ...)
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

    elseif event == "PLAYER_LOGIN" then
        print("|cffFF4444[DeathAnnounce]|r|cffFFFFFF Loaded.|r  "
              .. "Deaths on record: |cffFFD700" .. DeathAnnounceDB.deaths .. "|r")
        if DeathAnnounceDB.deaths == 0 then
            print("|cff888888First time? Set your count: |cffFFD700/da set <number>|r")
        end
        print("|cff888888Type /da for commands.|r")

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
    -- Preserve original casing for message command; lowercase everything else.
    local msg     = strtrim(input)
    local msgLow  = msg:lower()

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
        local preview = BuildMessage(num + 1)
        print("|cff888888Next death preview: |cffFFFFFF" .. preview .. "|r")

    ----------------------------------------------------
    elseif msgLow == "count" then
        print("|cffFF4444[DeathAnnounce]|r Deaths on record: |cffFFD700"
              .. DeathAnnounceDB.deaths .. "|r")

    ----------------------------------------------------
    elseif msgLow == "test" then
        local preview = BuildMessage(DeathAnnounceDB.deaths)
        print("|cffFF4444[DeathAnnounce]|r Preview (not sent to guild):")
        print("|cffFFD700" .. preview .. "|r")

    ----------------------------------------------------
    elseif msgLow == "send" then
        AnnounceToGuild(DeathAnnounceDB.deaths)

    ----------------------------------------------------
    elseif msg:lower():match("^message ") then
        -- /da message <template>   — everything after "message " is the new template
        local template = strtrim(msg:sub(9))  -- strip "message " prefix (8 chars + space)
        if template == "" then
            print("|cffFF4444[DeathAnnounce]|r Current message template:")
            print("|cffFFFFFF" .. DeathAnnounceDB.message .. "|r")
            print("|cff888888Tokens: {name}  {count}  {ordinal}|r")
        else
            DeathAnnounceDB.message = template
            print("|cffFF4444[DeathAnnounce]|r Message template updated.")
            print("|cff888888Preview: |cffFFFFFF" .. BuildMessage(DeathAnnounceDB.deaths) .. "|r")
        end

    ----------------------------------------------------
    elseif msgLow == "message reset" then
        DeathAnnounceDB.message = DB_DEFAULTS.message
        print("|cffFF4444[DeathAnnounce]|r Message reset to default.")

    ----------------------------------------------------
    else
        print("|cffFF4444[DeathAnnounce]|r |cffFFFFFFCommands:|r")
        print("  |cffFFD700/da set <number>|r        – Set your death count (do this once on first install)")
        print("  |cffFFD700/da message <template>|r  – Set a custom death message")
        print("  |cffFFD700/da message|r              – Show current message template")
        print("  |cffFFD700/da message reset|r        – Restore default message")
        print("  |cffFFD700/da count|r                – Print your current death count")
        print("  |cffFFD700/da test|r                 – Preview the message locally")
        print("  |cffFFD700/da send|r                 – Force-send to guild right now")
        print("  |cffFFD700/da enable|r               – Turn announcements on")
        print("  |cffFFD700/da disable|r              – Turn announcements off")
        print("|cff888888Message tokens: {name}  {count}  {ordinal}|r")
        print("|cff888888Example: /da message {name} bites the dust for the {ordinal} time RIP|r")
    end
end
