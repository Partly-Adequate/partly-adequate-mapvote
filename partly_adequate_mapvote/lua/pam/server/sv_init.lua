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

-- variables
-- stores the current voteable maps
PAM.maps = {}

-- stores the current votes
PAM.votes = {}

-- stores the players wanting to rock the vote
PAM.players_wanting_rtv = {}

-- add resources
resource.AddFile("materials/vgui/pam/img_missing.vmt")
resource.AddFile("materials/vgui/pam/ic_favorite.vmt")
resource.AddFile("materials/vgui/pam/ic_not_favorite.vmt")
resource.AddFile("materials/vgui/pam/ic_selected.vmt")
resource.AddFile("materials/vgui/pam/ic_not_selected.vmt")

-- map information
if not sql.TableExists("pam_maps") then
	sql.Query("CREATE TABLE pam_maps(id TEXT NOT NULL PRIMARY KEY, playcount INTEGER NOT NULL)")
end

if not sql.TableExists("pam_map_blacklist") then
	sql.Query("CREATE TABLE pam_map_blacklist(id TEXT NOT NULL PRIMARY KEY)")
end

if not sql.TableExists("pam_map_whitelist") then
	sql.Query("CREATE TABLE pam_map_whitelist(id TEXT NOT NULL PRIMARY KEY)")
end

if not sql.TableExists("pam_map_cooldowns") then
	sql.Query("CREATE TABLE pam_map_cooldowns(id TEXT NOT NULL PRIMARY KEY, heat INTEGER NOT NULL)")
end

-- convars
CreateConVar("pam_map_prefixes", "", {FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX, FCVAR_NOTIFY}, "When a map has at least one of the prefixes it is voteable.")
CreateConVar("pam_map_blacklist", "", {FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX, FCVAR_NOTIFY}, "When a map is listed here it won't be voteable.")
CreateConVar("pam_map_whitelist", "", {FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX, FCVAR_NOTIFY}, "When a map is listed here it will be voteable even if the prefixes don't match.")
CreateConVar("pam_map_cooldown", 3, {FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX, FCVAR_NOTIFY}, "Set the amount of rounds needed for a map to be voteable again.", 0)
CreateConVar("pam_max_maps", 15, {FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX, FCVAR_NOTIFY}, "Set the maximum number of maps. Set this to 0 to allow all maps.", 0)
