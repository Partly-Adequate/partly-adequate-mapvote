local extension = {}
extension.name = "plurality_voting"
extension.enabled = true

function extension.GetWinningKey(vote_results)
	return table.GetWinningKey(vote_results)
end

PAM.extension_handler.RegisterExtension(extension)
