local name = "rtv_chat"
PAM_EXTENSION.name = name
PAM_EXTENSION.enabled = true

local commands_setting = PAM.setting_namespace:AddChild(name):AddSetting("commands", pacoman.TYPE_STRING, "!rtv,rtv,!rock the vote,rock the vote")
local rtv_enabled_setting
local rtv_percentage_setting

local col_prefix = Color(255, 50, 255, 255)
local col_bright = Color(255, 255, 255, 255)
local col_darker = Color(200, 200, 200, 255)


function PAM_EXTENSION:OnRTVVoterAdded(ply)
	local players_needed = math.ceil((rtv_percentage_setting and rtv_percentage_setting:GetActiveValue() or 0) * player.GetCount())
	chat.AddText(col_prefix, "[PAM] ", col_bright, ply:GetName(), col_darker, " wants to rock the vote! (", col_bright, tostring(PAM.rtv_voter_count or "0"), col_darker, "/", col_bright , tostring(players_needed), col_darker, ")")
end

function PAM_EXTENSION:OnRTVVoterRemoved(ply)
	local players_needed = math.ceil((rtv_percentage_setting and rtv_percentage_setting:GetActiveValue() or 0) * player.GetCount())
	chat.AddText(col_prefix, "[PAM] ", col_bright, ply:GetName(), col_darker, " no longer wants to rock the vote! (", col_bright, tostring(PAM.rtv_voter_count or "0"), col_darker , "/", col_bright , tostring(players_needed), col_darker, ")")
end

function PAM_EXTENSION:OnInitialize()
	hook.Add( "OnPlayerChat", "PAM_RTV_Chat_Commands", function( ply, text, bTeam, bDead )
		if !self.enabled then return end
		if not rtv_enabled_setting or not rtv_enabled_setting:GetActiveValue() then return end
		if PAM.state != PAM.STATE_DISABLED then return end
		if ply != LocalPlayer() then return end

		local commands = string.Split(commands_setting:GetActiveValue(), ",")

		for i = 1, #commands do
			if text == commands[i] then
				if PAM.WantsRTV(ply) then
					PAM.UnVoteRTV()
				else
					PAM.VoteRTV()
				end
				return true
			end
		end
	end)
end

hook.Add("PacomanPostServerStateReceived", "rtv_chat_commands", function()
	local namespace = pacoman.server_settings:GetChild("pam")
	if not namespace then return end
	namespace = namespace:GetChild("rtv")
	if not namespace then return end

	rtv_enabled_setting = namespace:GetSetting("is_enabled")
	rtv_percentage_setting = namespace:GetSetting("percentage")
end)
