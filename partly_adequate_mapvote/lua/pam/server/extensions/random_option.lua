local extension = {}
extension.name = "random_option"
extension.settings = {
	allow_specials = false
}

function extension.RegisterSpecialOptions()
	PAM.RegisterOption("random_option", function()
		if not extension.settings.allow_specials then
			PAM.MakeOptionWin(PAM.options[PAM.special_option_count + math.random(#PAM.options - PAM.special_option_count)])
		else
			PAM.MakeOptionWin(PAM.options[math.random(#PAM.options)])
		end
	end)
end

PAM.extension_handler.RegisterExtension(extension)
