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
resource.AddFile("materials/vgui/pam/img_missing.vmt")
resource.AddFile("materials/vgui/pam/ic_favorite.vmt")
resource.AddFile("materials/vgui/pam/ic_not_favorite.vmt")
resource.AddFile("materials/vgui/pam/ic_selected.vmt")
resource.AddFile("materials/vgui/pam/ic_not_selected.vmt")

--create default config / load config
--TODO use convars instead
if not file.Exists("pam/config.txt", "DATA") then
	file.Write("pam/config.txt", util.TableToJSON(PAM.CONFIG_DEFAULT))
else
	local loadedConfig = util.JSONToTable(file.Read("pam/config.txt", "DATA"))
	PAM.config.vote_length = loadedConfig["vote_length"] or PAM.CONFIG_DEFAULT.vote_length
	PAM.config.map_prefixes = loadedConfig["map_prefixes"] or PAM.CONFIG_DEFAULT.map_prefixes
	PAM.config.maps_before_revote = loadedConfig["maps_before_revote"] or PAM.CONFIG_DEFAULT.maps_before_revote
	PAM.config.max_map_amount = loadedConfig["max_map_amount"] or PAM.CONFIG_DEFAULT.max_map_amount
	file.Write("pam/config.txt", util.TableToJSON(PAM.config))
end

if not file.Exists("pam/rtv_config.txt", "DATA") then
	file.Write("pam/rtv_config.txt", util.TableToJSON(PAM.RTV_CONFIG_DEFAULT))
else
	local loadedConfig = util.JSONToTable(file.Read("pam/rtv_config.txt", "DATA"))
	PAM.rtv_config.is_enabled = loadedConfig["is_enabled"] or PAM.RTV_CONFIG_DEFAULT.is_enabled
	PAM.rtv_config.needed_player_percentage = loadedConfig["needed_player_percentage"] or PAM.RTV_CONFIG_DEFAULT.needed_player_percentage
	PAM.rtv_config.vote_length = loadedConfig["vote_length"] or PAM.RTV_CONFIG_DEFAULT.vote_length
	PAM.rtv_config.allow_all_maps = loadedConfig["allow_all_maps"] or PAM.RTV_CONFIG_DEFAULT.allow_all_maps
	file.Write("pam/rtv_config.txt", util.TableToJSON(PAM.rtv_config))
end

--load map information
--TODO use database instead
if file.Exists("pam/recentmaps.txt", "DATA") then
	PAM.recent_maps = util.JSONToTable(file.Read("pam/recentmaps.txt", "DATA"))
end

if file.Exists("pam/playcounts.txt", "DATA") then
	PAM.playcounts = util.JSONToTable(file.Read("pam/playcounts.txt", "DATA"))
end
