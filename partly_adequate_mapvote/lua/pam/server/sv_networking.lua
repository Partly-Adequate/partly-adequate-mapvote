net.Receive("PAM_Vote", function(len, ply)
	local option_id = net.ReadUInt(32)

	if PAM.state ~= PAM.STATE_STARTED then return end
	if not IsValid(ply) then return end
	if not PAM.options[option_id] then return end

	PAM.AddVoter(ply, option_id)
end)

net.Receive("PAM_UnVote", function(len, ply)
	if PAM.state ~= PAM.STATE_STARTED then return end
	if not PAM.votes[ply:SteamID()] then return end
	if not IsValid(ply) then return end

	PAM.RemoveVoter(ply)
end)

net.Receive("PAM_StateRequest", function(len, ply)
	-- send all current vote info to the new client
	if PAM.state ~= PAM.STATE_DISABLED then
		net.Start("PAM_Start")
		net.WriteString(PAM.vote_type)
		net.WriteUInt(timer.TimeLeft("PAM_Vote_Timer"), 32)
		net.WriteUInt(PAM.special_option_count, 32)
		net.WriteUInt(PAM.option_count, 32)
		for i = 1, PAM.option_count do
			net.WriteString(PAM.options[i].name)
			net.WriteUInt(PAM.GetPickCount(PAM.options[i].name), 32)
		end
		net.Send(ply)

		for steam_id, option_id in ipairs(PAM.votes) do
			net.Start("PAM_Vote")
			net.WriteEntity(player.GetBySteamID(steam_id))
			net.WriteUInt(option_id, 32)
			net.Broadcast()
		end
	end

	if PAM.state == PAM.STATE_FINISHED then
		net.Start("PAM_Announce_Winner")
		net.WriteUInt(PAM.winning_option_id, 32)
		net.Send(ply)
	end

	PAM.extension_handler.RunEvent("StateRequest", ply)
end)
