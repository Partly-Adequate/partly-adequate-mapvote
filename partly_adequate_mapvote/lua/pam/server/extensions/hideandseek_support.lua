PAM_EXTENSION.name = "hideandseek_support"
PAM_EXTENSION.enabled = true

function PAM_EXTENSION:OnInitialize()
	if GAMEMODE_NAME ~= "hideandseek" then return end

	-- Fafy2801/light-hns
	hook.Add("HASVotemapStart", "PAM_Autostart_HAS", function()
		PAM.Start()
		return true
	end)


	-- Notify PAM that the round has ended
	hook.Add("HASRoundEnded", "PAM_RoundEnded", function()
		PAM.EndRound()
	end)
end
