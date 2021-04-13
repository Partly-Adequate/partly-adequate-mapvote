local extension = {}
extension.name = "gamemode"
extension.enabled = false

local vote_length = 30
local blacklist = "base"

function extension.RegisterSpecialOptions()
	if PAM.vote_type ~= "map" then return end

	PAM.RegisterOption("change_gamemode", function()
		PAM.Cancel()
		PAM.Start("gamemode", vote_length, function(option)
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

	for _, gamemode_table in ipairs(all_gamemodes) do
		-- don't add blacklisted gamemodes
		if string.find(blacklist, gamemode_table.name) then
			continue
		end

		PAM.RegisterOption(gamemode_table.name)
	end
end

PAM.extension_handler.RegisterExtension(extension)

local path = {"pam", extension.name}
local vote_length_setting_id = "vote_length"
local blacklist_setting_id = "blacklist"

vote_length = pacoman.server_settings:AddSetting(path, vote_length_setting_id, pacoman.P_TYPE_INTEGER, vote_length)
blacklist = pacoman.server_settings:AddSetting(path, blacklist_setting_id, pacoman.P_TYPE_STRING, blacklist)

pacoman.server_settings:AddCallback(path, vote_length_setting_id, function(new_value)
	vote_length = new_value
end)
pacoman.server_settings:AddCallback(path, blacklist_setting_id, function(new_value)
	blacklist = new_value
end)
