net.Receive("PAM_Start", function()
	PAM.maps = {}
	PAM.votes = {}
	PAM.state = PAM.STATE_STARTED

	local map_amount = net.ReadUInt(32)

	for index = 1, map_amount do
		local mapinfo = {};
		mapinfo.id = index
		mapinfo.name = net.ReadString()
		mapinfo.playcount = net.ReadUInt(32)
		PAM.maps[index] = mapinfo
	end

	--the point in time at which the mapvote will end
	PAM.ends_at = CurTime() + net.ReadUInt(32)

	PAM.extension_handler.OnVoteStarted()
end)

net.Receive("PAM_Vote", function()
	local ply = net.ReadEntity()
	local map_id = net.ReadUInt(32)

	if IsValid(ply) then
		PAM.votes[ply:SteamID()] = map_id
		PAM.extension_handler.OnVoterAdded(ply, map_id)
	end
end)

net.Receive("PAM_OnUnVote", function()
	local ply = net.ReadEntity()
	if IsValid(ply) then
		PAM.votes[ply:SteamID()] = nil
		PAM.extension_handler.OnVoterRemoved(ply)
	end
end)

net.Receive("PAM_Announce_Winner", function()
	map_id = net.ReadUInt(32)
	PAM.state = PAM.STATE_FINISHED
	PAM.extension_handler.OnWinnerAnnounced(map_id)
end)

net.Receive("PAM_Cancel", function()
	if PAM.state == PAM.STATE_STARTED then
		PAM.state = PAM.STATE_DISABLED
		PAM.extension_handler.OnVoteCanceled()
	end
end)
