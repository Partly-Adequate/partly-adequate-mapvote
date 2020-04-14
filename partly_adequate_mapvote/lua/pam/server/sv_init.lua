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
CreateConVar("pam_vote_length", 30, {FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX, FCVAR_NOTIFY}, "Set the length of the voting time in seconds.", 0)
CreateConVar("pam_map_prefixes", "", {FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX, FCVAR_NOTIFY}, "When a map has at least one of the prefixes it is voteable.")
CreateConVar("pam_map_blacklist", "", {FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX, FCVAR_NOTIFY}, "When a map is listed here it won't be voteable.")
CreateConVar("pam_map_whitelist", "", {FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX, FCVAR_NOTIFY}, "When a map is listed here it will be voteable even if the prefixes don't match.")
CreateConVar("pam_map_cooldown", 3, {FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX, FCVAR_NOTIFY}, "Set the amount of rounds needed for a map to be voteable again.", 0)
CreateConVar("pam_max_maps", 15, {FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX, FCVAR_NOTIFY}, "Set the maximum number of maps. Set this to 0 to allow all maps.", 0)
CreateConVar("pam_rtv_enabled", 0, {FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX, FCVAR_NOTIFY}, "Set this to 1 to enable rtv or to 0 to disable rtv.")
CreateConVar("pam_rtv_percentage", 0.6, {FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX, FCVAR_NOTIFY}, "The percentage of players needed for rtv to start.", 0, 1)
CreateConVar("pam_rtv_delayed", 0, {FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX, FCVAR_NOTIFY}, "Set this to 1 to delay the votescreen to a more fitting moment. This is not supported by most gamemodes.")

-- global variables
SetGlobalInt("pam_vote_length", GetConVar("pam_vote_length"):GetInt());
SetGlobalBool("pam_rtv_enabled", GetConVar("pam_rtv_enabled"):GetBool());
SetGlobalFloat("pam_rtv_percentage", GetConVar("pam_rtv_percentage"):GetFloat());

cvars.AddChangeCallback("pam_vote_length", function(convar, old_val, new_val)
	SetGlobalInt("pam_vote_length", tonumber(new_val));
end)

cvars.AddChangeCallback("pam_rtv_enabled", function(convar, old_val, new_val)
	SetGlobalInt("pam_rtv_enabled", tobool(new_val));
end)

cvars.AddChangeCallback("pam_rtv_percentage", function(convar, old_val, new_val)
	SetGlobalInt("pam_rtv_percentage", tonumber(new_val));
end)
