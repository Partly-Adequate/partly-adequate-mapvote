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

	-- Check for delayed RTV when the round ends
	hook.Add("OnEndRound", "PAM_Autostart_Delayed_RTV_Murder", function()
		PAM.CheckForDelayedRTV()
	end)
end
