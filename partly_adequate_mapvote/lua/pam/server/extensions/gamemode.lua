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

local setting_namespace = PAM.setting_namespace:AddChild(extension.name)
local vote_length_setting = setting_namespace:AddSetting("vote_length", pacoman.TYPE_INTEGER, vote_length)
local blacklist_setting = setting_namespace:AddSetting("blacklist", pacoman.TYPE_STRING, blacklist)

vote_length = vote_length_setting:GetActiveValue()
blacklist = blacklist_setting:GetActiveValue()

vote_length_setting:AddCallback("default", function(new_value)
	vote_length = new_value
end)
blacklist_setting:AddCallback("default", function(new_value)
	blacklist = new_value
end)
