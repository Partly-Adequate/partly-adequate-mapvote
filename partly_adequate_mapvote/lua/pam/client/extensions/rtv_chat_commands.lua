local extension = {}
extension.name = "rtv_chat"
extension.enabled = true

local commands = "!rtv,rtv"

local col_prefix = Color(255, 50, 255, 255)
local col_bright = Color(255, 255, 255, 255)
local col_darker = Color(200, 200, 200, 255)

local rtv_enabled
local rtv_percentage

function extension.OnRTVVoterAdded(ply)
	local players_needed = math.ceil((rtv_percentage or 0) * player.GetCount())
	chat.AddText(col_prefix, "[PAM] ", col_bright, ply:GetName(), col_darker, " wants to rock the vote! (", col_bright, tostring(PAM.rtv_voter_count or "0"), col_darker, "/", col_bright , tostring(players_needed), col_darker, ")")
end

function extension.OnRTVVoterRemoved(ply)
	local players_needed = math.ceil((rtv_percentage or 0) * player.GetCount())
	chat.AddText(col_prefix, "[PAM] ", col_bright, ply:GetName(), col_darker, " no longer wants to rock the vote! (", col_bright, tostring(PAM.rtv_voter_count or "0"), col_darker , "/", col_bright , tostring(players_needed), col_darker, ")")
end

hook.Add( "OnPlayerChat", "PAM_RTV_Chat_Commands", function( ply, text, bTeam, bDead )
    if !extension.enabled then return end
	if not rtv_enabled then return end
	if PAM.state != PAM.STATE_DISABLED then return end
    if ply != LocalPlayer() then return end

	local commands = string.Split(commands, ",")

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

local setting_namespace = PAM.setting_namespace:AddChild(extension.name)
local commands_setting = setting_namespace:AddSetting("commands", pacoman.TYPE_STRING, commands)

commands = commands_setting:GetActiveValue()

commands_setting:AddCallback("default", function(new_value)
	commands = new_value
end)

hook.Add("PacomanPostServerStateReceived", "rtv_chat_commands", function()
	local namespace = pacoman.server_settings:GetChild("pam")
	if not namespace then return end
	namespace = namespace:GetChild("rtv")
	if not namespace then return end

	local rtv_enabled_setting = namespace:GetSetting("is_enabled")
	local rtv_percentage_setting = namespace:GetSetting("percentage")

	if not rtv_enabled_setting or not rtv_percentage_setting then return end

	rtv_enabled = rtv_enabled_setting:GetActiveValue()
	rtv_percentage = rtv_percentage_setting:GetActiveValue()

	rtv_enabled_setting:AddCallback("rtv_chat_commands", function(new_value)
		rtv_enabled = new_value
	end)
	rtv_percentage_setting:AddCallback("rtv_chat_commands", function(new_value)
		rtv_percentage = new_value
	end)
end)
