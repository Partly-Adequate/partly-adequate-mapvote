local extension = {}
extension.name = "hideandseek_support"
extension.enabled = true

function extension.OnInitialize()
	if GAMEMODE_NAME ~= "hideandseek" then return end

	-- Fafy2801/light-hns
	hook.Add("HASVotemapStart", "PAM_Autostart_HNS", function()
		PAM.Start()
		return true
	end)

	-- Check for delayed RTV when the round ends
	hook.Add("HASRoundEnded", "PAM_Autostart_Delayed_RTV_HNS", function()
		PAM.CheckForDelayedRTV()
	end)
end

PAM.extension_handler.RegisterExtension(extension)
