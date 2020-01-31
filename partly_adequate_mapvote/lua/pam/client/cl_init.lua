PAM.vote_ends_at = 0
PAM.menu_manager = nil
PAM.winning_map_id = nil
PAM.maps = {}
PAM.votes = {}
PAM.players_wanting_rtv = {}
PAM.rtv_players_needed = 0

if not sql.TableExists("pam_maps") then
	sql.Query("CREATE TABLE pam_maps(id TEXT NOT NULL PRIMARY KEY, is_favorite INTEGER NOT NULL)")
end 

if not sql.TableExists("pam_extensions") then
	sql.Query("CREATE TABLE pam_extensions(id TEXT NOT NULL PRIMARY KEY, is_enabled INTEGER NOT NULL)")
end 
