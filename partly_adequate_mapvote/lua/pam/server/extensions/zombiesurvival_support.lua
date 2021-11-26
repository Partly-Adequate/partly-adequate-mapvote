PAM_EXTENSION.name = "zombiesurvival_support"
PAM_EXTENSION.enabled = true

function PAM_EXTENSION:OnInitialize()
	if GAMEMODE_NAME ~= "zombiesurvival" then return end

	-- jetboom/zombiesurvival
	hook.Add("LoadNextMap", "PAM_Autostart_ZombieSurvival", function()
		PAM.Start()
		return true
	end)


	hook.Add("PostEndRound", "PAM_RoundEnded", function()
		PAM.EndRound()
	end)
end
