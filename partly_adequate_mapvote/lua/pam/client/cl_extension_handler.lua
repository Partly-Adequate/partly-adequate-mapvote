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
	--check extension in database
	local data = sql.Query("SELECT is_enabled FROM pam_extensions WHERE id IS " .. sql.SQLStr(extension.id))
	if data then
		--enable/disable extension according to database
		if data[1]["is_enabled"] == "1" then
			extension.is_enabled = true;
		else
			extension.is_enabled = false;
		end
	else
		--insert new extension into database
		sql.Query( "INSERT OR REPLACE INTO pam_extensions VALUES( " .. sql.SQLStr(extension.id) .. ", " .. (extension.is_enabled and 1 or 0) .. ")")
	end
	--enable extension
	if(extension.is_enabled) then
		if extension.OnEnable then
			extension.OnEnable()
		end
	end
end

function PAM.DisableExtension(id)
	local extension = PAM.extensions[id]
	extension.is_enabled = false
	sql.Query( "INSERT OR REPLACE INTO pam_extensions VALUES( " .. sql.SQLStr(extension.id) .. ", " .. 0 .. ")")
	if extension.OnDisable then
		extension.OnDisable()
	end
end

function PAM.EnableExtension(id)
	local extension = PAM.extensions[id]
	extension.is_enabled = true
	sql.Query( "INSERT OR REPLACE INTO pam_extensions VALUES( " .. sql.SQLStr(extension.id) .. ", " .. 1 .. ")")
	if extension.OnEnable then
		extension.OnEnable()
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
