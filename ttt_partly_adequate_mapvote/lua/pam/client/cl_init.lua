PAM.EndsAt = 0
PAM.Panel = nil
PAM.FavoriteMaps = {}

if file.Exists("pam/favoritemaps.txt", "DATA") then
	PAM.FavoriteMaps = util.JSONToTable(file.Read("pam/favoritemaps.txt", "DATA"))
end
