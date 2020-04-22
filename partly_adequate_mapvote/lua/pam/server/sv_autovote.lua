hook.Add("Initialize", "PAM_Autostart", function()
	-- terrortown support
	if GAMEMODE_NAME == "terrortown" then
		if TTT2 then
			-- TTT2
			hook.Add("TTT2LoadNextMap", "PAM_Autostart_TTT2", function(nextmap, rounds_left, time_left)
				PAM.Start()
				return true
			end)
		else
			-- TTT and TOT
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
		hook.Add("TTTEndRound", "PAM_Autostart_Delayed_RTV_TTT", function()
			PAM.CheckForDelayedRTV()
		end)
		return
	end

	-- deathrun support
	if GAMEMODE_NAME == "deathrun" then
		-- Arizard/deathrun
		if DR and MV and MV.BeginMapVote then
			-- remove original functionality by cutting off the api
			concommand.Remove("mapvote_begin_mapvote")
			concommand.Remove("mapvote_list_maps")
			concommand.Remove("mapvote_nominate_map")
			concommand.Remove("mapvote_rtv")
			concommand.Remove("mapvote_update_mapvote")
			concommand.Remove("mapvote_vote")
			hook.Remove("PlayerSay", "CheckRTVChat")

			cvars.AddChangeCallback("mapvote_rtv_ratio", function()
				print('[PAM] This convar is no longer used. Use "pam_rtv_percentage" instead')
			end)

			-- start PAM instead of MV
			MV.BeginMapVote = PAM.Start

			-- DeathrunShouldMapSwitch gets called at the start of the ROUND_OVER state. It's a fitting moment to check for delayed RTV.
			hook.Add("DeathrunShouldMapSwitch", "PAM_Autostart_Delayed_RTV_Deathrun", function()
				return (PAM.state == PAM.STATE_STARTED) or PAM.CheckForDelayedRTV()
			end)
			return
		end

		--  Mr-Gash/GMod-Deathrun
		if RTV and RTV.Start and round and ROUND_ENDING then
			-- remove original functionality by cutting off the api
			hook.Remove("PlayerSay", "RTV Chat Commands")
			concommand.Remove("rtv_vote")
			concommand.Remove("rtv_start")
			RTV.Start = PAM.Start

			-- Check for delayed RTV when the round ends
			hook.Add("OnRoundSet", "PAM_Autostart_Delayed_RTV_Deathrun", function(round, ...)
				if(round == ROUND_ENDING) then
					if PAM.CheckForDelayedRTV() then
						-- stop next round from loading
						SetGlobalInt( "Deathrun_RoundPhase", -1 )
						SetGlobalInt( "Deathrun_RoundTime", 0 )
					end
				end
			end)
			return
		end
	end

	-- murder support
	if GAMEMODE_NAME == "murder" then
		-- Reconstructing MiRe's MapVote api, because murder supports only their addon natively
		MapVote = {}
		MapVote.Start = function(a, b, c, d) 
			PAM.Start()
		end

		-- Check for delayed RTV when the round ends
		hook.Add("OnEndRound", "PAM_Autostart_Delayed_RTV_Murder", function()
			PAM.CheckForDelayedRTV()
		end)
		return
	end
	-- other gamemodes go here
end)
