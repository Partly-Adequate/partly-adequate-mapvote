surface.CreateFont("PAM_MapNameFont", {
	font = "Trebuchet MS",
	size = 19,
})

surface.CreateFont("PAM_PlayCountFont", {
	font = "Trebuchet MS",
	size = 15
})

surface.CreateFont("PAM_VoteFontCountdown", {
	font = "Tahoma",
	size = 20
})

PAM.EndsAt = 0
PAM.Panel = false
PAM.FavoriteMaps = {}

if file.Exists("pam/favoritemaps.txt", "DATA") then
	PAM.FavoriteMaps = util.JSONToTable(file.Read("pam/favoritemaps.txt", "DATA"))
end
