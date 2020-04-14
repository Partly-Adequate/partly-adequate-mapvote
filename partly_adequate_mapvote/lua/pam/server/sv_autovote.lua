hook.Add("Initialize", "PAM_Autostart", function()
	-- terrortown support
	if GAMEMODE_NAME == "terrortown" then
		if TTT2 then
			-- TTT2 support
			hook.Add("TTT2LoadNextMap", "PAM_Autostart_TTT2", function(nextmap, rounds_left, time_left)
				PAM.Start()
				return true
			end)
		else
			-- TTT and TOT support
			function CheckForMapSwitch()
				local rounds_left = math.max(0, GetGlobalInt("ttt_rounds_left", 6) - 1)

				SetGlobalInt("ttt_rounds_left", rounds_left)

				local time_left = math.max(0, (GetConVar("ttt_time_limit_minutes"):GetInt() * 60) - CurTime())

				if rounds_left <= 0 or time_left <= 0 then
					timer.Stop("end2prep")
					if PAM.state == PAM.STATE_DISABLED then
						PAM.Start()
					end
				end
			end
		end
		-- The end of the round is a fitting moment for rtv to be checked
		hook.Add("TTTEndRound", "PAM_Autostart_RTV_TTT", function()
			if GetConVar("pam_rtv_delayed"):GetBool() then
				PAM.CheckForRTV();
			end
		end)
		return
	end
	-- other gamemodes go here
end)
