net.Receive("PAM_Vote", function(len, ply)
	if PAM.State == PAM.STATE_STARTED and IsValid(ply) then
		local map_id = net.ReadUInt(32)

		if PAM.Maps[map_id] then
			PAM.Votes[ply:SteamID()] = map_id

			net.Start("PAM_Vote")
			net.WriteEntity(ply)
			net.WriteUInt(map_id, 32)
			net.Broadcast()
		end
	end
end)

net.Receive("PAM_RTV", function(len, ply)
	if PAM.RTV_Config.IsEnabled and PAM.State == PAM.STATE_DISABLED then
		rtvReason = ""
		if table.HasValue(PAM.PlayersWantingRTV, ply:SteamID()) then
			table.RemoveByValue(PAM.PlayersWantingRTV, ply:SteamID());
			rtvReason = " no longer wants to rock the vote! "
		else
			table.insert(PAM.PlayersWantingRTV, ply:SteamID())
			rtvReason = " wants to rock the vote! "
		end

		currentCount = #PAM.PlayersWantingRTV
		neededCount = math.ceil(PAM.RTV_Config.NeededPlayerPercentage * player.GetCount())

		PrintMessage(3, "[PAM] " .. ply:GetName() .. rtvReason .. "(" .. tostring(currentCount) .. "/" .. tostring(neededCount) .. ")")

		if (currentCount >= neededCount) then
			PAM.Start(PAM.RTV_Config.VoteLength, PAM.RTV_Config.AllowAllMaps)
		end
	end
end)

/* Untested but needed
hook.Add( "PlayerDisconnected", "PAM_PlayerDisconnected", function(ply)
	if PAM.State == PAM.STATE_STARTED and PAM.Votes[ply:SteamID()] then
		net.Start("PAM_UnVote")
		net.WriteEntity(ply)
		net.Broadcast();
	elseif PAM.RTV_Config.IsEnabled and PAM.State == PAM.STATE_DISABLED then
		if table.HasValue(PAM.PlayersWantingRTV, ply:SteamID()) then
			table.RemoveByValue(PAM.PlayersWantingRTV, ply:SteamID());
		else
			CheckForRTV()
		end
	end
end )
*/
