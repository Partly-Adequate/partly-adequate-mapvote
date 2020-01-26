function PAM.AddToFavorites(mapname)
	if PAM.IsFavorite(mapname) then return end
	sql.Query( "INSERT OR REPLACE INTO pam_maps VALUES( " .. sql.SQLStr(mapname) .. ", " .. 1 .. ")")
end

function PAM.IsFavorite(mapname)
	local data = sql.Query("SELECT is_favorite FROM pam_maps WHERE id IS " .. sql.SQLStr(mapname))
	if data then
		--favorise maps according to database
		if data[1]["is_favorite"] == "1" then
			return true;
		else
			return false;
		end
	else
		--insert new map into database
		sql.Query( "INSERT OR REPLACE INTO pam_maps VALUES( " .. sql.SQLStr(mapname) .. ", " .. 0 .. ")")
	end
	return false;
end

function PAM.RemoveFromFavorites(mapname)
	if not PAM.IsFavorite(mapname) then return end
	sql.Query( "INSERT OR REPLACE INTO pam_maps VALUES( " .. sql.SQLStr(mapname) .. ", " .. 0 .. ")")
end

function PAM.Vote(map_id)
	net.Start("PAM_Vote")
	net.WriteUInt(map_id, 32)
	net.SendToServer()
end

function PAM.UnVote()
	net.Start("PAM_UnVote")
	net.SendToServer()
end

function PAM.WantsRTV(ply)
	return table.HasValue(PAM.players_wanting_rtv, ply)
end

function PAM.VoteRTV()
	if PAM.state == PAM.STATE_DISABLED and not PAM.WantsRTV(LocalPlayer()) then
		net.Start("PAM_VoteRTV")
		net.SendToServer()
	end
end

function PAM.UnVoteRTV()
	if PAM.state == PAM.STATE_DISABLED and PAM.WantsRTV(LocalPlayer())then
		net.Start("PAM_UnVoteRTV")
		net.SendToServer()
	end
end

function PAM.GetMapIconMat(map_name)
	return PAM.extension_handler.GetMapIconMat(map_name)
end
