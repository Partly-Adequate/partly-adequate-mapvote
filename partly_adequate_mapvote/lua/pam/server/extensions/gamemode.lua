local extension = {}
extension.name = "gamemode"
extension.enabled = false
extension.settings = {
	vote_length = 15,
	blacklist = "base"
}

function extension.RegisterSpecialOptions()
	if PAM.vote_type ~= "map" then return end

	PAM.RegisterOption("change_gamemode", function()
		PAM.Cancel()
		PAM.Start("gamemode", extension.settings.vote_length, function(option)
			PAM.ChangeGamemode(option)
			PAM.Cancel()
			PAM.Start()
		end)
	end)
end

function extension.RegisterOptions()
	if PAM.vote_type ~= "gamemode" then return end

	local all_gamemodes = engine.GetGamemodes()
	local gamemode_amount = 0

	local blacklist = extension.settings.blacklist

	for _, gamemode_table in ipairs(all_gamemodes) do
		-- don't add blacklisted gamemodes
		if string.find(blacklist, gamemode_table.name) then
			continue
		end

		PAM.RegisterOption(gamemode_table.name)
	end
end

PAM.RegisterExtension(extension)
