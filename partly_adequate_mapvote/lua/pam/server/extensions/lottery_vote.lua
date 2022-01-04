PAM_EXTENSION.name = "lottery_voting"
PAM_EXTENSION.enabled = true

function PAM_EXTENSION:GetWinningKey(vote_results)
	local vote_sum = 0
	for _, v in pairs(vote_results) do
		vote_sum = vote_sum + v
	end

	local selection = math.random() * vote_sum
	vote_sum = 0

	for k, v in pairs(vote_results) do
		vote_sum = vote_sum + v
		if vote_sum >= selection then
			return k
		end
	end
end
