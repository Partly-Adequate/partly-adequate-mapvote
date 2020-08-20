local extension = {}
extension.name = "special_icons"
extension.enabled = true

function extension.GetIconMaterial(option)
	if not option.is_special then return end

	local option_name = "img_" .. option.name

    if file.Exists("materials/vgui/pam/" .. option_name .. ".vmt", "GAME") then
        return Material("vgui/pam/" .. option_name .. ".vmt")
    end
end

PAM.extension_handler.RegisterExtension(extension)
