PAM_EXTENSION.name = "plurality_voting"
PAM_EXTENSION.enabled = false

function PAM_EXTENSION:GetWinningKey(vote_results)
	return table.GetWinningKey(vote_results)
end
