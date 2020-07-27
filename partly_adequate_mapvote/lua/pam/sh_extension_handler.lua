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

	if not extension.enabled then
		extension.enabled = false
	end

	local enable_cvar_name = "pam_enable_" .. extension.name
	-- TODO create Language System and use it for the helptext
	CreateConVar(enable_cvar_name, extension.enabled and 1 or 0, {FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX, FCVAR_NOTIFY}, "Enables/Disabled the " .. extension.name .. "pam extension")

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

	--enable extension
	if extension.enabled then
		PAM.EnableExtension(extension)
	end
end

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

hook.Add("Initialize", "PAM_Register_Extensions", function()
	PAM.RegisterExtensions()
end)
