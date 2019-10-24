// toggle menu visibility
concommand.Add("ttt_pam_toggle_menu", function(ply, cmd, args, argStr)
	if gamemode.Get("terrortown") and PAM.State == PAM.STATE_STARTED then
		PAM.Panel:SetVisible(not PAM.Panel:IsVisible())
	end
end)

// toggle rtv participation
concommand.Add("ttt_pam_rtv", function(ply, cmd, args, argStr)
	if gamemode.Get("terrortown") and PAM.State == PAM.STATE_DISABLED then
		net.Start("PAM_RTV")
		net.SendToServer()
	end
end)

//registers commands for the ttt2 bind menu
hook.Add("Initialize", "PamBindings", function
	bind.Register("ttt_pam_toggle_menu", function()
		LocalPlayer():ConCommand("ttt_pam_toggle_menu")
	end, nil, "Partly Adequate Mapvote", "Toggle menu visibility", nil)

	bind.Register("ttt_pam_rtv", function()
		LocalPlayer():ConCommand("ttt_pam_rtv")
	end, nil, "Partly Adequate Mapvote", "RTV", nil)
end)
