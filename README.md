# 🏦 GuildBankTracker

GuildBankTracker is a lightweight World of Warcraft addon that logs and exports guild bank transactions with precision and clarity. It’s designed for guild leaders, officers, and curious members who want full visibility into who deposited or withdrew what—and when.

---

## ✨ Features

- 📜 Logs all item transactions from the guild bank
- 🧠 Deduplicates entries to avoid clutter
- 🕒 Displays logs with friendly "X hours ago" timestamps
- 📤 Exports logs to CSV format (saved in SavedVariables)
- 🔄 Manual guild sync support (pull-based, no spam)
- 💬 Simple slash commands for control

---

## 🧪 Slash Commands

| Command         | Description                                      |
|-----------------|--------------------------------------------------|
| `/gbt log`      | Show the 10 most recent transactions             |
| `/gbt_export`   | Export logs to CSV and save to SavedVariables    |
| `/gbt_sync`     | Request logs from other guild members (manual)   |

---

## 🗂️ SavedVariables

Logs and exports are saved to:
WTF\Account<YourAccount>\SavedVariables\GuildBankTracker.lua
The `exportCSV` field contains a spreadsheet-ready version of your logs.

---

## 🛠️ Installation

1. Download or clone this repository into your WoW AddOns folder:
2. Restart WoW or type `/reload` in-game.
3. Open the guild bank to trigger logging.

---

## 🤝 Syncing with Guild Members

To sync logs from other players:
- Make sure they also have the addon installed
- Type `/gbt_sync` to request their logs
- Only your client will store the synced data

> Syncing is manual and pull-based to avoid unnecessary data bloat.

---

## 📌 Roadmap

- [ ] Add filters (by player, item, date)
- [ ] Add batch sync throttling
- [ ] Add log pruning or archiving

---

## 🧑‍💻 Author

Created by **Bálint Kónya** with a little help from Copilot.  
Feedback, suggestions, and pull requests are welcome!

---

## 📜 License

This project is open source and free to use. Attribution appreciated but not required.
