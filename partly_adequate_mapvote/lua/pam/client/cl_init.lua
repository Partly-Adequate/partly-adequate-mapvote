PAM.vote_ends_at = 0
PAM.vote_menu = nil
PAM.menu_manager = nil
PAM.players_wanting_rtv = {}

if not sql.TableExists("pam_maps") then
	sql.Query("CREATE TABLE pam_maps(id TEXT NOT NULL PRIMARY KEY, is_favorite INTEGER NOT NULL)")
end 

if not sql.TableExists("pam_extensions") then
	sql.Query("CREATE TABLE pam_extensions(id TEXT NOT NULL PRIMARY KEY, is_enabled INTEGER NOT NULL)")
end 
