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

--the default configuration
PAM.CONFIG_DEFAULT = {

	--length of voting time in seconds
	vote_length = 30,

	--prefixes for searching maps
	map_prefixes = {"ttt_"},

	--the amount of rounds needed for a map to appear again
	maps_before_revote = 3,

	--the amount of maps to select from
	max_map_amount = 15
}

--the default RTV configuration
PAM.RTV_CONFIG_DEFAULT = {
	--is rtv used
	is_enabled = false,

	--1 for all players, 0 for 1 player
	needed_player_percentage = 0.6,

	--length of rtv voting time in seconds
	vote_length = 30,

	--allows the rtv vote to contain all maps
	allow_all_maps = false;
}

--the current configuration
PAM.config = PAM.CONFIG_DEFAULT
PAM.rtv_config = PAM.RTV_CONFIG_DEFAULT

--the recently played maps
PAM.recent_maps = {}

--the currently voteable maps
PAM.maps = {}

--the current votes
PAM.votes = {}

--the play counts of each map
PAM.playcounts = {}

--the players wanting to rock the vote
PAM.players_wanting_rtv = {}

--set fallback metatable
setmetatable(PAM.config, PAM.CONFIG_DEFAULT)
setmetatable(PAM.rtv_config, PAM.RTV_CONFIG_DEFAULT)

--add resources
resource.AddFile("materials/vgui/pam_ic_missing.vmt")
resource.AddFile("materials/vgui/pam_ic_menu.vmt")
resource.AddFile("materials/vgui/pam_map_button.vmt")
resource.AddFile("materials/vgui/pam_ic_fav.vmt")
resource.AddFile("materials/vgui/pam_ic_nofav.vmt")

--create default config / load config
--TODO use convars instead
if not file.Exists("pam/config.txt", "DATA") then
	file.Write("pam/config.txt", util.TableToJSON(PAM.CONFIG_DEFAULT))
else
	local loadedConfig = util.JSONToTable(file.Read("pam/config.txt", "DATA"))
	if(loadedConfig.vote_length and loadedConfig.map_prefixes and loadedConfig.maps_before_revote and loadedConfig.max_map_amount) then
		PAM.config.vote_length = loadedConfig.vote_length
		PAM.config.map_prefixes = loadedConfig.map_prefixes
		PAM.config.maps_before_revote = loadedConfig.maps_before_revote
		PAM.config.max_map_amount = loadedConfig.max_map_amount
	else
		file.Write("pam/config.txt", util.TableToJSON(PAM.CONFIG_DEFAULT))
	end
end

if not file.Exists("pam/rtv_config.txt", "DATA") then
	file.Write("pam/rtv_config.txt", util.TableToJSON(PAM.RTV_CONFIG_DEFAULT))
else
	local loadedConfig = util.JSONToTable(file.Read("pam/rtv_config.txt", "DATA"))
	if(loadedConfig.is_enabled and loadedConfig.needed_player_percentage and loadedConfig.vote_length and loadedConfig.allow_all_maps) then
		PAM.rtv_config.is_enabled = loadedConfig.is_enabled
		PAM.rtv_config.needed_player_percentage = loadedConfig.needed_player_percentage
		PAM.rtv_config.vote_length = loadedConfig.vote_length
		PAM.rtv_config.allow_all_maps = loadedConfig.allow_all_maps
	else
		file.Write("pam/rtv_config.txt", util.TableToJSON(PAM.RTV_CONFIG_DEFAULT))
	end
end

--load map information
--TODO use database instead
if file.Exists("pam/recentmaps.txt", "DATA") then
	PAM.recent_maps = util.JSONToTable(file.Read("pam/recentmaps.txt", "DATA"))
end

if file.Exists("pam/playcounts.txt", "DATA") then
	PAM.playcounts = util.JSONToTable(file.Read("pam/playcounts.txt", "DATA"))
end
