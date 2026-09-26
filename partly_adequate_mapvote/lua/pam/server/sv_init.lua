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
-- client->server
-- server->client
util.AddNetworkString("PAM_StateRequest")

-- pick counts
if not sql.TableExists("pam_pickcounts") then
	sql.Query("CREATE TABLE pam_pickcounts(id TEXT NOT NULL PRIMARY KEY, pickcount INTEGER NOT NULL)")
end

local ply_count = 0

-- settings
PAM.setting_namespace = pacoman.server_settings:AddChild("pam")

hook.Add("PACOMAN_Initialized", "PAM_PACOMAN_Initialized",
	function()
		local setting_namespace = PAM.setting_namespace

		PAM.vote_length = setting_namespace:AddSetting("vote_length", pacoman.TYPE_INTEGER, 30, "The length of the voting time in seconds.")
		PAM.initial_vote_type = setting_namespace:AddSetting("initial_vote_type", PAM.vote_type_enum, "map", "The first type of vote that is held when pam starts.")

		-- initial game property values
		PAM.gp_game_random:SetValue(math.random())
		PAM.gp_map:SetValue(game.GetMap())
		PAM.gp_vote_type:SetValue(PAM.initial_vote_type:GetActiveValue())
		PAM.gp_gamemode:SetValue(engine.ActiveGamemode())
		PAM.gp_round_random:SetValue(math.random())
		PAM.gp_player_count:SetValue(ply_count)
	end
)

hook.Add("PAM_OnGamemodeChanged", "PAM_UpdateGamemodeProperty", function(gamemode_name)
	PAM.gp_gamemode:SetValue(gamemode_name)
end)
hook.Add("PAM_OnRoundEnded", "PAM_UpdateRoundRandomProperty", function()
	PAM.gp_round_random:SetValue(math.random())
end)
hook.Add("PlayerConnect", "PAM_UpdatePlayerCountPropertyOnConnect", function(ply)
	ply_count = ply_count + 1

	PAM.gp_player_count:SetValue(ply_count)
end)
hook.Add("PlayerDisconnected", "PAM_UpdatePlayerCountPropertyOnDisconnect", function(ply)
	ply_count = ply_count - 1

	PAM.gp_player_count:SetValue(ply_count)
end)
