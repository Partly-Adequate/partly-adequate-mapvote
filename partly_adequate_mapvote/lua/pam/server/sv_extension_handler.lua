-- TODO: Maybe change this to just ask for the extensions to call a global AddOption function instead of returning all their options
function PAM.extension_handler.RegisterOptions()
	for i = 1, #PAM.extensions do
		local extension = PAM.extensions[i]

		if extension.enabled and extension.RegisterSpecialOptions then
			extension.RegisterSpecialOptions()
		end
	end

	for i = 1, #PAM.extensions do
		local extension = PAM.extensions[i]
		if extension.enabled and extension.RegisterOptions then
			extension.RegisterOptions()
		end
	end
end

function PAM.extension_handler.GetWinningKey(vote_results)
	for i = 1, #PAM.extensions do
		local extension = PAM.extensions[i]

		if extension.enabled and extension.GetWinningKey then
			return extension.GetWinningKey(vote_results)
		end
	end
end

function PAM.extension_handler.GetVotePower(steam_id)
	local vote_power = 1

	for i = 1, #PAM.extensions do
		local extension = PAM.extensions[i]

		if extension.enabled and extension.GetVotePowerMultiplier then
			vote_power = vote_power * extension.GetVotePowerMultiplier(steam_id)
		end
	end

	return vote_power
end
