local extension = {}
extension.name = "rtv_chat"
extension.enabled = true
extension.settings = {
	commands = "!rtv,rtv"
}

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
	if not GetConVar("pam_rtv_enabled"):GetBool() then return end
	if PAM.state != PAM.STATE_DISABLED then return end
    if ply != LocalPlayer() then return end

	local commands = string.Split(extension.settings.commands, ",")

	for i = 1, #commands do
		if text == commands[i] then
			PAM.VoteRTV();
			return true;
		end
	end
end)

PAM.RegisterExtension(extension)
