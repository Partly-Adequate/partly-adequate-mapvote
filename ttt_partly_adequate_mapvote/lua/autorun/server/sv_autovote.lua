hook.Add("Initialize", "PAMAutoStart", function()
	if GAMEMODE_NAME == "terrortown" then
		function CheckForMapSwitch()
			local rounds_left = math.max(0, GetGlobalInt("ttt_rounds_left", 6) - 1)

			SetGlobalInt("ttt_rounds_left", rounds_left)

			local time_left = math.max(0, (GetConVar("ttt_time_limit_minutes"):GetInt() * 60) - CurTime())

			if rounds_left <= 0 or time_left <= 0 then
				timer.Stop("end2prep")

				PAM.UpdateRecentMaps()
				PAM.Start(nil, false)
			end
		end
	end
end)
