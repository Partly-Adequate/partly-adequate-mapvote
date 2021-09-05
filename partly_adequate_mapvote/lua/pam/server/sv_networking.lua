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
