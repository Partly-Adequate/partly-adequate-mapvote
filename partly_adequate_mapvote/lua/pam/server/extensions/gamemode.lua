local name = "gamemode"
PAM_EXTENSION.name = name
PAM_EXTENSION.enabled = false

local setting_namespace = PAM.setting_namespace:AddChild(name)
local vote_length_setting = setting_namespace:AddSetting("vote_length", pacoman.TYPE_INTEGER, 30)
local blacklist_setting = setting_namespace:AddSetting("blacklist", pacoman.TYPE_STRING, "base")

function PAM_EXTENSION:RegisterSpecialOptions()
	if PAM.vote_type ~= "map" then return end

	PAM.RegisterOption("change_gamemode", function()
		PAM.Cancel()
		PAM.Start("gamemode", vote_length_setting:GetActiveValue(), function(option)
			PAM.ChangeGamemode(option)
			PAM.Cancel()
			PAM.Start()
		end)
	end)
end

function PAM_EXTENSION:RegisterOptions()
	if PAM.vote_type ~= "gamemode" then return end

	local all_gamemodes = engine.GetGamemodes()
	for _, gamemode_table in ipairs(all_gamemodes) do
		-- don't add blacklisted gamemodes
		if string.find(blacklist_setting:GetActiveValue(), gamemode_table.name) then
			continue
		end

		PAM.RegisterOption(gamemode_table.name)
	end
end
