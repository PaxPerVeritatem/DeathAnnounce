======================================
  DeathAnnounce  –  WoW 3.3.5a addon
======================================

Every time you die, this addon reads your "Total Deaths" statistic from
Achievements > Statistics and shouts it in Guild chat:

  Arthas has died for the 42nd time LOL


INSTALLATION
------------
1. Copy the "DeathAnnounce" folder into:
      World of Warcraft\Interface\AddOns\
2. Restart WoW (or /reload).
3. Make sure "DeathAnnounce" is ticked in the AddOns list on the char screen.


FINDING THE RIGHT STATISTIC ID
-------------------------------
The addon defaults to statistic ID 26 for "Deaths".
If your death count looks wrong, do this in-game:

  1. Open Achievements > Statistics and note your exact death number.
  2. Type:  /da findstat
     The addon will print every stat ID that has a numeric value.
  3. Match the number to your in-game value and note that ID.
  4. Type:  /da setstat <ID>   (e.g.  /da setstat 26)

The addon also keeps a local SavedVariables counter that stays in sync,
so it works even if the stat ID isn't found.


SLASH COMMANDS  (/deathannounce  or  /da)
-----------------------------------------
  /da enable        Turn guild announcements on  (default: on)
  /da disable       Turn guild announcements off
  /da test          Preview what the message looks like (local only)
  /da send          Force-send the current count to guild right now
  /da count         Print your current death count in chat
  /da setstat <id>  Set a custom achievement statistic ID
  /da findstat      Scan IDs 1-500 and list all with numeric values
