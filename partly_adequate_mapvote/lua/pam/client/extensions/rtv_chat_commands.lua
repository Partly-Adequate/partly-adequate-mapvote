local extension = {}
extension.name = "rtv_chat"
extension.enabled = true

local commands = "!rtv,rtv"

local col_prefix = Color(255, 50, 255, 255)
local col_bright = Color(255, 255, 255, 255)
local col_darker = Color(200, 200, 200, 255)

function extension.OnRTVVoterAdded(ply)
	local players_needed = math.ceil((GetConVar("pam_rtv_percentage"):GetFloat() or 0) * player.GetCount())
	chat.AddText(col_prefix, "[PAM] ", col_bright, ply:GetName(), col_darker, " wants to rock the vote! (", col_bright, tostring(PAM.rtv_voter_count or "0"), col_darker, "/", col_bright , tostring(players_needed), col_darker, ")")
end

function extension.OnRTVVoterRemoved(ply)
	local players_needed = math.ceil((GetConVar("pam_rtv_percentage"):GetFloat() or 0) * player.GetCount())
	chat.AddText(col_prefix, "[PAM] ", col_bright, ply:GetName(), col_darker, " no longer wants to rock the vote! (", col_bright, tostring(PAM.rtv_voter_count or "0"), col_darker , "/", col_bright , tostring(players_needed), col_darker, ")")
end

hook.Add( "OnPlayerChat", "PAM_RTV_Chat_Commands", function( ply, text, bTeam, bDead )
    if !extension.enabled then return end
	if not pacoman.server_settings:GetActiveValue({"pam", "rtv"}, "is_enabled") then return end
	if PAM.state != PAM.STATE_DISABLED then return end
    if ply != LocalPlayer() then return end

	local commands = string.Split(extension.settings.commands, ",")

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

PAM.extension_handler.RegisterExtension(extension)

local path = {"pam", extension.name}
local commands_setting_id = "commands"

pacoman.client_settings:AddSetting(path, commands_setting_id, pacoman.P_TYPE_STRING, commands)

commands = pacoman.client_settings:GetActiveValue(path, commands_setting_id)

pacoman.client_settings:AddCallback(path, commands_setting_id, function(new_value)
	commands = new_value
end)
