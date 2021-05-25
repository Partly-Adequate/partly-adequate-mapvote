PAM.extension_handler = {}
PAM.extensions = {}
local extension_indices = {}
PAM_EXTENSION = {}

local function DisableExtension(extension)
	extension.enabled = false

	if not extension.OnDisable then return end

	extension:OnDisable()
end

local function EnableExtension(extension)
	extension.enabled = true

	if not extension.OnEnable then return end

	extension:OnEnable()
end

local function RegisterExtension(extension)
	local extension = PAM_EXTENSION

	-- cache name
	local extension_name = extension.name

	-- calculate id and set it
	local id = extension_indices[extension_name] or #PAM.extensions + 1
	extension.id = id

	-- Setting creation
	local enabled_setting = PAM.setting_namespace:AddChild(extension.name):AddSetting("enabled", pacoman.TYPE_BOOLEAN, extension.enabled)

	extension.enabled = enabled_setting:GetActiveValue()

	enabled_setting:AddCallback("extension handler", function(value)
		extension.enabled = value

		if value then
			if not extension.OnEnable then return end
			extension:OnEnable()
			return
		end

		if not extension.OnDisable then return end
		extension:OnDisable()
	end)

	-- add extension to table of extensions
	PAM.extensions[id] = extension
	extension_indices[extension_name] = id

	print('[PAM] Registered extension "' .. extension_name .. '" ('.. (extension.enabled and "enabled" or "disabled") .. ")")
end

if SERVER then
	local sv_extensions, _ = file.Find("pam/server/extensions/*.lua", "LUA")
	local cl_extensions, _ = file.Find("pam/client/extensions/*.lua", "LUA")
	for i = 1, #sv_extensions do
		PAM_EXTENSION = {}
		include("pam/server/extensions/" .. sv_extensions[i])
		if PAM_EXTENSION.name then
			RegisterExtension()
		end
	end

	for i = 1, #cl_extensions do
		AddCSLuaFile("pam/client/extensions/" .. cl_extensions[i])
	end
else
	local cl_extensions, _ = file.Find("pam/client/extensions/*.lua", "LUA")
	for i = 1, #cl_extensions do
		PAM_EXTENSION = {}
		include("pam/client/extensions/" .. cl_extensions[i])
		if PAM_EXTENSION.name then
			RegisterExtension()
		end
	end
end

function PAM.extension_handler.OnInitialize()
	for i = 1,#PAM.extensions do
		local extension = PAM.extensions[i]
		if extension.enabled and extension.OnInitialize  then
			extension:OnInitialize()
		end
	end
end

hook.Add("Initialize", "PAM_Initialize_Extensions", PAM.extension_handler.OnInitialize)
