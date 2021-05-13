PAM_EXTENSION.name = "special_icons"
PAM_EXTENSION.enabled = true

function PAM_EXTENSION:GetIconMaterial(option)
	if not option.is_special then return end

	local option_name = "img_" .. option.name

    if file.Exists("materials/vgui/pam/" .. option_name .. ".vmt", "GAME") then
        return Material("vgui/pam/" .. option_name .. ".vmt")
    end
end
