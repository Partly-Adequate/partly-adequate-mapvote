net.Receive("PAM_Start", function()
	PAM.state = PAM.STATE_STARTED
	table.Empty(PAM.options)
	table.Empty(PAM.votes)
	table.Empty(PAM.players_wanting_rtv)
	PAM.winning_option_id = nil

	-- the type of the current vote
	PAM.vote_type = net.ReadString()
	-- the point in time at which the mapvote will end
	PAM.ends_at = CurTime() + net.ReadUInt(32)

	local special_option_count = net.ReadUInt(32)
	local option_count = net.ReadUInt(32)

	for index = 1, option_count do
		local option = {}
		option.id = index
		option.is_special = index <= special_option_count
		option.name = net.ReadString()
		option.pick_count = net.ReadUInt(32)
		PAM.options[index] = option
	end

	PrintTable(PAM.options)

	PAM.extension_handler.OnVoteStarted()
end)

net.Receive("PAM_Vote", function()
	local ply = net.ReadEntity()
	local option_id = net.ReadUInt(32)

	if IsValid(ply) then
		PAM.votes[ply:SteamID()] = option_id
		PAM.extension_handler.OnVoterAdded(ply, option_id)
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
	PAM.winning_option_id = net.ReadUInt(32)
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
