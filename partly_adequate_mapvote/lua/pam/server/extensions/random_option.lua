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

local setting_namespace = PAM.setting_namespace:AddChild(extension.name)

local allow_specials_setting = setting_namespace:AddSetting("allow_specials", pacoman.TYPE_BOOLEAN, allow_specials)

allow_specials = allow_specials_setting:GetActiveValue()

allow_specials_setting:AddCallback("default", function(new_value)
	allow_specials = new_value
end)
