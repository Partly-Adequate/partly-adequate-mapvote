module("pamcon", package.seeall)
pamcon = {}

local roots = {}

-- serializes any value
-- uses TableToJSON internally and has all it's bugs
local function Serialize(value)
	local serializable = {}
	serializable.value = value
	return util.TableToJSON(serializable)
end

-- deserializes any value
-- uses TableToJSON internally and has all it's bugs
local function Deserialize(str)
	local deserialized = util.JSONToTable(str)
	return deserialized and deserialized.value
end

-- create table for storing values
if not sql.TableExists("pamcon_values") then
	sql.Query("CREATE TABLE pamcon_values(id TEXT NOT NULL PRIMARY KEY, value TEXT NOT NULL)")
end

-- stores a value
local function StoreValue(storage_id, value)
	-- serialize
	local serialized = Serialize(value)

	-- insert or replace value into database
	sql.Query("INSERT OR REPLACE INTO pamcon_values VALUES( " .. SQLStr(storage_id) .. ", " .. SQLStr(serialized) .. ")")
end

-- returns a stored value
local function GetStoredValue(storage_id)
	-- get data
	local data = sql.Query("SELECT value FROM pamcon_values WHERE id IS " .. SQLStr(storage_id))

	-- return nil when no data was found
	if not data then return end

	-- return deserialized value
	return Deserialize(data[1]["value"])
end

-- external callbacks
local external_callbacks = {}

-- calls all external callbacks that were registered under the callback_id and provides the setting as a parameter for these
local function CallExternalCallbacks(callback_id, setting)
	-- tries to find callbacks
	local cbs = external_callbacks[callback_id]

	-- returns nil when no callbacks were found
	if not cbs then return end

	-- calls callbacks
	for i = 1, #cbs do
		cbs[i](setting)
	end
end

-- adds an external callback to the callbacks at the callback_id
local function AddExternalCallback(callback_id, callback)
	-- tries to find callbacks
	local cbs = external_callbacks[callback_id]

	-- adds callbacks table if necessary
	if not cbs then
		cbs = {}
		external_callbacks[callback_id] = cbs
	end

	-- adds callback to callbacks table
	local index = #cbs + 1
	cbs[index] = callback
end

-- Namespace class
local Namespace = {}
Namespace.__index = Namespace

-- creates a new Namespace
function Namespace:Create(id)
	-- create new Namespace
	local namespace = {}
	setmetatable(namespace, Namespace)

	-- set attributes
	namespace.id = id
	namespace.children = {}
	namespace.children_indices = {}
	namespace.settings = {}
	namespace.setting_indices = {}

	-- return new namespace
	return namespace
end

-- creates a new Namespace and adds it to the roots table
function Namespace:CreateAsRoot(id)
	-- creates a new namespace
	local namespace = Namespace:Create(id)

	-- adds it to the roots table
	roots[id] = namespace

	-- returns the new namespace
	return namespace
end

-- adds the child Namespace
function Namespace:AddChild(child)
	-- calculate index
	local index = self.children_indices[child:GetID()] or #self.children + 1

	-- add child Namespace
	self.children[index] = child
	self.children_indices[child:GetID()] = index
end

-- adds the Setting
-- it creates Namespaces if necessary
function Namespace:AddSetting(setting)
	-- calculate index
	local index = self.setting_indices[setting:GetID()] or #self.settings + 1

	-- add Setting
	self.settings[index] = setting
	self.setting_indices[setting:GetID()] = index
end

-- returns the id of the Namespace
function Namespace:GetID()
	-- return id of found Namespace
	return self.id
end

function Namespace:GetChild(child_id)
	-- get index
	local index = self.children_indices[child_id]

	-- return nil when child doesn't exist
	if not index then return end

	-- return child
	return self.children[index]
end

-- returns this Namespace's children
function Namespace:GetChildren()
	-- return children
	return self.children
end

-- returns the child Namespace at the given path
-- it returns nil when the path can't be followed
function Namespace:GetChildAtPath(path)
	-- follows the path and creates namespaces if necessary
	local current = self
	for i = 1, #path do
		local id = path[i]
		-- tries to get the next Namespace
		local next = current:GetChild(id)

		if not next then return end

		-- advances to the next namespace
		current = next
	end

	-- return child
	return current
end

-- returns the child at the given path
-- it creates missing namespaces when necessary
function Namespace:AddChildrenAlongPath(path)
	-- follows the path and creates namespaces if necessary
	local current = self
	for i = 1, #path do
		local id = path[i]
		-- tries to get the next Namespace
		local next = current:GetChild(id)

		if not next then
			-- creates a new Namespace to be used as the next one
			next = Namespace:Create(id)
			current:AddChild(next)
		end

		-- advances to the next namespace
		current = next
	end

	-- return child
	return current
end

-- returns this Namespace's Setting with the given id at the given path
function Namespace:GetSetting(setting_id)
	-- get index
	local index = self.setting_indices[setting_id]

	-- return nil when setting doesn't exist
	if not index then return end

	-- return setting
	return self.settings[index]
end

-- returns this Namespace's Settings at the given path
function Namespace:GetSettings()
	-- return Settings of found Namespace
	return self.settings
end

-- Setting class
local Setting = {}
Setting.__index = Setting

-- creates a new Setting
function Setting:Create(id, type_id, value_validator, value)
	-- create new Setting
	local setting = {}
	setmetatable(setting, Setting)

	if value_validator and not value_validator(value) then return end

	-- set attributes
	setting.id = id
	setting.type_id = type_id
	setting.value_validator = value_validator
	setting.value = value
	setting.callbacks = {}

	-- return setting
	return setting
end

-- returns this Setting's type_id
function Setting:GetType()
	return self.type_id
end

-- returns this Setting's value_validator
function Setting:GetValidator()
	return self.value_validator
end

-- returns this Setting's id
function Setting:GetID()
	return self.id
end

-- returns this Setting's value
function Setting:GetValue()
	return self.value
end

-- adds a callback to this Setting
function Setting:AddCallback(callback)
	-- calculate index
	local index = #self.callbacks + 1

	-- register callback
	self.callbacks[index] = callback
end

-- changes the value of this Setting and calls all callbacks with the new value as a parameter
function Setting:SetValue(new_value)
	if self.value_validator and not self.value_validator(new_value) then return end

	-- update value
	self.value = new_value
	-- call callbacks
	for i = 1, #self.callbacks do
		self.callbacks[i](self)
	end
end

local path_separator = "/"

-- replaces any occurrence of path_separators with two path_separators
-- it's used internally to make sure path_ids are always unique
local function ValidateString(str)
	return string.Replace(str, path_separator, path_separator .. path_separator)
end

-- converts a path to a setting to a unique string
local function PathToID(root, path, setting_id)
	-- add root
	local path_id = ValidateString(root:GetID()) .. path_separator

	-- add segments of path
	for i = 1, #path do
		path_id = path_id .. ValidateString(path[i]) .. path_separator
	end

	-- add setting id and return
	return path_id .. ValidateString(setting_id)
end

-- converts a path_id to a path
local function IDToPath(path_id)
	-- this will store the values
	local root_id
	local path = {}

	-- rough split with some mistakes wherever a segment contains a path_separator
	local split_values = string.Split(path_id, path_separator)
	-- temporary variable for accumulating segments
	local current = ""
	-- temporary variable for checking if the amount of path separators is even or odd
	local append = false

	-- fixes splitting mistakes and stores the properly split version in formatted_values
	for i = 1, #split_values do
		local value = split_values[i]
		if append then
			current = current .. value
			append = false
		elseif value == "" then
			current = current .. path_separator
			append = true
		else
			current = current .. value
			if not root_id then
				root_id = current
			else
				path[#path + 1] = current
			end
			current = ""
		end
	end

	-- get the setting_id
	local setting_id = path[#path]
	-- remove the setting_id from the path
	path[#path] = nil

	-- return everything
	return roots[root_id], path, setting_id
end

-- checks if a value is a boolean
function BooleanValidator(value)
	return not value or type(value) == "boolean"
end

-- checks if a value is a string
function StringValidator(value)
	return value and type(value) == "string"
end

-- checks if a value is a number
function NumberValidator(value)
	return value and type(value) == "number"
end

-- checks if a value is an integer
function IntegerValidator(value)
	return value and type(value) == "number" and math.floor(value) == value
end

-- checks if a value is a number that's bigger or equal to 0 and smaller or equal to 100
function PercentageValidator(value)
	return value and type(value) == "number" and value >= 0 and value <= 100
end

if SERVER then
	util.AddNetworkString("PAMCON_RequestServerSettings")
	util.AddNetworkString("PAMCON_ChangeSetting")

	local server_settings_id = "server_settings"
	local client_overrides_id = "client_overrides"

	server_settings = Namespace:CreateAsRoot(server_settings_id)
	client_overrides = Namespace:CreateAsRoot(client_overrides_id)

	-- informs all clients on a change in a server setting
	local function BroadcastChange(path, id, value)
		net.Start("PAMCON_ChangeSetting")
		net.WriteBool(false)
		net.WriteString(Serialize(path))
		net.WriteString(id)
		net.WriteString(Serialize(value))
		net.Broadcast()
	end

	-- informs all clients on a change in a client override
	local function BroadcastOverrideChange(path, id, value)
		net.Start("PAMCON_ChangeSetting")
		net.WriteBool(true)
		net.WriteString(Serialize(path))
		net.WriteString(id)
		net.WriteString(Serialize(value))
		net.Broadcast()
	end

	-- creates/replaces a server setting
	function AddSetting(path, id, type, value_validator, value)
		-- makes sure the value fits the type
		if value_validator and not value_validator(value) then return end

		-- gets the id for storage
		local path_id = PathToID(server_settings, path, id)

		-- gets stored value if possible
		local stored_value = GetStoredValue(path_id)

		-- checks stored value
		if not value_validator or value_validator(stored_value) then
			value = stored_value
		end

		-- create Setting
		local setting = Setting:Create(id, type, value_validator, value)

		-- add Setting to server_settings
		server_settings:AddChildrenAlongPath(path):AddSetting(setting)

		-- store value whenever it's changed
		setting:AddCallback(function(setting)
			StoreValue(path_id, setting:GetValue())
		end)

		-- inform clients whenever it's changed
		setting:AddCallback(function(setting)
			BroadcastChange(path, id, setting:GetValue())
		end)

		-- call special callbacks whenever it's changed
		setting:AddCallback(function(setting)
			CallExternalCallbacks(path_id, setting)
		end)

		-- inform clients about new setting
		BroadcastChange(path, id, setting:GetValue())
	end

	-- returns the value of previously added Setting
	-- returns nil when no setting with the given id exists in the given path
	function GetSetting(path, id)
		-- gets Namespace
		local namespace = server_settings:GetChildAtPath(path)

		-- returns nil when the Namespace isn't found
		if not namespace then return end

		-- gets the Setting
		local setting = namespace:GetSetting(id)

		-- returns nil when the Setting isn't found
		if not setting then return end

		-- returns the Setting's value
		return setting:GetValue()
	end

	-- adds the given callback to the setting with the given id at the given path
	function AddCallback(path, id, callback)
		-- gets the Setting's unique id
		local path_id = PathToID(server_settings, path, id)

		-- adds an external callback for this setting
		AddExternalCallback(path_id, function(setting)
			callback(setting:GetValue())
		end)
	end

	-- creates/replaces a client override
	local function AddClientOverride(path, id, value)
		-- get id for storage
		local path_id = PathToID(client_overrides, path, id)

		-- get stored value if possible
		value = GetStoredValue(path_id) or value

		-- create Setting
		local setting = Setting:Create(id, "override", nil, value)

		-- add Setting to client_overrides
		client_overrides:AddChildrenAlongPath(path):AddSetting(setting)

		-- store value whenever it's changed
		setting:AddCallback(function(setting)
			StoreValue(path_id, setting:GetValue())
		end)

		-- inform clients whenever it's changed
		setting:AddCallback(function(setting)
			BroadcastOverrideChange(path, id, setting:GetValue())
		end)

		-- inform clients about new override
		StoreValue(path_id, setting:GetValue())
		BroadcastOverrideChange(path, id, setting:GetValue())
	end

	-- writes a Setting to the current netmessage
	local function SendSetting(setting)
		net.WriteString(setting:GetID())
		net.WriteString(setting:GetType())
		net.WriteString(Serialize(setting:GetValue()))
	end

	-- writes a Namespace to the current netmessage
	local function SendNamespace(namespace)
		net.WriteString(namespace:GetID())

		local children = namespace:GetChildren()
		local child_count = #children
		net.WriteUInt(child_count, 32)

		for i = 1, child_count do
			SendNamespace(children[i])
		end

		local settings = namespace:GetSettings()
		local setting_count = #settings

		net.WriteUInt(setting_count, 32)
		for i = 1, setting_count do
			SendSetting(settings[i])
		end
	end

	net.Receive("PAMCON_RequestServerSettings",function(len, ply)
		net.Start("PAMCON_RequestServerSettings")

		SendNamespace(server_settings)
		SendNamespace(client_overrides)

		net.Send(ply)
	end)

	net.Receive("PAMCON_ChangeSetting", function(len, ply)
		local is_override = net.ReadBool()
		local root = is_override and client_overrides or server_settings
		local path = Deserialize(net.ReadString())
		local id = net.ReadString()
		local value = Deserialize(net.ReadString())

		-- TODO add api for permissions
		if not IsValid(ply) or not ply:IsSuperAdmin() then return end

		local namespace = root:GetChildAtPath(path)

		if namespace then
			local setting = namespace:GetSetting(id)
			if setting then
				setting:SetValue(value)
				return
			end
		end

		if not is_override then return end

		AddClientOverride(path, id, value)
	end)

	local data = sql.Query("SELECT id,value FROM pamcon_values")
	if data then
		for i = 1, #data do
			local datum = data[i]
			local root, path, id = IDToPath(datum["id"])
			if root and root == client_overrides then
				AddClientOverride(path, id, Deserialize(datum.value))
			end
		end
	end
else
	local client_settings_id = "client_settings"
	local server_settings_id = "server_settings"
	local client_overrides_id = "client_overrides"

	-- root namespace for all client settings
	client_settings = Namespace:CreateAsRoot(client_settings_id)
	-- root namespace for a copy of all server settings
	server_settings = Namespace:CreateAsRoot(server_settings_id)
	-- root namespace for a copy of all client overrides
	client_overrides = Namespace:CreateAsRoot(client_overrides_id)

	-- creates/replaces a client setting
	function AddSetting(path, id, type, value_validator, value)
		if value_validator and not value_validator(value) then return end

		-- get id for storage
		path_id = PathToID(client_settings, path, id)

		-- get stored value if possible
		local stored_value = GetStoredValue(path_id)

		-- use stored value when it's valid
		if not value_validator or value_validator(stored_value) then
			value = stored_value
		end

		-- create Setting
		local setting = Setting:Create(id, type, value_validator, value)

		-- add Setting to client_settings
		client_settings:AddChildrenAlongPath(path):AddSetting(setting)

		-- store value whenever it's changed
		setting:AddCallback(function(new_value)
			StoreValue(path_id, new_value)
		end)

		-- call special callbacks whenever it's changed and no override exists
		setting:AddCallback(function(setting)
			local override_namespace = client_overrides:GetChildAtPath(path)

			if override_namespace and override_namespace:GetSetting(id) then return end

			CallExternalCallbacks(path_id, setting)
		end)
	end

	-- returns the value of the client setting with the given id at the given path
	-- when an override exists it will return the value of the override
	-- returns nil when no setting with the given id exists in the given path
	function GetSetting(path, id)
		-- tries to get the namespace the override setting would be stored under
		local override_namespace = client_overrides:GetChildAtPath(path)

		-- checks if override value can exist
		if override_namespace then
			-- tries to get the override setting in the override namespace
			local override_setting = override_namespace:GetSetting(id)
			-- checks if override value exists
			if override_setting then
				-- returns override value when it exists
				return override_setting:GetValue()
			end
		end

		-- gets the Namespace
		local namespace = client_overrides:GetChildAtPath(path)

		-- returns nil when namespace can't be found
		if not namespace then return end

		-- gets the setting
		local namespace = namespace:GetSetting(id)

		-- returns nil when the Setting isn't found
		if not setting then return end

		-- returns the Setting's value
		return setting:GetValue()
	end

	-- adds the given callback to the client setting with the given id at the given path
	-- the callback will only be called when no override for the setting exists or when the override's value changes
	function AddSettingCallback(path, id, callback)
		-- adds a callback to the Setting
		AddExternalCallback(PathToID(client_settings, path, id), function(setting)
			callback(setting:GetValue())
		end)
	end

	-- creates/replaces a server setting
	local function AddServerSetting(path, id, type, value)
		-- get id for callbacks
		path_id = PathToID(server_settings, path, id)

		-- create Setting
		local setting = Setting:Create(id, type, nil, value)

		-- add Setting to client_settings
		server_settings:AddChildrenAlongPath(path):AddSetting(setting)

		-- call special callbacks whenever it's changed and no override exists
		setting:AddCallback(function(setting)
			CallExternalCallbacks(path_id, setting)
		end)
	end

	-- returns the value of the server setting with the given id at the given path
	-- returns nil when no setting with the given id exists in the given path
	function GetServerSetting(path, id)
		-- tries to get the Namespace at path
		local namespace = server_settings:GetChildAtPath(path)

		-- returns nil when the Namespace isn't found
		if not namespace then return end

		-- tries to get the Setting
		local setting = namespace:GetSetting(id)

		-- returns nil when the Setting isn't found
		if not setting then return end

		-- returns the Setting's value
		return setting:GetValue()
	end

	-- adds the given callback to the server setting with the given id at the given path
	function AddServerSettingCallback(path, id, callback)
		-- adds a callback to the Setting
		AddExternalCallback(server_settings, path, id, function(setting)
			callback(setting:GetValue())
		end)
	end

	-- creates/replaces a client override
	local function AddClientOverride(path, id, type_id, value)
		-- gets the namespace of the setting this will override
		local namespace = client_settings:GetChildAtPath(path)

		-- returns nil when the namespace doesn't exist
		if not namespace then return end

		-- gets the setting this will override
		local real_setting = namespace:GetSetting(id)

		-- returns nil when the setting doesn't exist
		if not real_setting then return end

		-- returns nil when the value doesn't fit the setting this will override
		if real_setting:GetValidator() and not real_setting:GetValidator()(value) then return end

		-- get id for callbacks
		path_id = PathToID(client_settings, path, id)

		-- create Setting
		local setting = Setting:Create(id, real_setting:GetType(), real_setting:GetValidator(), value)

		-- add Setting to client_settings
		client_overrides:AddChildrenAlongPath(path):AddSetting(setting)

		-- call special callbacks whenever it's changed and no override exists
		setting:AddCallback(function(setting)
			CallExternalCallbacks(path_id, setting)
		end)

		CallExternalCallbacks(path_id, setting)
	end

	-- requests to change a server setting
	function RequestChange(path, id, value)
		net.Start("PAMCON_ChangeSetting")
		net.WriteBool(false)
		net.WriteString(Serialize(path))
		net.WriteString(id)
		net.WriteString(Serialize(value))
		net.SendToServer()
	end

	-- requests to add or change a client override
	function RequestOverride(path, id, value)
		net.Start("PAMCON_ChangeSetting")
		net.WriteBool(true)
		net.WriteString(Serialize(path))
		net.WriteString(id)
		net.WriteString(Serialize(value))
		net.SendToServer()
	end

	net.Receive("PAMCON_ChangeSetting", function(len)
		local is_override = net.ReadBool()
		local root = is_override and client_overrides or server_settings
		local path = Deserialize(net.ReadString())
		local id = net.ReadString()
		local type_id = net.ReadString()
		local value = Deserialize(net.ReadString())

		local namespace = root:AddChildrenAlongPath(path)

		local setting = namespace:GetSetting(id)

		if setting then
			setting:SetValue(value)
		elseif is_override then
			AddClientOverride(path, id, type_id, value)
		else
			AddServerSetting(path, id, type_id, value)
		end
	end)

	-- reads a Namespace from a received netmessage and calles add_func for all transmitted Settings
	local function ReceiveSettings(add_func, path)
		if path then
			path[#path + 1] = net.ReadString()
		else
			net.ReadString()
			path = {}
		end

		local child_count = net.ReadUInt(32)

		for i = 1, child_count do
			ReceiveSettings(add_func, path)
		end

		local setting_count = net.ReadUInt(32)

		for i = 1, setting_count do
			local id = net.ReadString()
			local type_id = net.ReadString()
			local value = Deserialize(net.ReadString())
			add_func(path, id, type, value)
		end

		path[#path] = nil
	end

	net.Receive("PAMCON_RequestServerSettings", function(len)
		ReceiveSettings(AddServerSetting, nil)
		ReceiveSettings(AddClientOverride, nil)
	end)

	hook.Add("InitPostEntity", "pamcon_request_server_settings", function()
		net.Start("PAMCON_RequestServerSettings")
		net.SendToServer()
	end)
end
