PAM.vote_ends_at = 0
PAM.menu_manager = nil
PAM.winning_map_id = nil
PAM.maps = {}
PAM.votes = {}
PAM.players_wanting_rtv = {}

if not sql.TableExists("pam_maps") then
	sql.Query("CREATE TABLE pam_maps(id TEXT NOT NULL PRIMARY KEY, is_favorite INTEGER NOT NULL)")
end
