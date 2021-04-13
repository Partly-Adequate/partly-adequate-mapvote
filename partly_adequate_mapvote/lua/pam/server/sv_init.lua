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

-- settings
local path = {"pam"}
local rtv_path = {"pam", "rtv"}
local server_settings = pacoman.server_settings
local vote_length_setting_id = "vote_length"
local rtv_enabled_setting_id = "is_enabled"
local rtv_delayed_setting_id = "is_delayed"
local rtv_percentage_setting_id = "percentage"

PAM.settings = {
	vote_length = server_settings:AddSetting(path, vote_length_setting_id, pacoman.P_TYPE_INTEGER, 30),
	rtv_enabled = server_settings:AddSetting(rtv_path, rtv_enabled_setting_id, pacoman.P_TYPE_BOOLEAN, false),
	rtv_delayed = server_settings:AddSetting(rtv_path, rtv_delayed_setting_id, pacoman.P_TYPE_BOOLEAN, false),
	rtv_percentage = server_settings:AddSetting(rtv_path, rtv_percentage_setting_id, pacoman.P_TYPE_PERCENTAGE, 0.6)
}

pacoman.server_settings:AddCallback(path, vote_length_setting_id, function(new_value)
	PAM.settings.vote_length = new_value
end)
pacoman.server_settings:AddCallback(rtv_path, rtv_enabled_setting_id, function(new_value)
	PAM.settings.rtv_enabled = new_value
end)
pacoman.server_settings:AddCallback(rtv_path, rtv_delayed_setting_id, function(new_value)
	PAM.settings.rtv_delayed = new_value
end)
pacoman.server_settings:AddCallback(rtv_path, rtv_percentage_setting_id, function(new_value)
	PAM.settings.rtv_percentage = new_value
end)
