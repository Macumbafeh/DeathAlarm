DeathAlarm = {
    name = "Death Alarm",
    author = GetAddOnMetadata("DeathAlarm", "Author"),
    version = GetAddOnMetadata("DeathAlarm", "Version"),
    frame = CreateFrame("frame"),
}

local DeathAlarm = DeathAlarm

local DBVERSION = 20121023.2
local combat    = false
local frame     = DeathAlarm.frame
local lastcheck = 0

function DeathAlarm:Print(msg, ...)
    DEFAULT_CHAT_FRAME:AddMessage(msg, ...)
end

function DeathAlarm:UNIT_HEALTH(unit)
    if unit ~= "player" or not combat then
        return
    end

    local curHP = UnitHealth("player")
    local maxHP = UnitHealthMax("player")

    if curHP / maxHP > self:GetThreshold() or GetTime() < lastcheck + self:GetInterval() then
        return
    end

    lastcheck = GetTime()
    SendChatMessage(self:GetMessage(), self:GetChannel())
end

function DeathAlarm:ADDON_LOADED(name)
    if name ~= "DeathAlarm" then
        return
    end

    frame:UnregisterEvent("ADDON_LOADED")

    DeathAlarmDB = DeathAlarmDB and DeathAlarmDB.version == DBVERSION
    and DeathAlarmDB or {
        channel     = "AUTO",
        enable      = true,
        interval    = 3,
        message     = "* Heal me quickly! I am dying! *",
        threshold   = 0.2,
        version     = DBVERSION
    }

    self.db = DeathAlarmDB

    if self.db.enable then
        self:Enable()
    end
end

function DeathAlarm:PLAYER_REGEN_ENABLED() combat = false end
function DeathAlarm:PLAYER_REGEN_DISABLED() combat = true end

function DeathAlarm:Enable()
    self.db.enable = true
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    frame:RegisterEvent("UNIT_HEALTH")

    combat = InCombatLockdown()
end

function DeathAlarm:Disable()
    self.db.enable = false
    frame:UnregisterEvent("PLAYER_REGEN_ENABLED")
    frame:UnregisterEvent("PLAYER_REGEN_DISABLED")
    frame:UnregisterEvent("UNIT_HEALTH")
end

function DeathAlarm:GetChannel()
    local channel = self.db.channel

    if channel == "AUTO" then
        channel = UnitInRaid("player") and "RAID"
        or GetNumPartyMembers() > 0 and "PARTY" or "YELL"
    end

    return channel
end

function DeathAlarm:GetInterval() return self.db.interval end
function DeathAlarm:GetMessage() return self.db.message end
function DeathAlarm:GetThreshold() return self.db.threshold end

function DeathAlarm:SetChannel(channel) self.db.channel = channel end
function DeathAlarm:SetInterval(seconds) self.db.interval = tonumber(seconds) or 3 end
function DeathAlarm:SetMessage(msg) self.db.message = msg end
function DeathAlarm:SetThreshold(float) self.db.threshold = tonumber(float) or 0.2 end

function DeathAlarm:Init()
    frame:SetScript("OnEvent", function(frame, event, ...)
        self[event](self, ...)
    end)

    frame:RegisterEvent("ADDON_LOADED")
end

DeathAlarm:Init()
