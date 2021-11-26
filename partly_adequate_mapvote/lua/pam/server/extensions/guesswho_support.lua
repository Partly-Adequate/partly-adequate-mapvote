PAM_EXTENSION.name = "guesswho_support"
PAM_EXTENSION.enabled = true

function PAM_EXTENSION:OnInitialize()
	if GAMEMODE_NAME ~= "guesswho" then return end

	-- lolleko/guesswho
	-- Reconstructing MiRe's MapVote api, because guesswho supports only their addon natively
	MapVote = MapVote or {}
	MapVote.Start = function()
		PAM.Start()
	end
	MapVote.Cancel = function()
		PAM.Cancel()
	end


	-- Notify PAM that the round has ended
	hook.Add("GWOnRoundEnd", "PAM_RoundEnded", function()
		PAM.EndRound()
	end)
end
