local name = "rtv"
PAM_EXTENSION.name = name
PAM_EXTENSION.enabled = true

local col_prefix = Color(255, 50, 255, 255)
local col_bright = Color(255, 255, 255, 255)
local col_darker = Color(200, 200, 200, 255)

local rtv_voters = {}
local rtv_voter_count = 0

local commands_setting = PAM.setting_namespace:AddChild(name):AddSetting("commands", pacoman.TYPE_STRING, "!rtv,rtv,!rock the vote,rock the vote")
local rtv_enabled_setting
local rtv_percentage_setting

hook.Add("PacomanPostServerStateReceived", "rtv_chat_commands", function()
	local namespace = pacoman.server_settings:GetChild("pam")
	if not namespace then return end
	namespace = namespace:GetChild("rtv")
	if not namespace then return end

	rtv_enabled_setting = namespace:GetSetting("enabled")
	rtv_percentage_setting = namespace:GetSetting("percentage")
end)

-- adds an rtv voter to the clients information
local function AddRTVVoter(ply)
	if not IsValid(ply) then return end

	rtv_voters[ply:SteamID()] = true
	rtv_voter_count = rtv_voter_count + 1

	PAM.extension_handler.RunEvent("OnRTVVoterAdded", ply)
end

-- removes an rtv voter from the clients information
local function RemoveRTVVoter(ply)
	if not IsValid(ply) then return end

	rtv_voters[ply:SteamID()] = nil
	rtv_voter_count = rtv_voter_count - 1

	PAM.extension_handler.RunEvent("OnRTVVoterRemoved", ply)
end

-- resets information on all rtv voters
local function ResetRTVVoters()
	rtv_voters = {}
	rtv_voter_count = 0

	PAM.extension_handler.RunEvent("OnRTVVotersReset", ply)
end

net.Receive("PAM_VoteRTV", function(len)
	AddRTVVoter(net.ReadEntity())
end)

net.Receive("PAM_UnVoteRTV", function(len)
	RemoveRTVVoter(net.ReadEntity())
end)

net.Receive("PAM_ResetRTV", function(len)
	ResetRTVVoters(ply)
end)

function PAM_EXTENSION:OnRTVVoterAdded(ply)
	print("callback called")
	local players_needed = math.ceil((rtv_percentage_setting and rtv_percentage_setting:GetActiveValue() or 0) * player.GetCount())
	chat.AddText(col_prefix, "[PAM] ", col_bright, ply:GetName(), col_darker, " wants to rock the vote! (", col_bright, tostring(rtv_voter_count or "0"), col_darker, "/", col_bright , tostring(players_needed), col_darker, ")")
end

function PAM_EXTENSION:OnRTVVoterRemoved(ply)
	local players_needed = math.ceil((rtv_percentage_setting and rtv_percentage_setting:GetActiveValue() or 0) * player.GetCount())
	chat.AddText(col_prefix, "[PAM] ", col_bright, ply:GetName(), col_darker, " no longer wants to rock the vote! (", col_bright, tostring(rtv_voter_count or "0"), col_darker , "/", col_bright , tostring(players_needed), col_darker, ")")
end

function PAM_EXTENSION:OnInitialize()
	hook.Add("OnPlayerChat", "PAM_RTV_Chat_Commands", function(ply, text)
		if !self.enabled then return end
		if not rtv_enabled_setting or not rtv_enabled_setting:GetActiveValue() then return end
		if PAM.state != PAM.STATE_DISABLED then return end
		if ply != LocalPlayer() then return end

		local commands = string.Split(commands_setting:GetActiveValue(), ",")

		for i = 1, #commands do
			if text == commands[i] then
				if rtv_voters[ply:SteamID()] then
					net.Start("PAM_UnVoteRTV")
					net.SendToServer()
				else
					net.Start("PAM_VoteRTV")
					net.SendToServer()
				end
				return true
			end
		end
	end)

	--toggle rtv participation
	concommand.Add("pam_rtv", function(ply, cmd, args, arg_str)
		if self.enabled and rtv_enabled_setting and rtv_enabled_setting:GetActiveValue() and PAM.state == PAM.STATE_DISABLED then
			if rtv_voters[ply:SteamID()] then
				net.Start("PAM_UnVoteRTV")
				net.SendToServer()
			else
				net.Start("PAM_VoteRTV")
				net.SendToServer()
			end
		end
	end)
end

net.Receive("PAM_RTVStateRequest", function(len)
	local count = net.ReadUInt(32)
	for i = 1, count do
		AddRTVVoter(net.ReadEntity())
	end
end)

hook.Add("InitPostEntity", "PAM_RTVStateRequest", function()
	net.Start("PAM_RTVStateRequest")
	net.SendToServer()
end)
