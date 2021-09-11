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
			print("[PAM] This convar is no longer used")
		end)

		-- start PAM instead of MV
		MV.BeginMapVote = PAM.Start


		-- Notify PAM that the round has ended
		hook.Add("OnRoundSet", "PAM_RoundEnded", function(round_id)
			if round_id == ROUND_OVER then
				PAM.EndRound()
			end
		end)
		return
	end

	-- Mr-Gash/GMod-Deathrun
	if RTV and RTV.Start and ROUND_ENDING then
		-- remove original functionality by cutting off the api
		hook.Remove("PlayerSay", "RTV Chat Commands")
		concommand.Remove("rtv_vote")
		concommand.Remove("rtv_start")
		RTV.Start = PAM.Start


		-- Notify PAM that the round has ended
		hook.Add("OnRoundSet", "PAM_RoundEnded", function(round, ...)
			if round == ROUND_ENDING then
				PAM.EndRound()
			end
		end)
		return
	end
end
