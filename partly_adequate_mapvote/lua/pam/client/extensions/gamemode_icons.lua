local extension = {}
extension.name = "gamemode_icons"
extension.enabled = true

function extension.GetIconMaterial(option)
	if PAM.vote_type ~= "gamemode" then return end
	if option.is_special then return end

	local gamemode_name = option.name

	if file.Exists("gamemodes/" .. gamemode_name .. "/icon24.png", "GAME") then
		return Material("gamemodes/" .. gamemode_name .. "/icon24.png")
	end
end

PAM.RegisterExtension(extension)
