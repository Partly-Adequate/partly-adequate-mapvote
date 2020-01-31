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

-- TODO test this
net.Receive("PAM_UnVote", function(len, ply)
	if PAM.state == PAM.STATE_STARTED and IsValid(ply) then
		PAM.Votes[ply:SteamID()] = nil
		net.Start("PAM_UnVote")
		net.WriteEntity(ply)
		net.Broadcast()
	end
end)

net.Receive("PAM_VoteRTV", function(len, ply)
	if PAM.rtv_config.is_enabled and PAM.state == PAM.STATE_DISABLED and IsValid(ply) and not table.HasValue(PAM.players_wanting_rtv, ply:SteamID())then
		table.insert(PAM.players_wanting_rtv, ply:SteamID())

		local rtv_players_needed = math.ceil(PAM.rtv_config.needed_player_percentage * player.GetCount())
		net.Start("PAM_VoteRTV")
		net.WriteEntity(ply)
		net.WriteUInt(rtv_players_needed, 32)
		net.Broadcast()

		PAM.CheckForRTV()
	end
end)

net.Receive("PAM_UnVoteRTV", function(len, ply)
	if PAM.rtv_config.is_enabled and PAM.state == PAM.STATE_DISABLED and IsValid(ply) and table.HasValue(PAM.players_wanting_rtv, ply:SteamID())then
		table.RemoveByValue(PAM.players_wanting_rtv, ply:SteamID())

		local rtv_players_needed = math.ceil(PAM.rtv_config.needed_player_percentage * player.GetCount())
		net.Start("PAM_UnVoteRTV")
		net.WriteEntity(ply)
		net.WriteUInt(rtv_players_needed, 32)
		net.Broadcast()
		
		PAM.CheckForRTV()
	end
end)
