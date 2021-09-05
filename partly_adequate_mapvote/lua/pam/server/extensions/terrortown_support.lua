PAM_EXTENSION.name = "terrortown_support"
PAM_EXTENSION.enabled = true

function PAM_EXTENSION:OnInitialize()
	-- terrortown support
	if GAMEMODE_NAME ~= "terrortown" then return end


	-- Notify PAM that the round has ended
	hook.Add("TTTEndRound", "PAM_RoundEnded", function()
		PAM.extension_handler.RunEvent("OnRoundEnded")
	end)

	-- ttt2/ttt2
	if TTT2 then
		hook.Add("TTT2LoadNextMap", "PAM_Autostart_TTT2", function(nextmap, rounds_left, time_left)
			PAM.Start()
			return true
		end)
		return
	end

	-- terrortown
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
