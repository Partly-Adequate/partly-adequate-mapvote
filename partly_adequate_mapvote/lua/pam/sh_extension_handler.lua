PAM.extension_handler = {}
PAM.extensions = {}

function PAM.DisableExtension(extension)
	extension.enabled = false
	if extension.OnDisable then
		extension.OnDisable()
	end
end

function PAM.EnableExtension(extension)
	extension.enabled = true
	if extension.OnEnable then
		extension.OnEnable()
	end
end

function PAM.RegisterExtension(extension)
	local id = #PAM.extensions + 1
	extension.id = id
	PAM.extensions[id] = extension
	print('[PAM] Registering extension "' .. extension.name .. '"!')

	if not extension.settings then
		extension.settings = {}
	end

	local enable_cvar_name = "pam_enable_" .. extension.name

	CreateConVar(enable_cvar_name, extension.enabled and 1 or 0, {FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX, FCVAR_NOTIFY}, "Enables/Disables the pam extension \"" .. extension.name .. "\"")

	extension.enabled = GetConVar(enable_cvar_name):GetBool()

	cvars.AddChangeCallback(enable_cvar_name, function(cvar, old_val, new_val)
		if tobool(new_val) and not extension.enabled then
			PAM.EnableExtension(extension)
		elseif not tobool(new_val) and extension.enabled then
			PAM.DisableExtension(extension)
		end
	end)

	-- generate cvars for all settings
	for k,v in pairs(extension.settings) do
		-- TODO create Language System and use it for the helptext
		local cvar_name = "pam_" .. k
		local cvar_type = type(v)
		if cvar_type == "number" then
			CreateConVar(cvar_name, tostring(v), {FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX, FCVAR_NOTIFY}, "This convar was automatically generated.")
			extension.settings[k] = GetConVar(cvar_name):GetInt()
			cvars.AddChangeCallback(cvar_name, function(cvar, old_val, new_val)
				extension.settings[k] = tonumber(new_val)
			end)
		elseif cvar_type == "boolean" then
			CreateConVar(cvar_name, v and 1 or 0, {FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX, FCVAR_NOTIFY}, "This convar was automatically generated.")
			extension.settings[k] = GetConVar(cvar_name):GetBool()
			cvars.AddChangeCallback(cvar_name, function(cvar, old_val, new_val)
				extension.settings[k] = tobool(new_val)
			end)
		elseif cvar_type == "string" then
			CreateConVar(cvar_name, tostring(v), {FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX, FCVAR_NOTIFY}, "This convar was automatically generated.")
			extension.settings[k] = GetConVar(cvar_name):GetString()
			cvars.AddChangeCallback(cvar_name, function(cvar, old_val, new_val)
				extension.settings[k] = tostring(new_val)
			end)
		end
		print(cvar_name .. " = " .. tostring(extension.settings[k]) .. " (" .. cvar_type .. ")")
	end
end

if SERVER then
	local sv_extensions, _ = file.Find("pam/server/extensions/*.lua", "LUA")
	local cl_extensions, _ = file.Find("pam/client/extensions/*.lua", "LUA")
	for i = 1, #sv_extensions do
		local sv_extension = sv_extensions[i]
		include("pam/server/extensions/" .. sv_extension)
	end

	for i = 1, #cl_extensions do
		local cl_extension = cl_extensions[i]
		AddCSLuaFile("pam/client/extensions/" .. cl_extension)
	end
else
	local cl_extensions, _ = file.Find("pam/client/extensions/*.lua", "LUA")
	for i = 1, #cl_extensions do
		local cl_extension = cl_extensions[i]
		include("pam/client/extensions/" .. cl_extension)
	end
end

function PAM.extension_handler.OnInitialize()
	for i = 1,#PAM.extensions do
		local extension = PAM.extensions[i]
		if extension.enabled and extension.OnInitialize  then
			extension.OnInitialize()
		end
	end
end

hook.Add("Initialize", "PAM_Initialize_Extensions", PAM.extension_handler.OnInitialize)
