PAM.extension_handler = {}
PAM.extensions = {}

function PAM.RegisterExtensions()
	print("[PAM] Registering extensions!")
	hook.Run("PAM_Register_Extensions")
end

function PAM.RegisterExtension(extension)
	local id = #PAM.extensions + 1
	extension.id = id
	PAM.extensions[id] = extension
	print('[PAM] Registering extension "' .. extension.name .. '"!')

	if not extension.settings then
		extension.settings = {}
	end

	--enable extension
	if extension.settings.is_enabled then
		print('[PAM] Enabling extension "' .. extension.name .. '"!')
		if extension.OnEnable then
			extension.OnEnable()
		end
	end
end

function PAM.DisableExtension(extension)
	extension.settings.is_enabled = false
	if extension.OnDisable then
		extension.OnDisable()
	end
end

function PAM.EnableExtension(extension)
	extension.settings.is_enabled = true
	if extension.OnEnable then
		extension.OnEnable()
	end
end

hook.Add("Initialize", "PAM_Register_Extensions", function()
	PAM.RegisterExtensions()
end)
