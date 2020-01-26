--terrortown (regular ttt, ttt2 and tot)
--TODO use fancy hook once v0.6 of TTT2 is released
hook.Add("Initialize", "PAM_TTT_AutoStart", function()
	if GAMEMODE_NAME == "terrortown" then
		function CheckForMapSwitch()
			local rounds_left = math.max(0, GetGlobalInt("ttt_rounds_left", 6) - 1)

			SetGlobalInt("ttt_rounds_left", rounds_left)

			local time_left = math.max(0, (GetConVar("ttt_time_limit_minutes"):GetInt() * 60) - CurTime())

			if rounds_left <= 0 or time_left <= 0 then
				timer.Stop("end2prep")
				if PAM.state == PAM.STATE_DISABLED then
					PAM.Start(nil, false)
				end
			end
		end
	end
end)
