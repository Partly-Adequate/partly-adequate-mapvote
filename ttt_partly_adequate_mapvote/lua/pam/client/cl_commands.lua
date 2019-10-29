-- toggle menu visibility
concommand.Add("pam_toggle_menu", function(player, cmd, args, argStr)
	if PAM.state == PAM.STATE_STARTED then
		PAM.menu.Toggle()
	end
end)

-- toggle rtv participation
concommand.Add("pam_rtv", function(player, cmd, args, argStr)
	if PAM.state == PAM.STATE_DISABLED then
		net.Start("PAM_RTV")
		net.SendToServer()
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
end)
