local extension = {}
extension.name = "Default Map Icons"
extension.settings = {
	is_enabled = true
}

function extension.GetMapIconMat(map_name)
    if file.Exists("maps/thumb/" .. map_name .. ".png", "GAME") then
        return Material("maps/thumb/" .. map_name .. ".png")
    elseif file.Exists("maps/" .. map_name .. ".png", "GAME") then
        return Material("maps/" .. map_name .. ".png")
    end
    return nil
end

hook.Add("PAM_Register_Extensions", "PAM_Register_Default_Map_Icons", function()
	PAM.RegisterExtension(extension)
end)
