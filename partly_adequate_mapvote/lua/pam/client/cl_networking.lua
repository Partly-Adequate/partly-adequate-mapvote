net.Receive("PAM_Start", function()
	PAM.state = PAM.STATE_STARTED

	table.Empty(PAM.options)
	table.Empty(PAM.votes)

	PAM.winning_option_id = nil

	-- the type of the current vote
	PAM.vote_type = net.ReadString()
	-- the point in time at which the mapvote will end
	PAM.ends_at = CurTime() + net.ReadUInt(32)

	PAM.special_option_count = net.ReadUInt(32)
	PAM.option_count = net.ReadUInt(32)

	for index = 1, PAM.option_count do
		local option = {}
		option.id = index
		option.is_special = index <= PAM.special_option_count
		option.name = net.ReadString()
		option.pick_count = net.ReadUInt(32)
		PAM.options[index] = option
	end

	PAM.extension_handler.RunEvent("OnVoteStarted")
end)

net.Receive("PAM_Cancel", function()
	if PAM.state == PAM.STATE_DISABLED then return end

	PAM.Cancel()
end)

net.Receive("PAM_Vote", function()
	local ply = net.ReadEntity()
	local option_id = net.ReadUInt(32)

	if PAM.state ~= PAM.STATE_STARTED then return end
	if not IsValid(ply) then return end
	if not PAM.options[option_id] then return end

	PAM.AddVoter(ply, option_id)
end)

net.Receive("PAM_UnVote", function()
	local ply = net.ReadEntity()

	if PAM.state ~= PAM.STATE_STARTED then return end
	if not IsValid(ply) then return end
	if not PAM.votes[ply:SteamID()] then return end

	PAM.RemoveVoter(ply)
end)

net.Receive("PAM_Announce_Winner", function()
	local option_id = net.ReadUInt(32)

	if not PAM.options[option_id] then return end

	PAM.AnnounceWinner(option_id)
end)

net.Receive("PAM_Gamemode_Changed", function()
	hook.Run("PAM_OnGamemodeChanged", net.ReadString())
end)
