net.Receive("PAM_Vote", function(len, ply)
	if PAM.state == PAM.STATE_STARTED and IsValid(ply) then
		local id = net.ReadUInt(32)

		if PAM.options[id] then
			PAM.votes[ply:SteamID()] = id

			net.Start("PAM_Vote")
			net.WriteEntity(ply)
			net.WriteUInt(id, 32)
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
	if GetConVar("pam_rtv_enabled"):GetBool() and PAM.state == PAM.STATE_DISABLED and IsValid(ply) and not table.HasValue(PAM.players_wanting_rtv, ply:SteamID()) then
		table.insert(PAM.players_wanting_rtv, ply:SteamID())

		net.Start("PAM_VoteRTV")
		net.WriteEntity(ply)
		net.Broadcast()

		if not GetConVar("pam_rtv_delayed"):GetBool() then
			PAM.CheckForRTV()
		end
	end
end)

net.Receive("PAM_UnVoteRTV", function(len, ply)
	if GetConVar("pam_rtv_enabled"):GetBool() and PAM.state == PAM.STATE_DISABLED and IsValid(ply) and table.HasValue(PAM.players_wanting_rtv, ply:SteamID()) then
		table.RemoveByValue(PAM.players_wanting_rtv, ply:SteamID())

		net.Start("PAM_UnVoteRTV")
		net.WriteEntity(ply)
		net.Broadcast()
	end
end)
