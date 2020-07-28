local extension = {}
extension.name = "murder_support"
extension.enabled = true

function extension.OnInitialize()
	if GAMEMODE_NAME ~= "murder" then
		-- Reconstructing MiRe's MapVote api, because murder supports only their addon natively
		MapVote = {}
		MapVote.Start = function(a, b, c, d)
			PAM.Start()
		end

		-- Check for delayed RTV when the round ends
		hook.Add("OnEndRound", "PAM_Autostart_Delayed_RTV_Murder", function()
			PAM.CheckForDelayedRTV()
		end)
		return
	end
end

PAM.RegisterExtension(extension)
