--toggle menu visibility
concommand.Add("pam_toggle_menu", function(player, cmd, args, arg_str)
	if PAM.state ~= PAM.STATE_DISABLED then
		PAM.extension_handler.ToggleVisibility()
	end
end)

--toggle rtv participation
concommand.Add("pam_rtv", function(ply, cmd, args, arg_str)
	if PAM.state == PAM.STATE_DISABLED then
		if PAM.WantsRTV(ply) then
			PAM.UnVoteRTV()
		else
			PAM.VoteRTV()
		end
	end
end)

--registers commands for the ttt2 bind menu
hook.Add("Initialize", "PAM_Bindings", function()
	if TTT2 then
		bind.Register("pam_toggle_menu", function()
			LocalPlayer():ConCommand("pam_toggle_menu")
		end, nil, "Partly Adequate Mapvote", "Toggle menu visibility", nil)

		bind.Register("pam_rtv", function()
			LocalPlayer():ConCommand("pam_rtv")
		end, nil, "Partly Adequate Mapvote", "RTV", nil)
	end
end)
