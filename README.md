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

**DeathAnnounce** is a lightweight WoW addon for **patch 3.3.5a** that counts your deaths and announces them in Guild chat every time you die — including what killed you.

```
Arthas died for the 42nd time — killed by Kel'Thuzad (lvl 80)
Arthas died for the 43rd time — killed by Kel'Thuzad
Arthas died for the 44th time — Killed by being bad (fell off something)
```

---

## 📜 Features

- 💀 **Auto-announces** every death to Guild chat
- 🗡️ **Tracks your killer** — reads mob name and level from the combat log
- 🌋 **Environmental deaths** get their own message (falling, drowning, fire, lava and more)
- ✏️ **Fully customisable messages** with tokens for name, count, ordinal, killer, and env type
- 🔢 **Ordinal formatting** — 1st, 2nd, 3rd, 42nd...
- 💾 **SavedVariables** keep your count persistent across sessions
- 🔇 **Silently skips** if you're not in a guild

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

## ⚗️ First-Time Setup

On first install the counter starts at 0. Seed it with your real death total once and you're done forever:

1. Open **Achievements → Statistics** in-game and find your **Deaths** number
2. Type `/da set <that number>` in chat ✅

That's it. The addon counts up from there on every death.

---

## 🗡️ Killer Detection

DeathAnnounce reads the combat log to find out what killed you.

**Mob deaths:** The killer's name is always tracked. Level is pulled by matching the mob to your current target, focus, or nearby units — if it's available it gets included, if not it's simply left out.

```
killed by Kel'Thuzad (lvl 80)   ← level found
killed by Some Mob               ← level not available, cleanly omitted
```

**Environmental deaths:** WoW tells us exactly how you died, so each type gets its own flavour text:

| Cause | Message |
|---|---|
| Falling | fell off something |
| Drowning | forgot to breathe |
| Fatigue | swam too far out |
| Fire | stood in the fire |
| Lava | touched the lava |
| Slime | walked into the slime |

---

## ✏️ Custom Messages

Use `/da message <template>` for mob deaths and `/da message env <template>` for environmental deaths.

**Mob death tokens:**

| Token | Replaced with | Use when... |
|---|---|---|
| `{name}` | Your character's name | always |
| `{ordinal}` | Number + suffix — `42nd`, `1st`, `100th` | your sentence says *"for the Nth time"* |
| `{count}` | Plain number — `42`, `1`, `100` | your sentence says *"death #N"* or *"died N times"* |
| `{killer}` | Mob name + level if available | always — this is the whole killer string |

> **`{ordinal}` vs `{count}`** — read your sentence out loud.
> *"for the forty-second time"* → `{ordinal}`.
> *"death number forty-two"* / *"died forty-two times"* → `{count}`.

**Env death tokens:** same as above plus `{env_type}` (e.g. `fell off something`).

**Examples:**
```
/da message {name} died for the {ordinal} time — killed by {killer}
→  Arthas died for the 42nd time — killed by Kel'Thuzad (lvl 80)

/da message F in chat for {name}, death #{count} — RIP to {killer}
→  F in chat for Arthas, death #42 — RIP to Kel'Thuzad

/da message env {name} died for the {ordinal} time — {env_type} lmao
→  Arthas died for the 42nd time — fell off something lmao
```

Type `/da message` with no argument to see both current templates.
Type `/da message reset` to restore both to defaults.

---

## 🧙 Slash Commands

All commands use `/deathannounce` or the short form `/da`.

| Command | Effect |
|---|---|
| `/da set <number>` | 🩸 Seed your real death count |
| `/da message <template>` | ✏️ Set a custom mob-death message |
| `/da message env <template>` | 🌋 Set a custom env-death message |
| `/da message` | 👁️ Show current message templates |
| `/da message reset` | 🔄 Restore both messages to defaults |
| `/da count` | 🔢 Print your current death count |
| `/da test` | 👁️ Preview the message locally (no guild spam) |
| `/da send` | 📢 Force-send to guild right now |
| `/da enable` | ✅ Turn announcements on |
| `/da disable` | ❌ Turn announcements off |

---

## ❓ FAQ

**Q: Does this require any special permissions or server access?**
> Nope. Fully client-side. Install it like any other addon and it just works.

**Q: Will it spam if I die a lot in one fight?**
> Each `PLAYER_DEAD` event = one message. Die once, one message.

**Q: What if I'm not in a guild?**
> Silently skips. No errors, no spam.

**Q: The death count is wrong!**
> Use `/da set <your real count>` to correct it at any time.

**Q: The killer shows no level.**
> That's normal — it means the mob was already gone by the time the addon checked. The name always shows, level is bonus info.

---

## ⚔️ Compatibility

| | Status |
|---|---|
| WoW 3.3.5a (WotLK) | ✅ Fully supported |
| TukUI / ElvUI | ✅ No conflicts |
| Other death addons | ✅ No conflicts |

---

<div align="center">

*May your deaths be few, and your guild chat be spared.*

*...but probably not.*

**☠️ FOR THE HORDE ☠️** *(or Alliance, we don't judge)*

</div>
