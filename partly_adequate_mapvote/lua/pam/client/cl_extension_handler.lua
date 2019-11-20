PAM.extension_handler = {}
PAM.extensions = {}

function PAM.ReloadExtensions()
	for _, extension in ipairs(PAM.extensions) do
		PAM.DisableExtension(extension.id)
	end
	table.Empty(PAM.extensions)

	print("[PAM] Registering extensions!")
	hook.Run("PAM_Register_Client_Extensions")
end

function PAM.RegisterExtension(extension)
	PAM.extensions[extension.id] = extension
	print('[PAM] Registering extension "' .. extension.id .. '"!')
	-- TODO search for extension in db and enable/disable accordingly
end

function PAM.DisableExtension(id)
	PAM.extensions[id].is_enabled = false
	if PAM.extensions[id].OnDisable then
		PAM.extensions[id].OnDisable()
	end
end

function PAM.EnableExtension(id)
	PAM.extensions[id].is_enabled = true
	if PAM.extensions[id].OnEnable then
		PAM.extensions[id].OnEnable()
	end
end

function PAM.extension_handler.OnVoteStarted()
	for _, extension in pairs(PAM.extensions) do
		if extension.is_enabled and extension.OnVoteStarted  then
			extension.OnVoteStarted()
		end
	end
end

function PAM.extension_handler.OnVoteCanceled()
	for _, extension in pairs(PAM.extensions) do
		if extension.is_enabled and extension.OnVoteCanceled  then
			extension.OnVoteCanceled()
		end
	end
end

function PAM.extension_handler.OnVoterAdded(ply, map_id)
	for _, extension in pairs(PAM.extensions) do
		if extension.is_enabled and extension.OnVoterAdded  then
			extension.OnVoterAdded(ply, map_id)
		end
	end
end

function PAM.extension_handler.GetMapIconMat(map_name)
	local icon = nil
	for _, extension in pairs(PAM.extensions) do
		if extension.is_enabled and extension.GetMapIconMat  then
			icon = extension.GetMapIconMat(map_name)
			if icon then
				return icon
			end
		end
	end
	return nil
end

function PAM.extension_handler.OnVoterRemoved(ply)
	for _, extension in pairs(PAM.extensions) do
		if extension.is_enabled and extension.OnVoterRemoved  then
			extension.OnVoterRemoved(ply)
		end
	end
end

function PAM.extension_handler.OnRTVVoterAdded(ply)
	for _, extension in pairs(PAM.extensions) do
		if extension.is_enabled and extension.OnRTVVoterAdded  then
			extension.OnRTVVoterAdded(ply)
		end
	end
end

function PAM.extension_handler.OnRTVVoterRemoved(ply)
	for _, extension in pairs(PAM.extensions) do
		if extension.is_enabled and extension.OnRTVVoterAdded  then
			extension.OnRTVVoterRemoved(ply)
		end
	end
end

function PAM.extension_handler.OnWinnerAnnounced()
	for _, extension in pairs(PAM.extensions) do
		if extension.is_enabled and extension.OnWinnerAnnounced  then
			extension.OnWinnerAnnounced()
		end
	end
end

function PAM.extension_handler.ToggleVisibility()
	for _, extension in pairs(PAM.extensions) do
		if extension.is_enabled and extension.ToggleVisibility  then
			extension.ToggleVisibility()
		end
	end
end

hook.Add("Initialize", "PAM_GuiManager", function()
	PAM.ReloadExtensions()
end)
