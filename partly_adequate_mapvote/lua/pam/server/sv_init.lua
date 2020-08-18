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

-- add resources
resource.AddFile("materials/vgui/pam/img_missing.vmt")
resource.AddFile("materials/vgui/pam/ic_favorite.vmt")
resource.AddFile("materials/vgui/pam/ic_not_favorite.vmt")
resource.AddFile("materials/vgui/pam/ic_selected.vmt")
resource.AddFile("materials/vgui/pam/ic_not_selected.vmt")
