PAM_EXTENSION.name = "deathrun_support"
PAM_EXTENSION.enabled = true

function PAM_EXTENSION:OnInitialize()
	if GAMEMODE_NAME ~= "deathrun" then return end

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
			print('[PAM] This convar is no longer used')
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
