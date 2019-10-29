PAM.vote_ends_at = 0
PAM.favorite_maps = {}

if file.Exists("pam/favoritemaps.txt", "DATA") then
	PAM.favorite_maps = util.JSONToTable(file.Read("pam/favoritemaps.txt", "DATA"))
end
