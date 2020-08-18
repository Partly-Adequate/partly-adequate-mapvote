net.Receive("PAM_Start", function()
	PAM.state = PAM.STATE_STARTED
	table.Empty(PAM.maps)
	table.Empty(PAM.votes)
	table.Empty(PAM.players_wanting_rtv)
	PAM.winning_map_id = nil

	local map_amount = net.ReadUInt(32)

	for index = 1, map_amount do
		local mapinfo = {};
		mapinfo.id = index
		mapinfo.name = net.ReadString()
		mapinfo.playcount = net.ReadUInt(32)
		PAM.maps[index] = mapinfo
	end

	-- the point in time at which the mapvote will end
	PAM.ends_at = CurTime() + GetGlobalInt("pam_vote_length")

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

net.Receive("PAM_UnVote", function()
	local ply = net.ReadEntity()
	if IsValid(ply) then
		PAM.votes[ply:SteamID()] = nil
		PAM.extension_handler.OnVoterRemoved(ply)
	end
end)

net.Receive("PAM_VoteRTV", function(len)
	local ply = net.ReadEntity()
	table.insert(PAM.players_wanting_rtv, ply)
	PAM.extension_handler.OnRTVVoterAdded(ply)
end)

net.Receive("PAM_UnVoteRTV", function(len)
	local ply = net.ReadEntity()
	table.RemoveByValue(PAM.players_wanting_rtv, ply);
	PAM.extension_handler.OnRTVVoterRemoved(ply)
end)

net.Receive("PAM_Announce_Winner", function()
	PAM.winning_map_id = net.ReadUInt(32)
	PAM.state = PAM.STATE_FINISHED
	PAM.extension_handler.OnWinnerAnnounced()
end)

net.Receive("PAM_Cancel", function()
	if PAM.state ~= PAM.STATE_DISABLED then
		PAM.state = PAM.STATE_DISABLED
		PAM.extension_handler.OnVoteCanceled()
	end
end)

net.Receive("PAM_Gamemode_Changed", function()
	hook.Run("PAM_OnGamemodeChanged", net.ReadString())
end)
