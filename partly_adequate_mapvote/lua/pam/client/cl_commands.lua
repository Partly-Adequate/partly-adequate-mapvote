-- toggle menu visibility
concommand.Add("pam_toggle_menu", function(player, cmd, args, arg_str)
	if PAM.state == PAM.STATE_STARTED then
		PAM.extension_handler.ToggleVisibility()
	end
end)

-- toggle rtv participation
concommand.Add("pam_rtv", function(player, cmd, args, arg_str)
	if PAM.state == PAM.STATE_DISABLED then
		net.Start("PAM_RTV")
		net.SendToServer()
	end
end)

-- create a menu selection screen
concommand.Add("pam_menu_selection", function(player, cmd, args, arg_str)
	if IsValid(PAM.menu_manager) then
		PAM.menu_manager:Remove()
	else
		PAM.menu_manager = vgui.Create("pam_menu_selection")
	end
end)

-- registers commands for the ttt2 bind menu
hook.Add("Initialize", "PamBindings", function()
	bind.Register("pam_toggle_menu", function()
		LocalPlayer():ConCommand("pam_toggle_menu")
	end, nil, "Partly Adequate Mapvote", "Toggle menu visibility", nil)

	bind.Register("pam_rtv", function()
		LocalPlayer():ConCommand("pam_rtv")
	end, nil, "Partly Adequate Mapvote", "RTV", nil)

	bind.Register("pam_menu_selection", function()
		LocalPlayer():ConCommand("pam_menu_selection")
	end, nil, "Partly Adequate Mapvote", "Menu Selection", nil)
end)
