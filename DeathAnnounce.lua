-------------------------------------------------------------------------------
--  DeathAnnounce.lua
--  Reads "Total Deaths" from Achievements > Statistics and announces it
--  in Guild chat every time the player dies.
--
--  WoW 3.3.5a (Wrath of the Lich King)
-------------------------------------------------------------------------------

local ADDON_NAME  = "DeathAnnounce"

-- Default achievement statistic ID for "Deaths" on the Statistics page.
-- If the number looks wrong, run:  /da findstat
-- and look for an ID whose value matches your in-game death count.
local DEFAULT_STAT_ID = 26

-- How long (seconds) to wait after PLAYER_DEAD before reading the stat.
-- The achievement stat sometimes needs a moment to tick up.
local ANNOUNCE_DELAY = 2.0

-------------------------------------------------------------------------------
-- SavedVariables defaults
-------------------------------------------------------------------------------
local DB_DEFAULTS = {
    statID   = DEFAULT_STAT_ID,   -- achievement statistic ID to pull deaths from
    deaths   = 0,                 -- local fallback counter (kept in sync)
    enabled  = true,              -- master on/off switch
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

-- Tries to read the death count from the achievement stat system.
-- Falls back to the locally-saved counter when the stat is unavailable.
local function GetDeathCount()
    local raw = GetStatistic(DeathAnnounceDB.statID)
    if raw and raw ~= "--" then
        local num = tonumber(raw)
        if num then
            -- Keep our local counter in sync so the fallback stays accurate.
            if num > DeathAnnounceDB.deaths then
                DeathAnnounceDB.deaths = num
            end
            return num
        end
    end
    return DeathAnnounceDB.deaths
end

-- Sends the death announcement to Guild chat (silently skipped if not in a guild).
local function AnnounceToGuild(count)
    if not IsInGuild() then
        print("|cffFF4444[DeathAnnounce]|r Not in a guild – announcement skipped.")
        return
    end
    local name    = UnitName("player")
    local suffix  = OrdinalSuffix(count)
    local message = name .. " has died for the " .. count .. suffix .. " time LOL"
    SendChatMessage(message, "GUILD")
end

-------------------------------------------------------------------------------
-- Main frame + timer
-------------------------------------------------------------------------------
local frame        = CreateFrame("Frame", "DeathAnnounceFrame")
local countdown    = -1   -- negative = idle
local deathQueued  = false

frame:SetScript("OnUpdate", function(self, elapsed)
    if not deathQueued then return end
    countdown = countdown - elapsed
    if countdown <= 0 then
        deathQueued = false
        countdown   = -1
        local count = GetDeathCount()
        AnnounceToGuild(count)
    end
end)

-------------------------------------------------------------------------------
-- Event handling
-------------------------------------------------------------------------------
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_DEAD")

frame:SetScript("OnEvent", function(self, event, ...)
    -----------------------------------------------------------------------
    if event == "ADDON_LOADED" then
        local name = ...
        if name ~= ADDON_NAME then return end

        -- Initialise SavedVariables
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
        -- Sync the local counter with the achievement stat (happens once per session).
        -- We OVERWRITE the local counter if the stat returns a valid number,
        -- so the count is always anchored to the real achievement value.
        local raw = GetStatistic(DeathAnnounceDB.statID)
        if raw and raw ~= "--" then
            local num = tonumber(raw)
            if num then
                DeathAnnounceDB.deaths = num   -- always trust the stat over our local copy
                print("|cffFF4444[DeathAnnounce]|r|cffFFFFFF Loaded.|r  "
                      .. "Synced from achievement stat: |cffFFD700" .. num
                      .. "|r  |cff888888(StatID " .. DeathAnnounceDB.statID .. ")|r")
            end
        else
            -- Stat ID is probably wrong – warn the user clearly.
            print("|cffFF4444[DeathAnnounce]|r|cffFF8800 WARNING:|r Stat ID "
                  .. DeathAnnounceDB.statID .. " returned no value.")
            print("|cffFF4444[DeathAnnounce]|r Run |cffFFD700/da findstat|r to find "
                  .. "your server's death stat ID, then |cffFFD700/da setstat <id>|r.")
            print("|cffFF4444[DeathAnnounce]|r Or manually seed your count: "
                  .. "|cffFFD700/da set <number>|r")
            print("|cffFF4444[DeathAnnounce]|r Current local count: |cffFFD700"
                  .. DeathAnnounceDB.deaths .. "|r")
        end
        print("|cff888888Type /da for commands.|r")

    -----------------------------------------------------------------------
    elseif event == "PLAYER_DEAD" then
        if not DeathAnnounceDB.enabled then return end

        -- Bump our local counter immediately so the fallback is ready.
        DeathAnnounceDB.deaths = DeathAnnounceDB.deaths + 1

        -- Schedule the guild message after a short delay.
        deathQueued = true
        countdown   = ANNOUNCE_DELAY
    end
end)

-------------------------------------------------------------------------------
-- Slash commands   /deathannounce  |  /da
-------------------------------------------------------------------------------
SLASH_DEATHANNOUNCE1 = "/deathannounce"
SLASH_DEATHANNOUNCE2 = "/da"

SlashCmdList["DEATHANNOUNCE"] = function(msg)
    msg = strtrim(msg:lower())

    ----------------------------------------------------
    if msg == "enable" then
        DeathAnnounceDB.enabled = true
        print("|cffFF4444[DeathAnnounce]|r Announcements |cff00FF00ENABLED|r.")

    ----------------------------------------------------
    elseif msg == "disable" then
        DeathAnnounceDB.enabled = false
        print("|cffFF4444[DeathAnnounce]|r Announcements |cffFF0000DISABLED|r.")

    ----------------------------------------------------
    elseif msg == "test" then
        -- Preview what the guild message will look like (printed locally only).
        local count  = GetDeathCount()
        local suffix = OrdinalSuffix(count)
        local name   = UnitName("player")
        print("|cffFF4444[DeathAnnounce]|r Preview (not sent to guild):")
        print("|cffFFD700" .. name .. " has died for the " .. count .. suffix .. " time LOL|r")

    ----------------------------------------------------
    elseif msg == "send" then
        -- Force-send to guild right now (useful for testing with guildmates).
        local count = GetDeathCount()
        AnnounceToGuild(count)

    ----------------------------------------------------
    elseif msg:match("^set %d+$") then
        local num = tonumber(msg:match("%d+"))
        DeathAnnounceDB.deaths = num
        print("|cffFF4444[DeathAnnounce]|r Death count manually set to |cffFFD700"
              .. num .. "|r.")
        print("Next death will announce: |cffFFFFFF" .. UnitName("player")
              .. " has died for the " .. (num+1) .. OrdinalSuffix(num+1) .. " time LOL|r")

    ----------------------------------------------------
    elseif msg == "sync" then
        local raw = GetStatistic(DeathAnnounceDB.statID)
        if raw and raw ~= "--" and tonumber(raw) then
            DeathAnnounceDB.deaths = tonumber(raw)
            print("|cffFF4444[DeathAnnounce]|r Synced from stat: |cffFFD700"
                  .. DeathAnnounceDB.deaths .. "|r")
        else
            print("|cffFF4444[DeathAnnounce]|r Stat ID "
                  .. DeathAnnounceDB.statID .. " returned: |cffFF8800"
                  .. tostring(raw) .. "|r  (try /da findstat)")
        end

    ----------------------------------------------------
    elseif msg == "count" then
        local count = GetDeathCount()
        print("|cffFF4444[DeathAnnounce]|r|cffFFFFFF Your total deaths: |cffFFD700"
              .. count .. "|r  (StatID " .. DeathAnnounceDB.statID .. ")")

    ----------------------------------------------------
    elseif msg:match("^setstat %d+$") then
        local id = tonumber(msg:match("%d+"))
        DeathAnnounceDB.statID = id
        local raw = GetStatistic(id)
        print("|cffFF4444[DeathAnnounce]|r Statistic ID set to |cffFFD700" .. id
              .. "|r  →  current value: |cffFFFFFF" .. tostring(raw) .. "|r")

    ----------------------------------------------------
    elseif msg == "findstat" then
        -- Scans statistic IDs 1-500 and prints those with numeric values.
        -- Compare the output to your in-game death count to find the right ID.
        print("|cffFF4444[DeathAnnounce]|r Scanning stat IDs 1-500 for numeric values …")
        local found = 0
        for i = 1, 500 do
            local raw = GetStatistic(i)
            if raw and raw ~= "--" and tonumber(raw) then
                print(string.format("  |cff888888ID|r |cffFFD700%3d|r  =  |cffFFFFFF%s|r", i, raw))
                found = found + 1
            end
        end
        print("|cffFF4444[DeathAnnounce]|r Scan done. " .. found .. " stats found.")
        print("Use |cffFFD700/da setstat <ID>|r to apply the correct one.")

    ----------------------------------------------------
    else
        print("|cffFF4444[DeathAnnounce]|r |cffFFFFFFCommands:|r")
        print("  |cffFFD700/da set <number>|r    -- Seed your real death count (fixes counting from 1)")
        print("  |cffFFD700/da sync|r             -- Re-sync count from achievement stat")
        print("  |cffFFD700/da enable|r           -- Turn announcements on")
        print("  |cffFFD700/da disable|r          -- Turn announcements off")
        print("  |cffFFD700/da test|r             -- Preview the death message locally")
        print("  |cffFFD700/da send|r             -- Force-send current count to guild")
        print("  |cffFFD700/da count|r            -- Print your current death count")
        print("  |cffFFD700/da setstat <id>|r     -- Override the achievement statistic ID")
        print("  |cffFFD700/da findstat|r          -- Scan and list all numeric stat IDs")
    end
end
