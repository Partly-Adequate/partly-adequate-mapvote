module("pamcon", package.seeall)
pamcon = {}

-- converts the arguments to a string
local function GetStorageID(root, path, id)
	-- TODO
	return "whateverthisis"
end

-- returns a stored value
local function GetStoredValue(storage_id)
	-- TODO
	return nil
end

-- stores a value
local function StoreValue(storage_id, value)
	-- TODO
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

-- adds the child Namespace
function Namespace:AddChild(child)
	-- calculate index
	local index = #self.children + 1

	-- add child Namespace
	self.children[index] = child
	self.children_indices[child:GetID()] = index
end

-- adds the Setting
-- it creates Namespaces if necessary
function Namespace:AddSetting(setting)
	-- calculate index
	local index = #self.settings + 1

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
function Setting:Create(id, value)
	-- create new Setting
	local setting = {}
	setmetatable(setting, Setting)

	-- set attributes
	setting.id = id
	setting.value = value
	setting.callbacks = {}

	-- return setting
	return setting
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
	-- update value
	self.value = new_value
	-- call callbacks
	for i = 1, #self.callbacks do
		callbacks[i](new_value)
	end
end

if SERVER then
	-- root namespace for all server settings
	server_settings = Namespace:Create("server_settings")
	-- root namespace for all client overriding Setting
	client_overrides = Namespace:Create("client_overrides")

	-- creates a new Setting and adds it to the server's settings
	function AddSetting(path, id, value)
		-- get id for storage
		storage_id = GetStorageID(client_settings, path, id)

		-- get stored value if possible
		value = GetStoredValue(storage_id) or value

		-- create Setting
		local setting = Setting:Create(id, value)

		-- add Setting to server_settings
		server_settings:AddChildrenAlongPath(path):AddSetting(setting)

		-- store value whenever it's changed
		setting:AddCallback(function(new_value)
			StoreValue(storage_id, new_value)
		end)
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
		-- gets Namespace
		local namespace = server_settings:GetChildAtPath(path)

		-- returns nil when the Namespace isn't found
		if not namespace then return end

		-- gets the Setting
		local setting = namespace:GetSetting(id)

		-- returns nil when the Setting isn't found
		if not setting then return end

		-- adds a callback to the Setting
		setting:AddCallback(callback)
	end
else
	-- root namespace for all client settings
	client_settings = Namespace:Create("client_settings")
	-- root namespace for a copy of all server settings
	server_settings = Namespace:Create("server_settings")
	-- root namespace for a copy of all client overrides
	client_overrides = Namespace:Create("client_overrides")

	-- creates a new Setting and adds it to the client's settings
	function AddSetting(path, id, value)
		-- get id for storage
		storage_id = GetStorageID(client_settings, path, id)

		-- get stored value if possible
		value = GetStoredValue(storage_id) or value

		-- create Setting
		local setting = Setting:Create(id, value)

		-- add Setting to client_settings
		client_settings:AddChildrenAlongPath(path):AddSetting(setting)

		-- store value whenever it's changed
		setting:AddCallback(function(new_value)
			StoreValue(storage_id, new_value)
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
		-- tries to get the Namespace at path
		local namespace = client_settings:GetChildAtPath(path)

		-- returns nil when the Namespace isn't found
		if not namespace then return end

		-- tries to get the Setting
		local setting = namespace:GetSetting(id)

		-- returns nil when the Setting isn't found
		if not setting then return end

		-- TODO overridable callbacks
		-- Callbacks should only be called when no override exists
		-- overrides should be able to call these callbacks

		-- adds a callback to the Setting
		setting:AddCallback(callback)
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
		-- tries to get the Namespace at path
		local namespace = server_settings:GetChildAtPath(path)

		-- returns nil when the Namespace isn't found
		if not namespace then return end

		-- tries to get the Setting
		local setting = namespace:GetSetting(id)

		-- returns nil when the Setting isn't found
		if not setting then return end

		-- returns the Setting's value
		setting:AddCallback(callback)
	end
end
