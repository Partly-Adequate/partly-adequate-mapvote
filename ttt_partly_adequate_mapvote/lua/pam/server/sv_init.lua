-- server->all
util.AddNetworkString("PAM_Start")
-- client->server->all
util.AddNetworkString("PAM_Cancel")
-- client->server->all
util.AddNetworkString("PAM_Vote")
-- client->server->all
util.AddNetworkString("PAM_UnVote")
-- client->server
util.AddNetworkString("PAM_RTV")
-- server->all
util.AddNetworkString("PAM_Announce_Winner")

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
