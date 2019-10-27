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
	PAM.Panel = hook.Run("PAM_LoadGUI")
	if not PAM.Panel then
		PAM.Panel = vgui.Create("ttt_pam_votescreen")
	end
end)

net.Receive("PAM_Vote", function()
	local ply = net.ReadEntity()

	if IsValid(ply) then
		PAM.Votes[ply:SteamID()] = net.ReadUInt(32)

		if IsValid(PAM.Panel) then
			PAM.Panel:AddVoter(ply)
		end
	end
end)

net.Receive("PAM_UnVote", function()
	local ply = net.ReadEntity()
	if IsValid(ply) then
		PAM.Panel:RemoveVoter(ply)
	end
end)

net.Receive("PAM_Announce_Winner", function()
	if IsValid(PAM.Panel) then
		PAM.State = PAM.STATE_FINISHED
		PAM.Panel:Flash(net.ReadUInt(32))
	end
end)

net.Receive("PAM_Cancel", function()
	if IsValid(PAM.Panel) then
		PAM.Panel:Remove()
		PAM.State = PAM.STATE_DISABLED
	end
end)
