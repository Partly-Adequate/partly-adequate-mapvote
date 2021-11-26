PAM_EXTENSION.name = "murder_support"
PAM_EXTENSION.enabled = true

function PAM_EXTENSION:OnInitialize()
	if GAMEMODE_NAME ~= "murder" then return end

	-- mechanicalmind/murder
	-- Reconstructing MiRe's MapVote api, because murder supports only their addon natively
	MapVote = MapVote or {}
	MapVote.Start = function()
		PAM.Start()
	end
	MapVote.Cancel = function()
		PAM.Cancel()
	end


	-- Notify PAM that the round has ended
	hook.Add("OnEndRound", "PAM_RoundEnded", function()
		PAM.EndRound()
	end)
end
