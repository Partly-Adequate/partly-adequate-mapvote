module("pamcon", package.seeall)
pamcon = {}

if not sql.TableExists("pamcon") then
	sql.Query("CREATE TABLE pamcon(id TEXT NOT NULL PRIMARY KEY, value TEXT NOT NULL)")
end

local root = "root"

local settings = {}
local namespaces = {}
namespaces[root] = {
	n_name = root,
	n_settings = {},
	n_children = {},
}

local callbacks = {}
local types = {}

local function GetNamespaceID(path)
	local id = root
	for i = 1, #path do
		id = id .. "/" .. path[i]
	end
	return id
end

local function GetSettingID(path, name)
	return GetNamespaceID(path) .. "/" .. name
end

function AddType(name, to_string, from_string)
	if types[name] then return end

	types[name] = {
		t_to_string = to_string,
		t_from_string = from_string
	}
	return true
end

function AddSetting(path, name, type, value)
	-- check if type is known
	local t = types[type]
	if not t then
		return
	end

	-- make sure the path exists
	local sub_path = root
	for i = 1, #path do
		local segment = path[i]
		local parent = namespaces[sub_path]
		sub_path = sub_path .. "/" .. segment

		-- check if path exists
		if namespaces[sub_path] then continue end

		-- create path
		namespaces[sub_path] = {
			n_name = segment,
			n_children = {},
			n_settings = {}
		}

		-- register path
		parent.n_children[#parent.n_children + 1] = segment
	end

	local id = sub_path .. "/" .. name

	local data = sql.QueryValue("SELECT value FROM pamcon WHERE id IS " .. sql.SQLStr(id))
	if not data then
		sql.Query("INSERT INTO pamcon VALUES(".. sql.SQLStr(id) ..", ".. sql.SQLStr(t.t_to_string(value)) .. ")")
	else
		value = t.t_from_string(data)
	end

	-- create setting
	settings[id] = {
		s_name = name,
		s_namespace = sub_path,
		s_type = type,
		s_value = value
	}

	-- initialize callback table
	callbacks[id] = {}

	-- register setting in namespace
	local namespace = namespaces[sub_path]
	namespace.n_settings[#namespace.n_settings + 1] = name

	return true
end

function GetSetting(path, name)
	local setting_id = GetSettingID(path, name)
	local setting = settings[setting_id]
	if not setting then return end

	return setting.s_value
end

function ChangeSetting(path, name, value)
	local setting_id = GetSettingID(path, name)
	local setting = settings[setting_id]
	if not setting then return end

	local old_value = setting.s_value

	local t = types[setting.s_type]
	local serialized_value = t.t_to_string(value)
	setting.s_value = value

	local callbacks = callbacks[setting_id]
	for i = 1, #callbacks do
		callbacks[i](old_value, value)
	end

	sql.Query("INSERT OR REPLACE INTO pamcon VALUES(".. sql.SQLStr(setting_id) ..", ".. sql.SQLStr(serialized_value) .. ")")

	return true
end

function GetSettingType(path, name)
	local setting_id = GetSettingID(path, name)
	local setting = settings[setting_id]
	if not setting then return end

	return setting.s_type
end

function GetSettings(path)
	local namespace_id = GetNamespaceID(path)
	local namespace = namespaces[namespace_id]
	if not namespace then
		return {}
	end

	local settings = {}

	for i = 1, #namespace.n_settings do
		settings[i] = namespace.n_settings[i]
	end

	return settings
end

function GetNamespaceChildren(name)
	local namespace_id = GetNamespaceID(path)
	local namespace = namespaces[namespace_id]
	if not namespace then
		return {}
	end

	local children = {}

	for i = 1, #namespace.n_children do
		children[i] = namespace.n_children[i]
	end

	return children
end

function AddCallback(path, name, callback)
	local callbacks = callbacks[GetSettingID(path, name)]
	callbacks[#callbacks + 1] = callback
end

function PrintAll()
	print("Settings:")
	PrintTable(settings)
	print("Namespaces:")
	PrintTable(namespaces)
end

AddType("number", tostring, tonumber)
AddType("string", tostring, tostring)
AddType("bool", tostring, tobool)
