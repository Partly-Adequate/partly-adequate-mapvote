local extension = {}
extension.name = "rtv_chat_notifications"
extension.enabled = true

local col_prefix = Color(255, 50, 255, 255)
local col_bright = Color(255, 255, 255, 255)
local col_darker = Color(200, 200, 200, 255)

function extension.OnRTVVoterAdded(ply)
	local players_needed = math.ceil((GetGlobalFloat("pam_rtv_percentage") or 0) * player.GetCount())
	chat.AddText(col_prefix, "[PAM] ", col_bright, ply:GetName(), col_darker, " wants to rock the vote! (", col_bright, tostring(#PAM.players_wanting_rtv or "0"), col_darker, "/", col_bright , tostring(players_needed), col_darker, ")")
end

function extension.OnRTVVoterRemoved(ply)
	local players_needed = math.ceil((GetGlobalFloat("pam_rtv_percentage") or 0) * player.GetCount())
	chat.AddText(col_prefix, "[PAM] ", col_bright, ply:GetName(), col_darker, " no longer wants to rock the vote! (", col_bright, tostring(#PAM.players_wanting_rtv or "0"), col_darker , "/", col_bright , tostring(players_needed), col_darker, ")")
end

PAM.RegisterExtension(extension)
