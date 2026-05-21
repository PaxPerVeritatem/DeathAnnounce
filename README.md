<div align="center">

![Shiifu](shiifu.jpg)

# ☠️ DeathAnnounce ☠️
### *"Because your guildmates NEED to know."*

![WoW Version](https://img.shields.io/badge/WoW-3.3.5a%20%E2%80%94%20Wrath%20of%20the%20Lich%20King-C41E3A?style=for-the-badge&logo=battle-dot-net&logoColor=white)
![Lua](https://img.shields.io/badge/Lua-5.1-2C2D72?style=for-the-badge&logo=lua&logoColor=white)
![License](https://img.shields.io/badge/License-Free%20Loot-gold?style=for-the-badge)
![Deaths](https://img.shields.io/badge/Deaths-too%20many-red?style=for-the-badge)

</div>

---

> *You just facepulled the whole room. Again.*
> *The raid leader is sighing. The healer already released.*
> *At least your guild will know exactly how many times this has happened.*

**DeathAnnounce** is a lightweight WoW addon for **patch 3.3.5a** that reads your **Total Deaths** straight from the Achievements → Statistics page and announces it in Guild chat every single time you die — with the running total, for maximum accountability.

```
⚔️  Arthas has died for the 69th time LOL
```

---

## 📜 Features

- 💀 **Auto-announces** every death to Guild chat
- 📊 **Reads directly** from your Achievements → Statistics page (real total, not a session counter)
- 🔢 **Ordinal formatting** — 1st, 2nd, 3rd, 42nd... because details matter
- 💾 **SavedVariables** keep your count persistent and in sync across sessions
- 🔇 **Silently skips** if you're not in a guild (no error spam)
- ⚙️ **Slash commands** for full control

---

## 🗡️ Installation

```
1. Download the zip and extract it
2. Drop the "DeathAnnounce" folder into:
   World of Warcraft/Interface/AddOns/
3. Restart WoW (or /reload)
4. Enable "DeathAnnounce" on the character select AddOns screen
5. Go die. Heroically.
```

---

## ⚗️ First-Time Setup (Important!)

The addon tries to sync your death count automatically from the achievement stat system on login. If the number looks wrong (counting from 1 instead of your real total), do this:

**Quick fix:**
1. Open **Achievements → Statistics** in-game and find your real **Deaths** number
2. Type `/da set <that number>` in chat
3. You're done ✅

**Proper fix (auto-sync forever after):**
1. Type `/da findstat` — scans stat IDs and prints all numeric values
2. Match one of them to your real death count
3. Type `/da setstat <id>` to lock it in
4. From now on it syncs automatically every login 🔄

---

## 🧙 Slash Commands

All commands use `/deathannounce` or the short form `/da`.

| Command | Effect |
|---|---|
| `/da set <number>` | 🩸 Seed your real death count (the most important one) |
| `/da sync` | 🔄 Re-sync count from achievement stat right now |
| `/da test` | 👁️ Preview what the message looks like (local only, no guild spam) |
| `/da send` | 📢 Force-send current count to guild |
| `/da count` | 🔢 Print your current death count |
| `/da enable` | ✅ Turn announcements on |
| `/da disable` | ❌ Turn announcements off |
| `/da setstat <id>` | 🔧 Override the achievement statistic ID |
| `/da findstat` | 🔍 Scan IDs 1–500 and list all with numeric values |

---

## 🏆 Example Output

```
[Guild] [Arthas]: Arthas has died for the 1st time LOL
[Guild] [Arthas]: Arthas has died for the 2nd time LOL
[Guild] [Arthas]: Arthas has died for the 100th time LOL
[Guild] [Arthas]: Arthas has died for the 420th time LOL
```

*Your raid leader has left the guild.*

---

## ❓ FAQ

**Q: Does this require any special permissions or server access?**
> Nope. It's a client-side addon. Install it like any other addon and it just works.

**Q: Will it spam if I die a lot in one fight?**
> Each `PLAYER_DEAD` event = one message. Die once, one message. Die to the same trash pack 4 times... well, that's on you.

**Q: What if I'm not in a guild?**
> The addon detects this and silently skips the announcement. No errors, no spam.

**Q: The death count starts at 1, not my real total!**
> See the [First-Time Setup](#️-first-time-setup-important) section above. Use `/da set <your real count>`.

---

## ⚔️ Compatibility

| Feature | Status |
|---|---|
| WoW 3.3.5a (WotLK) | ✅ Fully supported |
| Other patches | ❓ Untested |
| TukUI / ElvUI | ✅ No conflicts |
| Other death addons | ✅ No conflicts |

---

<div align="center">

*May your deaths be few, and your guild chat be spared.*

*...but probably not.*

**☠️ FOR THE HORDE ☠️** *(or Alliance, we don't judge)*

</div>
