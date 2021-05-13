PAM_EXTENSION.name = "map_icons"
PAM_EXTENSION.enabled = true

function PAM_EXTENSION:GetIconMaterial(option)
	if PAM.vote_type ~= "map" then return end
	if option.is_special then return end

	local map_name = option.name

    if file.Exists("maps/thumb/" .. map_name .. ".png", "GAME") then
        return Material("maps/thumb/" .. map_name .. ".png")
    elseif file.Exists("maps/" .. map_name .. ".png", "GAME") then
        return Material("maps/" .. map_name .. ".png")
    end
end
