local addonName = ...
local frame = CreateFrame("Frame")

GuildBankTrackerDB = GuildBankTrackerDB or {
    transactions = {},
    seen = {},
    exportCSV = ""
}


-- Register events
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("GUILDBANKLOG_UPDATE")

-- Event handler
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local loadedAddonName = ...
        if loadedAddonName == addonName then
            print("GuildBankTracker loaded.")
        end

    elseif event == "GUILDBANKLOG_UPDATE" then
        GuildBankTracker_ScanBankLog()

    elseif event == "CHAT_MSG_ADDON" then
        local prefix, message, channel, sender = ...
        if prefix == "GBT" and sender ~= UnitName("player") then
            local entry = GuildBankTracker_Deserialize(message)
            local key = GuildBankTracker_GenerateKey(entry)
            if not GuildBankTrackerDB.seen[key] then
                table.insert(GuildBankTrackerDB.transactions, entry)
                GuildBankTrackerDB.seen[key] = true
                print("GuildBankTracker: Received transaction from " .. sender)
            end
        end
    end
end)

local function SafeTimestamp(year, month, day, hour)
    if not (year and month and day and hour) then
        local now = date("*t")
        return string.format("%04d-%02d-%02d %02d:%02d", now.year, now.month, now.day, now.hour, now.min)
    end
    return string.format("%04d-%02d-%02d %02d:00", year, month + 1, day, hour)
end

local function TimeAgo(timestamp)
    if not timestamp or timestamp == "Unknown" then return "some time ago" end

    local pattern = "(%d+)%-(%d+)%-(%d+) (%d+):(%d+)"
    local y, m, d, h, min = timestamp:match(pattern)
    if not y then return "some time ago" end

    local t = time({
        year = tonumber(y),
        month = tonumber(m),
        day = tonumber(d),
        hour = tonumber(h),
        min = tonumber(min),
        sec = 0
    })

    local diff = time() - t
    if diff < 60 then
        return "just now"
    elseif diff < 3600 then
        return math.floor(diff / 60) .. " minutes ago"
    elseif diff < 86400 then
        return math.floor(diff / 3600) .. " hours ago"
    else
        return math.floor(diff / 86400) .. " days ago"
    end
end


-- Scan and store transactions
function GuildBankTracker_ScanBankLog()
    for tab = 1, GetNumGuildBankTabs() do
        local numTransactions = GetNumGuildBankTransactions(tab)
        for i = 1, numTransactions do
            local type, name, itemLink, count, tabIndex, year, month, day, hour = GetGuildBankTransaction(tab, i)

            -- Format timestamp
            timestamp = SafeTimestamp(year, month, day, hour)

            -- Build readable action
            local action = ""
            if type == "deposit" then
                action = "Deposited"
            elseif type == "withdraw" then
                action = "Withdrew"
            elseif type == "move" then
                action = "Moved"
            elseif type == "money" then
                action = "Changed gold"
            else
                action = type
            end

            -- Build entry
            local entry = {
                type = type,
                action = action,
                name = name,
                item = itemLink or "",
                count = count or 0,
                tab = tabIndex or tab,
                timestamp = timestamp
            }

            -- Generate unique key
            local key = GuildBankTracker_GenerateKey(entry)
            if not GuildBankTrackerDB.seen[key] then
                table.insert(GuildBankTrackerDB.transactions, entry)
                GuildBankTrackerDB.seen[key] = true
            end
        end
    end
    print("GuildBankTracker: New transactions scanned.")
end

function GuildBankTracker_GenerateKey(entry)
    return table.concat({
        entry.type or "",
        entry.name or "",
        entry.item or "",
        entry.count or 0,
        entry.tab or 0,
        entry.timestamp or ""
    }, "::")
end

local function StripItemLink(link)
    return link:match("%[(.-)%]") or link
end

SLASH_GBT1 = "/gbt"
SlashCmdList["GBT"] = function(msg)
    msg = msg:lower()
    if msg == "log" then
        local logs = GuildBankTrackerDB.transactions
        print("Last 10 Guild Bank Transactions:")
        for i = math.max(1, #logs - 9), #logs do
            local e = logs[i]
            print(string.format("%s %s x%d in Tab %d by %s (%s)",
                e.name,
                e.action,
                e.count,
                e.tab,
                e.item ~= "" and e.item or "(gold)",
                TimeAgo(e.timestamp)
            ))
        end
    else
        print("Use /gbt log to print the last 10 transactions.")
    end
end

SLASH_GBTEXPORT1 = "/gbt_export"
SlashCmdList["GBTEXPORT"] = function()
    local lines = { "Timestamp,Action,Item,Count,Tab,Player" }

    for _, e in ipairs(GuildBankTrackerDB.transactions) do
        local line = string.format("%s,%s,%s,%d,%d,%s",
            TimeAgo(e.timestamp),
            e.action,
            StripItemLink(e.item):gsub(",", ""),  -- strip commas to avoid CSV issues
            e.count,
            e.tab,
            e.name
        )
        table.insert(lines, line)
        print(line)  -- still print to chat
    end

    -- Save to SavedVariables
    GuildBankTrackerDB.exportCSV = table.concat(lines, "\n")
    print("GuildBankTracker: Export saved to SavedVariables.")
end

