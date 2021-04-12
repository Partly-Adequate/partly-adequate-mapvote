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

PAM.settings = {
	vote_length = 30,
	rtv_enabled = false,
	rtv_delayed = false,
	rtv_percentage = 0.6
}

-- settings
local path = {"pam"}
local rtv_path = {"pam", "rtv"}
local vote_length_setting_id = "vote_length"
local rtv_enabled_setting_id = "is_enabled"
local rtv_delayed_setting_id = "is_delayed"
local rtv_percentage_setting_id = "percentage"

pacoman.server_settings:AddSetting(path, vote_length_setting_id, pacoman.P_TYPE_INTEGER, PAM.settings.vote_length)
pacoman.server_settings:AddSetting(rtv_path, rtv_enabled_setting_id, pacoman.P_TYPE_BOOLEAN, PAM.settings.rtv_enabled)
pacoman.server_settings:AddSetting(rtv_path, rtv_delayed_setting_id, pacoman.P_TYPE_BOOLEAN, PAM.settings.rtv_delayed)
pacoman.server_settings:AddSetting(rtv_path, rtv_percentage_setting_id, pacoman.P_TYPE_PERCENTAGE, PAM.settings.rtv_percentage)

PAM.settings = {
	vote_length = pacoman.server_settings:GetActiveValue({"pam"}, "vote_length"),
	rtv_enabled = pacoman.server_settings:GetActiveValue({"pam", "rtv"}, "is_enabled"),
	rtv_delayed = pacoman.server_settings:GetActiveValue({"pam", "rtv"}, "is_delayed"),
	rtv_percentage = pacoman.server_settings:GetActiveValue({"pam", "rtv"}, "percentage")
}

pacoman.server_settings:AddCallback({"pam"}, "vote_length", function(new_value)
	PAM.settings.vote_length = new_value
end)
pacoman.server_settings:AddCallback({"pam", "rtv"}, "is_enabled", function(new_value)
	PAM.settings.rtv_enabled = new_value
end)
pacoman.server_settings:AddCallback({"pam", "rtv"}, "is_delayed", function(new_value)
	PAM.settings.rtv_delayed = new_value
end)
pacoman.server_settings:AddCallback({"pam", "rtv"}, "percentage", function(new_value)
	PAM.settings.rtv_percentage = new_value
end)
