-- cancels the vote on this client
function PAM.Cancel()
	PAM.state = PAM.STATE_DISABLED

	PAM.extension_handler.RunEvent("OnVoteCanceled")
end

-- makes the client announce a winner
function PAM.AnnounceWinner(option_id)
	PAM.winning_option = PAM.options[option_id]
	PAM.state = PAM.STATE_FINISHED

	PAM.extension_handler.RunEvent("OnOptionWon", option)
end

-- voting
-- Adds a voter to the clients information
function PAM.AddVoter(ply, option_id)
	PAM.votes[ply:SteamID()] = option_id

	PAM.extension_handler.RunEvent("OnVoterAdded", ply, option_id)
end

-- removes a voter from the clients information
function PAM.RemoveVoter(ply)
	PAM.votes[ply:SteamID()] = false

	PAM.extension_handler.RunEvent("OnVoterRemoved", ply)
end

-- makes the client vote for an option
function PAM.Vote(option_id)
	if PAM.state ~= PAM.STATE_STARTED then return end

	net.Start("PAM_Vote")
	net.WriteUInt(option_id, 32)
	net.SendToServer()
end

-- makes the client withdraw their vote
function PAM.UnVote()
	if PAM.state ~= PAM.STATE_STARTED then return end

	net.Start("PAM_UnVote")
	net.SendToServer()
end

-- option icons
-- returns a material for the option name or nil when no material was found
function PAM.GetIconMaterial(option_name)
	return PAM.extension_handler.RunReturningEvent("GetIconMaterial", option_name)
end

-- favorising
function PAM.IsFavorite(option_name)
	local data = sql.Query("SELECT is_favorite FROM pam_options WHERE id IS " .. sql.SQLStr(option_name))
	if data then
		--favorise maps according to database
		if data[1]["is_favorite"] == "1" then
			return true;
		else
			return false;
		end
	else
		--insert new map into database
		sql.Query( "INSERT OR REPLACE INTO pam_options VALUES( " .. sql.SQLStr(option_name) .. ", " .. 0 .. ")")
	end
	return false;
end

-- adds an option to favorites
function PAM.AddToFavorites(option_name)
	if PAM.IsFavorite(option_name) then return end

	sql.Query( "INSERT OR REPLACE INTO pam_options VALUES( " .. sql.SQLStr(option_name) .. ", " .. 1 .. ")")

	PAM.extension_handler.RunEvent("OnOptionFavorited", option_name)
end

-- removes an option from favorites
function PAM.RemoveFromFavorites(option_name)
	if not PAM.IsFavorite(option_name) then return end

	sql.Query( "INSERT OR REPLACE INTO pam_options VALUES( " .. sql.SQLStr(option_name) .. ", " .. 0 .. ")")

	PAM.extension_handler.RunEvent("OnOptionUnFavorited", option_name)
end
