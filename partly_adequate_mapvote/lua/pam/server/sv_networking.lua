net.Receive("PAM_Vote", function(len, ply)
	if PAM.state == PAM.STATE_STARTED and IsValid(ply) then
		local map_id = net.ReadUInt(32)

		if PAM.maps[map_id] then
			PAM.votes[ply:SteamID()] = map_id

			net.Start("PAM_Vote")
			net.WriteEntity(ply)
			net.WriteUInt(map_id, 32)
			net.Broadcast()
		end
	end
end)

net.Receive("PAM_UnVote", function(len, ply)
	if PAM.state == PAM.STATE_STARTED and IsValid(ply) then
		PAM.Votes[ply:SteamID()] = nil
		net.Start("PAM_UnVote")
		net.WriteEntity(ply)
		net.Broadcast()
	end
end)

net.Receive("PAM_RTV", function(len, ply)
	if PAM.rtv_config.is_enabled and PAM.state == PAM.STATE_DISABLED then
		local rtv_reason = ""
		if table.HasValue(PAM.players_wanting_rtv, ply:SteamID()) then
			table.RemoveByValue(PAM.players_wanting_rtv, ply:SteamID());
			rtv_reason = " no longer wants to rock the vote! "
		else
			table.insert(PAM.players_wanting_rtv, ply:SteamID())
			rtv_reason = " wants to rock the vote! "
		end

		local current_count = #PAM.players_wanting_rtv
		local needed_count = math.ceil(PAM.rtv_config.needed_player_percentage * player.GetCount())

		PrintMessage(3, "[PAM] " .. ply:GetName() .. rtv_reason .. "(" .. tostring(current_count) .. "/" .. tostring(needed_count) .. ")")

		if (current_count >= needed_count) then
			PAM.Start(PAM.rtv_config.vote_length, PAM.rtv_config.allow_all_maps)
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
