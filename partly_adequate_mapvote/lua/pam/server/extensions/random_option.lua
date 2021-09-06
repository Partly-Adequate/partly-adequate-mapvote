local name = "random_option"
PAM_EXTENSION.name = name
PAM_EXTENSION.enabled = false

local allow_specials_setting = PAM.setting_namespace:AddChild(name):AddSetting("allow_specials", pacoman.TYPE_BOOLEAN, false)

function PAM_EXTENSION:RegisterSpecialOptions()
	PAM.RegisterOption("random_option", function()
		if allow_specials_setting:GetActiveValue() then
			PAM.MakeOptionWin(PAM.options[math.random(#PAM.options)])
			return
		end
		PAM.MakeOptionWin(PAM.options[PAM.special_option_count + math.random(#PAM.options - PAM.special_option_count)])
	end)
end
