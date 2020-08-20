PAM.extension_handler = {}
PAM.extensions = {}

function PAM.DisableExtension(extension)
function PAM.extension_handler.DisableExtension(extension)
	extension.enabled = false
	if extension.OnDisable then
		extension.OnDisable()
	end
end

function PAM.extension_handler.EnableExtension(extension)
	extension.enabled = true
	if extension.OnEnable then
		extension.OnEnable()
	end
end

local function UpdateSetting(extension, setting, current_gm)
	current_gm = current_gm or engine.ActiveGamemode()

	local active_cvar_name = "pam_" .. extension.name .. "_" .. setting

	if extension.gamemode_dependent then
		if GetConVar("pam_" .. extension.name .. "_for_" .. current_gm):GetBool() then
			active_cvar_name = active_cvar_name .. "_" .. current_gm
		end
	end

	local setting_type = type(extension.settings[setting])

	if setting_type == "number" then
		extension.settings[setting] = GetConVar(active_cvar_name):GetInt()
	elseif setting_type == "bool" then
		extension.settings[setting] = GetConVar(active_cvar_name):GetBool()
	else
		extension.settings[setting] = GetConVar(active_cvar_name):GetString()
	end
end

local function UpdateSettings(extension, current_gm)
	current_gm = current_gm or engine.ActiveGamemode()

	for setting, _ in pairs(extension.settings) do
		UpdateSetting(extension, setting, current_gm)
	end
end

local function CreateCorrectlyTypedSettingCvar(cvar_name, value)
	if type(value) == "boolean" then
		CreateConVar(cvar_name, value and 1 or 0, {FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX, FCVAR_NOTIFY}, "This convar was automatically generated.")
	else
		CreateConVar(cvar_name, value, {FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX, FCVAR_NOTIFY}, "This convar was automatically generated.")
	end
end

-- generates cvars for all settings
local function GenerateConVarSettings(extension)
	local gamemodes = engine:GetGamemodes()

	-- generate cvars for each gamemode to allow overriding the defaults
	if extension.gamemode_dependent then
		for i = 1, #gamemodes do
			local gamemode_name = gamemodes[i].name

			local cv_use_custom_settings = CreateConVar("pam_" .. extension.name .. "_for_" .. gamemode_name, 0, {FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX, FCVAR_NOTIFY}, "Set the pam extension \"" .. extension.name .. "\" to use custom settings for " .. gamemode_name)

			cvars.AddChangeCallback(cv_use_custom_settings:GetName(), function()
				UpdateSettings(extension)
			end)
		end

		hook.Add("PAM_OnGamemodeChanged", "PAM_Update" .. "_" .. extension.name, function(new_gm)
			UpdateSettings(extension, new_gm)
		end)
	end

	for setting, value in pairs(extension.settings) do
		local cvar_name = "pam_" .. extension.name .. "_" .. setting

		CreateCorrectlyTypedSettingCvar(cvar_name, value)

		cvars.AddChangeCallback(cvar_name, function(cvar, old_val, new_val)
			UpdateSetting(extension, setting)
		end)

		if extension.gamemode_dependent then
			for i = 1, #gamemodes do
				dependent_cvar_name = cvar_name .. "_" .. gamemodes[i].name

				CreateCorrectlyTypedSettingCvar(dependent_cvar_name, value)

				cvars.AddChangeCallback(dependent_cvar_name, function(cvar, old_val, new_val)
					UpdateSetting(extension, setting)
				end)
			end
		end
	end

	UpdateSettings(extension)
end

function PAM.extension_handler.RegisterExtension(extension)
	local id = #PAM.extensions + 1
	extension.id = id
	PAM.extensions[id] = extension
	print('[PAM] Registering extension "' .. extension.name .. '"!')

	if not extension.settings then
		extension.settings = {}
	end

	local enable_cvar_name = "pam_" .. extension.name .. "_enabled"

	CreateConVar(enable_cvar_name, extension.enabled and 1 or 0, {FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX, FCVAR_NOTIFY}, "Enables/Disables the pam extension \"" .. extension.name .. "\"")

	extension.enabled = GetConVar(enable_cvar_name):GetBool()

	cvars.AddChangeCallback(enable_cvar_name, function(cvar, old_val, new_val)
		if tobool(new_val) and not extension.enabled then
			PAM.extension_handler.EnableExtension(extension)
		elseif not tobool(new_val) and extension.enabled then
			PAM.extension_handler.DisableExtension(extension)
		end
	end)

	GenerateConVarSettings(extension)
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
