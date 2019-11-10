local menu = {}
menu.id = "RTV Chat Notifications"
menu.is_enabled = true

local col_prefix = Color(255, 50, 255, 255)
local col_bright = Color(255, 255, 255, 255)
local col_darker = Color(200, 200, 200, 255)

-- TODO use the convar storing the rtv_percentage to calculate the amount of players needed

function menu.OnRTVVoterAdded(ply)
	chat.AddText(col_prefix, "[PAM] ", col_bright, ply:GetName(), col_darker, " wants to rock the vote! (", col_bright, tostring(#PAM.players_wanting_rtv or "0"), col_darker, "/", col_bright , "0", col_darker, ")")
end

function menu.OnRTVVoterRemoved(ply)
	chat.AddText(col_prefix, "[PAM] ", col_bright, ply:GetName(), col_darker, " no longer wants to rock the vote! (", col_bright, tostring(#PAM.players_wanting_rtv or "0"), col_darker , "/", col_bright , "0", col_darker, ")")
end

hook.Add("PAM_Register_Client_Extensions", "PAM_Register_RTV_Chat_Notifications", function()
	PAM.RegisterExtension(menu)
end)
