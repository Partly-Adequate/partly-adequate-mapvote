local extension = {}
extension.name = "random_option"
extension.enabled = false

local allow_specials = false

function extension.RegisterSpecialOptions()
	PAM.RegisterOption("random_option", function()
		if not allow_specials then
			PAM.MakeOptionWin(PAM.options[PAM.special_option_count + math.random(#PAM.options - PAM.special_option_count)])
		else
			PAM.MakeOptionWin(PAM.options[math.random(#PAM.options)])
		end
	end)
end

PAM.extension_handler.RegisterExtension(extension)

local path = {"pam", extension.name}
local allow_specials_setting_id = "allow_specials"

allow_specials = pacoman.server_settings:AddSetting(path, allow_specials_setting_id, pacoman.P_TYPE_BOOLEAN, allow_specials)

pacoman.server_settings:AddCallback(path, allow_specials_setting_id, function(new_value)
	allow_specials = new_value
end)
