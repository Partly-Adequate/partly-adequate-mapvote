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

	-- generate cvars for all settings
	for k,v in pairs(extension.settings) do
		-- TODO Integrate helptext into Language System
		local cvar_name = "pam_" .. k
		local cvar_type = type(v)
		if cvar_type == "number" then
			CreateConVar(cvar_name, tostring(v), {FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX, FCVAR_NOTIFY}, "This convar was automatically generated.")
			extension.settings[k] = GetConVar(cvar_name):GetInt()
			cvars.AddChangeCallback(cvar_name, function(cvar, old_val, new_val)
				extension.settings[k] = tonumber(new_val)
			end)
		elseif cvar_type == "boolean" then
			CreateConVar(cvar_name, tostring(v), {FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX, FCVAR_NOTIFY}, "This convar was automatically generated.")
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
