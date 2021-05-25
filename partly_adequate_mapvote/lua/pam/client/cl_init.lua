PAM.vote_ends_at = 0

PAM.setting_namespace = pacoman.client_settings:AddChild("pam")

if not sql.TableExists("pam_options") then
	sql.Query("CREATE TABLE pam_options(id TEXT NOT NULL PRIMARY KEY, is_favorite INTEGER NOT NULL)")
end
