local extension = {}
extension.name = "default_map_icons"
extension.enabled = true

function extension.GetMapIconMat(map_name)
    if file.Exists("maps/thumb/" .. map_name .. ".png", "GAME") then
        return Material("maps/thumb/" .. map_name .. ".png")
    elseif file.Exists("maps/" .. map_name .. ".png", "GAME") then
        return Material("maps/" .. map_name .. ".png")
    end
    return nil
end

PAM.RegisterExtension(extension)
