local name = "custom_round_counter"

PAM_EXTENSION.name = name
PAM_EXTENSION.enabled = false

local setting_namespace = PAM.setting_namespace:AddChild(name)
local round_limit = setting_namespace:AddSetting("round_limit", pacoman.TYPE_INTEGER, 6)

PAM.custom_round_counter = 0;

function PAM_EXTENSION:OnRoundEnded(self)
	PAM.custom_round_counter = PAM.custom_round_counter + 1

	if PAM.custom_round_counter >= round_limit:GetActiveValue() then
		PAM.Start()
	end
end
