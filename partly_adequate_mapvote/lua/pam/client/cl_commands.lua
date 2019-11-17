-- toggle menu visibility
concommand.Add("pam_toggle_menu", function(player, cmd, args, arg_str)
	if PAM.state == PAM.STATE_STARTED then
		PAM.extension_handler.ToggleVisibility()
	end
end)

-- toggle rtv participation
concommand.Add("pam_rtv", function(ply, cmd, args, arg_str)
	if PAM.state == PAM.STATE_DISABLED then
		if PAM.WantsRTV(ply) then
			PAM.UnRTV()
		else
			PAM.RTV()
		end
	end
end)

-- create a menu selection screen
concommand.Add("pam_extension_manager", function(player, cmd, args, arg_str)
	if IsValid(PAM.extension_manager) then
		PAM.extension_manager:Remove()
	else
		PAM.extension_manager = vgui.Create("pam_extension_manager")
	end
end)

-- registers commands for the ttt2 bind menu
hook.Add("Initialize", "PamBindings", function()
	if TTT2 then
		bind.Register("pam_toggle_menu", function()
			LocalPlayer():ConCommand("pam_toggle_menu")
		end, nil, "Partly Adequate Mapvote", "Toggle menu visibility", nil)

		bind.Register("pam_rtv", function()
			LocalPlayer():ConCommand("pam_rtv")
		end, nil, "Partly Adequate Mapvote", "RTV", nil)

		bind.Register("pam_menu_selection", function()
			LocalPlayer():ConCommand("pam_extension_manager")
		end, nil, "Partly Adequate Mapvote", "Extension Manager", nil)
	end
end)
