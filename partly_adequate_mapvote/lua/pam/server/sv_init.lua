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
-- server->all
util.AddNetworkString("PAM_Announce_Winner")
-- server->all
util.AddNetworkString("PAM_Gamemode_Changed")

-- pick counts
if not sql.TableExists("pam_pickcounts") then
	sql.Query("CREATE TABLE pam_pickcounts(id TEXT NOT NULL PRIMARY KEY, pickcount INTEGER NOT NULL)")
end

-- game properties
-- the current gamemode
local gp_gamemode = pacoman.RegisterGameProperty("gamemode", pacoman.TYPE_STRING, engine.ActiveGamemode())
hook.Add("PAM_OnGamemodeChanged", "PAM_UpdateGamemodeProperty", function(gamemode_name)
	gp_gamemode:SetValue(gamemode_name)
end)
-- the current map
pacoman.RegisterGameProperty("map", pacoman.TYPE_STRING, game.GetMap())
-- random value assignet at the start of each game
pacoman.RegisterGameProperty("game_random", pacoman.TYPE_PERCENTAGE, math.random())
-- random value assigned at the end of each round
local gp_round_random = pacoman.RegisterGameProperty("round_random", pacoman.TYPE_PERCENTAGE, math.random())
hook.Add("PAM_OnRoundEnded", "PAM_UpdateRoundRandomProperty", function()
	gp_round_random:SetValue(math.random())
end)

-- settings
local setting_namespace = pacoman.server_settings:AddChild("pam")

PAM.setting_namespace = setting_namespace
PAM.vote_length = setting_namespace:AddSetting("vote_length", pacoman.TYPE_INTEGER, 30)
