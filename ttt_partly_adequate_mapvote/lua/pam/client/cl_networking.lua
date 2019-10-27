net.Receive("PAM_Start", function()
	PAM.Maps = {}
	PAM.Votes = {}
	PAM.State = PAM.STATE_STARTED

	local amount = net.ReadUInt(32)

	for i = 1, amount do
		local mapinfo = {};
		mapinfo.id = i
		mapinfo.name = net.ReadString()
		mapinfo.playcount = net.ReadUInt(32)
		PAM.Maps[i] = mapinfo
	end

	--the point in time at which the mapvote will end
	PAM.EndsAt = CurTime() + net.ReadUInt(32)

	if !hook.Run("PAM_OnVoteStarted") then
		if IsValid(PAM.Panel) then
			PAM.Panel:Remove()
		end
		PAM.Panel = vgui.Create("ttt_pam_votescreen")
	end
end)

net.Receive("PAM_Vote", function()
	local ply = net.ReadEntity()
	local mapID = net.ReadUInt(32)

	if IsValid(ply) then
		PAM.Votes[ply:SteamID()] = mapID
		if !hook.Run("PAM_OnPlayerVoted", ply, mapID) and IsValid(PAM.Panel) then
			PAM.Panel:AddVoter(ply)
		end
	end
end)

net.Receive("PAM_OnUnVote", function()
	local ply = net.ReadEntity()
	if IsValid(ply) then
		if !hook.Run("PAM_OnPlayerUnVoted", ply) and IsValid(PAM.Panel) then
			PAM.Panel:RemoveVoter(ply)
		end
	end
end)

net.Receive("PAM_Announce_Winner", function()
	mapID = net.ReadUInt(32)
	PAM.State = PAM.STATE_FINISHED
	if !hook.Run("PAM_OnWinnerAnnounced", mapID) and IsValid(PAM.Panel) then
		PAM.Panel:Flash(mapID)
	end
end)

net.Receive("PAM_Cancel", function()
	if PAM.State == PAM.STATE_STARTED then
		PAM.State = PAM.STATE_DISABLED
		if !hook.Run("PAM_OnCanceled", mapID) and IsValid(PAM.Panel) then
			PAM.Panel:Remove()
		end
	end
end)
