--toggle menu visibility
concommand.Add("pam_toggle_menu", function(player, cmd, args, arg_str)
	if PAM.state ~= PAM.STATE_DISABLED then
		PAM.extension_handler.RunEvent("ToggleVisibility")
	end
end)
