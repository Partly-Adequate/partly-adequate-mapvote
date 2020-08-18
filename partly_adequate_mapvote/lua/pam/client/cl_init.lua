PAM.vote_ends_at = 0
PAM.menu_manager = nil
PAM.winning_option_id = nil

if not sql.TableExists("pam_maps") then
	sql.Query("CREATE TABLE pam_maps(id TEXT NOT NULL PRIMARY KEY, is_favorite INTEGER NOT NULL)")
end
