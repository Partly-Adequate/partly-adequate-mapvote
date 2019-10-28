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
util.AddNetworkString("PAM_RTV")
-- server->all
util.AddNetworkString("PAM_Announce_Winner")

--the default configuration
PAM.CONFIG_DEFAULT = {

	--length of voting time in seconds
	VoteLength = 30,

	--prefixes for searching maps
	MapPrefixes = {"ttt_"},

	--the amount of rounds needed for a map to appear again
	MapsBeforeRevote = 3,

	--the amount of maps to select from
	MaxMapAmount = 15
}

--the default RTV configuration
PAM.RTV_CONFIG_DEFAULT = {
	--is rtv used
	IsEnabled = false,

	--1 for all players, 0 for 1 player
	NeededPlayerPercentage = 0.6,

	--length of rtv voting time in seconds
	VoteLength = 60,

	--allows the rtv vote to contain all maps
	AllowAllMaps = false;
}

--the current configuration
PAM.Config = {}
PAM.RTV_Config = {}

-- the recently played maps
PAM.RecentMaps = {}

-- the play counts of each map
PAM.Playcounts = {}

-- the players wanting to rock the vote
PAM.PlayersWantingRTV = {}

-- set fallback metatable
setmetatable(PAM.Config, PAM.CONFIG_DEFAULT)
setmetatable(PAM.RTV_Config, PAM.RTV_CONFIG_DEFAULT)

resource.AddFile("materials/vgui/ttt/pam_ic_missing.vmt")
resource.AddFile("materials/vgui/ttt/pam_ic_menu.vmt")
resource.AddFile("materials/vgui/ttt/pam_map_button.vmt")
resource.AddFile("materials/vgui/ttt/pam_ic_fav.vmt")
resource.AddFile("materials/vgui/ttt/pam_ic_nofav.vmt")

if file.Exists("pam/config.txt", "DATA") then
	PAM.Config = util.JSONToTable(file.Read("pam/config.txt", "DATA"))
end

if file.Exists("pam/rtv_config.txt", "DATA") then
	PAM.RTV_Config = util.JSONToTable(file.Read("pam/rtv_config.txt", "DATA"))
end

if file.Exists("pam/recentmaps.txt", "DATA") then
	PAM.RecentMaps = util.JSONToTable(file.Read("pam/recentmaps.txt", "DATA"))
end

if file.Exists("pam/playcounts.txt", "DATA") then
	PAM.Playcounts = util.JSONToTable(file.Read("pam/playcounts.txt", "DATA"))
end
