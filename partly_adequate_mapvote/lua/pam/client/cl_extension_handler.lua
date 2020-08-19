function PAM.extension_handler.OnVoteStarted()
	for i = 1,#PAM.extensions do
		local extension = PAM.extensions[i]
		if extension.enabled and extension.OnVoteStarted  then
			extension.OnVoteStarted()
		end
	end
end

function PAM.extension_handler.OnWinnerAnnounced()
	for i = 1, #PAM.extensions do
		local extension = PAM.extensions[i]
		if extension.enabled and extension.OnWinnerAnnounced  then
			extension.OnWinnerAnnounced()
		end
	end
end

function PAM.extension_handler.OnVoteCanceled()
	for i = 1,#PAM.extensions do
		local extension = PAM.extensions[i]
		if extension.enabled and extension.OnVoteCanceled  then
			extension.OnVoteCanceled()
		end
	end
end

function PAM.extension_handler.OnVoterAdded(ply, option_id)
	for i = 1,#PAM.extensions do
		local extension = PAM.extensions[i]
		if extension.enabled and extension.OnVoterAdded  then
			extension.OnVoterAdded(ply, option_id)
		end
	end
end

function PAM.extension_handler.OnVoterRemoved(ply)
	for i = 1,#PAM.extensions do
		local extension = PAM.extensions[i]
		if extension.enabled and extension.OnVoterRemoved  then
			extension.OnVoterRemoved(ply)
		end
	end
end

function PAM.extension_handler.OnRTVVoterAdded(ply)
	for i = 1, #PAM.extensions do
		local extension = PAM.extensions[i]
		if extension.enabled and extension.OnRTVVoterAdded  then
			extension.OnRTVVoterAdded(ply)
		end
	end
end

function PAM.extension_handler.OnRTVVoterRemoved(ply)
	for i = 1, #PAM.extensions do
		local extension = PAM.extensions[i]
		if extension.enabled and extension.OnRTVVoterAdded  then
			extension.OnRTVVoterRemoved(ply)
		end
	end
end

function PAM.extension_handler.OnVoted()
	for i = 1, #PAM.extensions do
		local extension = PAM.extensions[i]
		if extension.enabled and extension.OnVoted  then
			extension.OnVoted()
		end
	end
end

function PAM.extension_handler.OnUnVoted()
	for i = 1, #PAM.extensions do
		local extension = PAM.extensions[i]
		if extension.enabled and extension.OnUnVoted  then
			extension.OnUnVoted()
		end
	end
end

function PAM.extension_handler.OnVotedRTV()
	for i = 1, #PAM.extensions do
		local extension = PAM.extensions[i]
		if extension.enabled and extension.OnVotedRTV  then
			extension.OnVotedRTV()
		end
	end
end

function PAM.extension_handler.OnUnVotedRTV()
	for i = 1, #PAM.extensions do
		local extension = PAM.extensions[i]
		if extension.enabled and extension.OnUnVotedRTV  then
			extension.OnUnVotedRTV()
		end
	end
end

function PAM.extension_handler.GetIconMaterial(option_name)
	local icon = nil
	for i = 1,#PAM.extensions do
		local extension = PAM.extensions[i]
		if extension.enabled and extension.GetIconMaterial then
			icon = extension.GetIconMaterial(option_name)
			if icon then
				return icon
			end
		end
	end
	return nil
end

function PAM.extension_handler.OnOptionFavorited(option_name)
	for i = 1, #PAM.extensions do
		local extension = PAM.extensions[i]
		if extension.enabled and extension.OnOptionFavorited  then
			extension.OnOptionFavorited(option_name)
		end
	end
end

function PAM.extension_handler.OnOptionUnFavorited(option_name)
	for i = 1, #PAM.extensions do
		local extension = PAM.extensions[i]
		if extension.enabled and extension.OnOptionUnFavorited  then
			extension.OnOptionUnFavorited(option_name)
		end
	end
end

function PAM.extension_handler.ToggleVisibility()
	for i = 1, #PAM.extensions do
		local extension = PAM.extensions[i]
		if extension.enabled and extension.ToggleVisibility  then
			extension.ToggleVisibility()
		end
	end
end
