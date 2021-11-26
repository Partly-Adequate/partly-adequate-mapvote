PAM_EXTENSION.name = "special_icons"
PAM_EXTENSION.enabled = true

function PAM_EXTENSION:GetIconMaterial(option)
	if not option.is_special then return end

	if file.Exists("materials/vgui/pam/special_options/" .. option.name .. ".vmt", "GAME") then
		return Material("vgui/pam/special_options/" .. option.name .. ".vmt")
	end
end
