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

net.Receive("PAM_VoteRTV", function(len, ply)
	if not PAM.settings.rtv_enabled then return end
	if PAM.state ~= PAM.STATE_DISABLED then return end
	if not IsValid(ply) then return end
	if PAM.rtv_voters[ply:SteamID()] then return end

	PAM.AddRTVVoter(ply)
end)

net.Receive("PAM_UnVoteRTV", function(len, ply)
	if not PAM.settings.rtv_enabled then return end
	if PAM.state ~= PAM.STATE_DISABLED then return end
	if not IsValid(ply) then return end
	if not PAM.rtv_voters[ply:SteamID()] then return end

	PAM.RemoveRTVVoter(ply)
end)
