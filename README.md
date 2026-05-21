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

**DeathAnnounce** is a lightweight WoW addon for **patch 3.3.5a** that counts your deaths and announces them in Guild chat every time you die — with the running total and a fully customisable message.

```
⚔️  Arthas has died for the 69th time LOL
```

---

## 📜 Features

- 💀 **Auto-announces** every death to Guild chat
- ✏️ **Fully customisable message** with tokens for name, count, and ordinal
- 🔢 **Ordinal formatting** — 1st, 2nd, 3rd, 42nd... because details matter
- 💾 **SavedVariables** keep your count persistent across sessions
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

## ⚗️ First-Time Setup

On first install the counter starts at 0. Seed it with your real death total once and you're done forever:

1. Open **Achievements → Statistics** in-game and find your **Deaths** number
2. Type `/da set <that number>` in chat  ✅

That's it. The addon counts up from there on every death.

---

## ✏️ Custom Messages

Use `/da message <template>` to set whatever you want the guild to see.

**Available tokens** — the addon fills these in automatically, you just type them as-is:

| Token | Replaced with | Use when... |
|---|---|---|
| `{name}` | Your character's name | always |
| `{ordinal}` | Number + suffix — `42nd`, `1st`, `100th` | your sentence says *"for the Nth time"* |
| `{count}` | Plain number — `42`, `1`, `100` | your sentence says *"death #N"* or *"died N times"* |

> **`{ordinal}` vs `{count}` — which one?**
> Read your sentence out loud. If it sounds like *"for the forty-second time"* → use `{ordinal}`.
> If it sounds like *"death number forty-two"* or *"died forty-two times"* → use `{count}`.

**Examples:**
```
/da message {name} has died for the {ordinal} time LOL
→  Arthas has died for the 42nd time LOL        ← ordinal fits "for the Nth time"

/da message F in chat for {name}, death #{count}
→  F in chat for Arthas, death #42              ← count fits "#N"

/da message {name} has now died {count} times. Skill issue.
→  Arthas has now died 42 times. Skill issue.   ← count fits "N times"

/da message {name} bites the dust for the {ordinal} time RIP
→  Arthas bites the dust for the 42nd time RIP
```

Type `/da message` with no argument to see your current template.
Type `/da message reset` to go back to the default.

---

## 🧙 Slash Commands

All commands use `/deathannounce` or the short form `/da`.

| Command | Effect |
|---|---|
| `/da set <number>` | 🩸 Seed your real death count |
| `/da message <template>` | ✏️ Set a custom death message |
| `/da message` | 👁️ Show the current message template |
| `/da message reset` | 🔄 Restore the default message |
| `/da count` | 🔢 Print your current death count |
| `/da test` | 👁️ Preview the message locally (no guild spam) |
| `/da send` | 📢 Force-send to guild right now |
| `/da enable` | ✅ Turn announcements on |
| `/da disable` | ❌ Turn announcements off |

---

## 🏆 Example Output

```
[Guild] [Arthas]: Arthas has died for the 1st time LOL
[Guild] [Arthas]: Arthas has died for the 42nd time LOL
[Guild] [Arthas]: F in chat for Arthas, death #420
```

*Your raid leader has left the guild.*

---

## ❓ FAQ

**Q: Does this require any special permissions or server access?**
> Nope. It's a fully client-side addon. Install it like any other addon and it just works.

**Q: Will it spam if I die a lot in one fight?**
> Each `PLAYER_DEAD` event = one message. Die once, one message. Die to the same trash pack 4 times... that's on you.

**Q: What if I'm not in a guild?**
> The addon detects this and silently skips the announcement. No errors, no spam.

**Q: The death count is wrong!**
> Use `/da set <your real count>` to correct it at any time.

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
