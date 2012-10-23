local DeathAlarm = DeathAlarm

local ValidChannels = {
    AUTO    = true,
    GUILD   = true,
    PARTY   = true,
    RAID    = true,
    RAID_WARNING = true,
    SAY     = true,
    YELL    = true,
}

local function print(...) DEFAULT_CHAT_FRAME:AddMessage(...) end

SLASH_DEATHALARM1 = "/deathalarm"
SLASH_DEATHALARM2 = "/da"

SlashCmdList.DEATHALARM = function(msg) DeathAlarm:OnSlashCmd(msg) end

function DeathAlarm:OnSlashCmd(msg)
    local cmd, param = msg:match("(%S*)%s*(.*)")

    if cmd == "on" then
        self:Enable()
        self:Print("Enabled.")

    elseif cmd == "off" then
        self:Disable()
        self:Print("Disabled.")

    elseif cmd == "msg" then
        self:SetMessage(param)
        self:Print(("Message set to %q."):format(self:GetMessage()))

    elseif cmd == "interval" then
        self:SetInterval(param)
        self:Print(("Interval set to %.2f s."):format(self:GetInterval()))

    elseif cmd == "threshold" then
        self:SetThreshold(param)
        self:Print(("Threshold set to %.2f (= %.2f%% HP)."):format(self:GetThreshold(), self:GetThreshold() * 100))

    elseif cmd == "channel" then
        if ValidChannels[param:upper()] then
            self:SetChannel(param:upper())
            self:Print(("Channel set to %s."):format(self.db.channel:lower()))
        end

    else
        self:Print(("Version %s usage:"):format(self.version))
        print("/da { on || off || msg || interval || threshold || channel }")
        print("   /da on || off - Toggles addon on/off.")
        print("   /da msg <message> - Message to spam when below HP threshold.")
        print("   /da interval <seconds> - Minimum interval between alerts.")
        print("   /da threshold <float> - Current to max health proportion below which the alert will be send.")
        print("   /da channel <name> - Output channel for alerts. AUTO channel changes according to group type.")
    end
end
