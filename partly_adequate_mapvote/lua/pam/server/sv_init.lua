-- ulx->server
-- server->all
util.AddNetworkString("PAM_Start")
-- ulx->server
-- server->all
util.AddNetworkString("PAM_Cancel")
-- client->server
-- server->all
util.AddNetworkString("PAM_Vote")
-- client->server
-- server->all
util.AddNetworkString("PAM_UnVote")
-- client->server
-- server->all
util.AddNetworkString("PAM_VoteRTV")
-- client->server
-- server->all
util.AddNetworkString("PAM_UnVoteRTV")
-- server->all
util.AddNetworkString("PAM_Announce_Winner")
-- server->all
util.AddNetworkString("PAM_Gamemode_Changed")

-- pick counts
if not sql.TableExists("pam_pickcounts") then
	sql.Query("CREATE TABLE pam_pickcounts(id TEXT NOT NULL PRIMARY KEY, pickcount INTEGER NOT NULL)")
end

local gp_gamemode = pacoman.RegisterGameProperty("gamemode", pacoman.TYPE_STRING, engine.ActiveGamemode())
hook.Add("PAM_OnGamemodeChanged", "PAM_UpdateGamemodeProperty", function(gamemode_name)
	gp_gamemode:SetValue(gamemode_name)
end)


local setting_namespace = pacoman.server_settings:AddChild("pam")
local rtv_namespace = setting_namespace:AddChild("rtv")

PAM.setting_namespace = setting_namespace
PAM.vote_length = setting_namespace:AddSetting("vote_length", pacoman.TYPE_INTEGER, 30)
local rtv_enabled_setting = rtv_namespace:AddSetting("is_enabled", pacoman.TYPE_BOOLEAN, false)
local rtv_delayed_setting = rtv_namespace:AddSetting("is_delayed", pacoman.TYPE_BOOLEAN, false)
local rtv_percentage_setting = rtv_namespace:AddSetting("percentage", pacoman.TYPE_PERCENTAGE, 0.6)

PAM.settings = {
	rtv_enabled = rtv_enabled_setting:GetActiveValue(),
	rtv_delayed = rtv_delayed_setting:GetActiveValue(),
	rtv_percentage = rtv_percentage_setting:GetActiveValue()
}

rtv_enabled_setting:AddCallback("default", function(new_value)
	PAM.settings.rtv_enabled = new_value
end)
rtv_delayed_setting:AddCallback("default", function(new_value)
	PAM.settings.rtv_delayed = new_value
end)
rtv_percentage_setting:AddCallback("default", function(new_value)
	PAM.settings.rtv_percentage = new_value
end)
