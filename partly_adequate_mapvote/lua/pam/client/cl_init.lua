PAM.vote_ends_at = 0
PAM.favorite_maps = {}
PAM.vote_menu = nil
PAM.menu_manager = nil
PAM.players_wanting_rtv = {}

--load map information
--TODO use database instead
if file.Exists("pam/favoritemaps.txt", "DATA") then
	PAM.favorite_maps = util.JSONToTable(file.Read("pam/favoritemaps.txt", "DATA"))
end
