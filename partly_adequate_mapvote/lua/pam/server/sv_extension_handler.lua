function PAM.extension_handler.RegisterOptions()
	for i = 1, #PAM.extensions do
		local extension = PAM.extensions[i]

		if extension.enabled and extension.RegisterSpecialOptions then
			extension:RegisterSpecialOptions()
		end
	end

	for i = 1, #PAM.extensions do
		local extension = PAM.extensions[i]
		if extension.enabled and extension.RegisterOptions then
			extension:RegisterOptions()
		end
	end
end

function PAM.extension_handler.GetWinningKey(vote_results)
	for i = 1, #PAM.extensions do
		local extension = PAM.extensions[i]

		if extension.enabled and extension.GetWinningKey then
			return extension:GetWinningKey(vote_results)
		end
	end
end

function PAM.extension_handler.GetVotePower(steam_id)
	local vote_power = 1

	for i = 1, #PAM.extensions do
		local extension = PAM.extensions[i]

		if extension.enabled and extension.GetVotePowerMultiplier then
			vote_power = vote_power * extension:GetVotePowerMultiplier(steam_id)
		end
	end

	return vote_power
end

function PAM.extension_handler.OnOptionRegistered(option_id)
	for i = 1, #PAM.extensions do
		local extension = PAM.extensions[i]

		if extension.enabled and extension.OnOptionRegistered then
			extension:OnOptionRegistered(option_id)
		end
	end
end

function PAM.extension_handler.OnGamemodeChanged(gamemode_name)
	for i = 1, #PAM.extensions do
		local extension = PAM.extensions[i]

		if extension.enabled and extension.OnGamemodeChanged then
			extension:OnGamemodeChanged(gamemode_name)
		end
	end
end

function PAM.extension_handler.PreMapChanged(map_name)
	for i = 1, #PAM.extensions do
		local extension = PAM.extensions[i]

		if extension.enabled and extension.PreMapChanged then
			extension:PreMapChanged(map_name)
		end
	end
end

function PAM.extension_handler.OnVoteCanceled()
	for i = 1, #PAM.extensions do
		local extension = PAM.extensions[i]

		if extension.enabled and extension.OnVoteCanceled then
			extension:OnVoteCanceled()
		end
	end
end

function PAM.extension_handler.OnVoterAdded(ply, option_id)
	for i = 1, #PAM.extensions do
		local extension = PAM.extensions[i]

		if extension.enabled and extension.OnVoterAdded then
			extension:OnVoterAdded(ply,option_id)
		end
	end
end

function PAM.extension_handler.OnVoterRemoved(ply)
	for i = 1, #PAM.extensions do
		local extension = PAM.extensions[i]

		if extension.enabled and extension.OnVoterRemoved then
			extension:OnVoterRemoved(ply)
		end
	end
end

function PAM.extension_handler.OnRTVVoterAdded(ply)
	for i = 1, #PAM.extensions do
		local extension = PAM.extensions[i]

		if extension.enabled and extension.OnRTVVoterAdded then
			extension:OnRTVVoterAdded(ply)
		end
	end
end

function PAM.extension_handler.OnRTVVoterRemoved(ply)
	for i = 1, #PAM.extensions do
		local extension = PAM.extensions[i]

		if extension.enabled and extension.OnRTVVoterRemoved then
			extension:OnRTVVoterRemoved(ply)
		end
	end
end

function PAM.extension_handler.OnOptionWon(option)
	for i = 1, #PAM.extensions do
		local extension = PAM.extensions[i]

		if extension.enabled and extension.OnOptionWon then
			extension:OnOptionWon(option)
		end
	end
end
