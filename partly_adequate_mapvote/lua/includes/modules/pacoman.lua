---
-- This is the pacoman module
-- @author Reispfannenfresser
-- @module pacoman
module("pacoman", package.seeall)
pacoman = {}

-- @TypeText string string that's used to separate namespaces when a path is turned into a string
local namespace_separator = "/"
-- @TypeText string string that's used to separate settings when a path is turned into a string
local setting_separator = "."

local callback_lists = {}

---
-- Adds a callback to the specified call_id
-- @param string call_id the id to call this callback with
-- @param string id the id to identify/remove this callback with at a later point
-- @callback function callback the function to call
-- @local
-- @note this won't allow registering two callbacks with the same call_id and id.
local function AddCallback(call_id, id, callback)
	if not callback_lists[call_id] then
		callback_lists[call_id] = {
			callbacks = {},
			ids = {},
			indices = {}
		}
	end

	local callback_list = callback_lists[call_id]
	if callback_list.indices[id] then return end

	local index = #callback_list.callbacks + 1

	callback_list.callbacks[index] = callback
	callback_list.ids[index] = id
	callback_list.indices[id] = index
end

---
-- Removes all callbacks at the specified call_id
-- @param string call_id the id to remove all callbacks from
-- @local
local function RemoveCallbacks(call_id)
	callback_lists[call_id] = nil
end

---
-- Removes a callback from the callbacks at the specified call_id
-- @param string call_id the id that is used to call the callback with
-- @param string id the identifier of the callback that will be deleted
-- @local
local function RemoveCallback(call_id, id)
	local callback_list = callback_lists[call_id]
	if not callback_list then return end

	local callbacks = callback_list.callbacks
	local callback_ids = callback_list.ids
	local callback_indices = callback_list.indices

	local index = callback_indices[id]
	local last_index = #callbacks

	if index == last_index then
		callback_ids[index] = nil
		callback_indices[id] = nil
		callbacks[id] = nil
		return
	end

	local last_id = callback_ids[last_index]

	callbacks[index] = callbacks[last_index]
	callback_ids[index] = callback_ids[last_index]
	callback_indices[last_id] = index

	callbacks[last_index] = nil
	callback_ids[last_index] = nil
	callback_indices[id] = nil
end

---
-- Calls all callbacks at the specified call_id
-- @param string call_id the id that is used to call the callback with
-- @local
local function CallCallbacks(call_id, value)
	local callback_list = callback_lists[call_id]
	if not callback_list then return end

	local callbacks = callback_list.callbacks

	for i = 1, #callbacks do
		callbacks[i](value)
	end
end

---
-- For every namespace-/setting_separator it inserts another one at the same position
-- @param string str the string to prepare
-- @note this is used for making sure the paths for storing settings are all unique
-- @local
local function PrepareString(str)
	local tmp = string.Replace(str, namespace_separator, namespace_separator .. namespace_separator)
	return string.Replace(tmp, setting_separator, setting_separator .. setting_separator)
end

-- TODO documentation for Type class
local Type = {}
Type.__index = Type

---
-- creates a new <code>Type</code>
-- @param string id the new <code>Type</code>'s id
-- @param[opt] function is_value_valid a function that can be used to determine if a value is of the new <code>Type</code>
-- @param[opt] function compare_values a function that can be used to compare two values of the new <code>Type</code> (a <= b)
-- @return Type the new type
-- @realm shared
function Type:Create(id, is_value_valid, serialize, deserialize, compare_values)
	new_type = {}
	setmetatable(new_type, self)

	new_type.id = id
	new_type.serialize = serialize
	new_type.deserialize = deserialize
	new_type.is_value_valid = is_value_valid
	new_type.compare_values = compare_values

	return new_type
end

---
-- @return string this <code>Type</code>'s id
-- @realm shared
function Type:GetID()
	return self.id
end

---
-- checks if a value is of this <code>Type</code>
-- @param any value the value to check
-- @return bool true if the value has this <code>Type</code>
-- @realm shared
function Type:IsValueValid(value)
	return not self.is_value_valid or self.is_value_valid(value)
end

---
-- @return bool true if this <code>Type</code> is comparable, false if it's not
-- @realm shared
function Type:IsComparable()
	if self.compare_values then
		return true
	end

	return false
end

---
-- serializes a value of this Type
-- @param any value the value to serialize
-- @return string|nil the serialized value or nil when the value is invalid
function Type:Serialize(value)
	if not self:IsValueValid(value) then return end

	return self.serialize(value)
end

---
-- deserializes a string that was serialized using this Type's Serialize function
-- @param string srt the string to deserialize
-- @return any|nil the deserialized value or nil when the value is invalid
function Type:Deserialize(str)
	local value = self.deserialize(str)
	if not self:IsValueValid(value) then return end

	return value
end

---
-- compares two values of this Type
-- @param any value_1 the first value
-- @param any value_2 the second value
-- @return bool value_1 <= value_2 or nil when this Type is not comparable
-- @realm shared
function Type:CompareValues(value_1, value_2)
	if not self:IsComparable() then return end

	return self.compare_values(value_1, value_2)
end

local types = {}

---
-- creates and registers a new Type
-- @param string id the new Type's id
-- @param[opt] function is_value_valid a function that can be used to determine if a value is of the new Type
-- @param[opt] function compare_values a function that can be used to compare two values of the new Type (a <= b)
-- @note won't do anything when a type with the id already exists
-- @realm shared
function RegisterType(id, is_value_valid, serialize, deserialize, compare_values)
	if types[id] then return end
	local type = Type:Create(id, is_value_valid, serialize, deserialize, compare_values)

	types[id] = type
	return type
end

local function GetType(id)
	return types[id]
end

---
-- checks if a value is an Integer
-- @param any value the value to check
-- @return bool
-- @local
local function IsInteger(value)
	return value and type(value) == "number" and math.floor(value) == value
end

---
-- checks if a value is a number that's greater or equal to 0 and less or equal to 100
-- @param any value the value to check
-- @return bool
-- @local
local function IsPercentage(value)
	return value and type(value) == "number" and value >= 0 and value <= 100
end

---
-- checks if the first value is smaller than or equal to the second value
-- @param number value_1 the first value
-- @param number value_2 the second value
-- @return bool
-- @local
local function CompareNumber(value_1, value_2)
	return value_1 <= value_2
end

---
-- serializes anything
-- @param any the value to serialize
-- @return string the serialized value
-- @note uses JSONToTable internally and contains all it's bugs
local function SerializeAny(value)
	local serializable = {}
	serializable.value = value
	return util.TableToJSON(serializable)
end

---
-- deserializes strings which were serialized using SerializeAny
-- @param string the value to deserialize
-- @return any the deserialized value
-- @note uses TableToJSON internally and contains all it's bugs
local function DeserializeAny(str)
	local deserialized = util.JSONToTable(str)
	return deserialized and deserialized.value
end

-- @TypeText Type describes all types of values
TYPE_ANY = RegisterType("any", nil, SerializeAny, DeserializeAny)
-- @TypeText Type describes strings
TYPE_STRING = RegisterType("string", isstring, tostring, tostring)
-- @TypeText Type describes booleans
TYPE_BOOLEAN = RegisterType("boolean", isbool, tostring, tobool)
-- @TypeText Type describes numbers
TYPE_NUMBER = RegisterType("number", isnumber, tostring, tonumber, CompareNumber)
-- @TypeText Type describes percentages (numbers in interval [0;1])
TYPE_PERCENTAGE = RegisterType("percentage", IsPercentage, tostring, tonumber, CompareNumber)
-- @TypeText Type describes integers
TYPE_INTEGER = RegisterType("integer", IsInteger, tostring, tonumber, CompareNumber)

-- TODO documentation for Game_Property class
local Game_Property = {}
Game_Property.__index = Game_Property

---
-- Creates a new Game_Property
-- @param string id the name/identifier of this Game_Property
-- @param Type type the Type of this Game_Property's value
-- @param any value the current value of this Game_Property
-- @return the new Game_Property
function Game_Property:Create(id, type, value)
	if not type:IsValueValid(value) then return end

	local game_property = {}
	setmetatable(game_property, self)

	game_property.id = id
	game_property.type = type
	game_property.value = value
	game_property.callbacks = {}
	game_property.callback_indices = {}
	game_property.callback_ids = {}

	return game_property
end

---
-- Updates the value of this Game_Property
-- @param any new_value the new value of this Game_Property
-- @note new_value has to be valid in regards to the Type of this Game_Property
-- @note this will call all callbacks that were added previously
function Game_Property:SetValue(new_value)
	if not self.type:IsValueValid(new_value) then return end

	self.value = new_value

	for i = 1, #self.callbacks do
		self.callbacks[i]()
	end
end

---
-- Adds a callback to this Game_Property. All callbacks will be called whenever the value of this Game_Property changes
-- @param function callback_func the function
-- @return number an identifier which can be used to remove the callback
function Game_Property:AddCallback(callback_id, callback)
	if self.callback_indices[callback_id] then return end

	local index = #self.callbacks + 1

	self.callbacks[index] = callback

	self.callback_ids[index] = callback_id
	self.callback_indices[callback_id] = index
end

---
-- Removes the callback with the provided id
-- @param string callback_id the id of the callback to remove
function Game_Property:RemoveCallback(callback_id)
	local index = self.callback_indices[callback_id]
	if not index then return end

	local last_index = #self.callbacks

	if index == last_index then
		self.callbacks[index] = nil
		self.callback_ids[index] = nil
		self.callback_indices[callback_id] = nil
		return
	end

	local last_id = callback_ids[last_index]

	self.callbacks[index] = self.callbacks[last_index]
	self.callback_ids[index] = last_id
	self.callback_indices[callback_id] = nil

	self.callbacks[last_index] = nil
	self.callback_ids[last_index] = nil
	self.callback_indices[last_id] = index
end

game_properties = {}
game_property_indices = {}

---
-- Creates a new GameProperty and registers it internally.
-- @param string id identifier/name of the Game_Property
-- @param string type_id identifier of the Type of the Game_Property
-- @param any value the current value of the Game_Property
-- @note value has to be valid in regards to the specified Type
-- @realm shared
function RegisterGameProperty(id, type_id, value)
	if game_property_indices[id] then return end

	local type = GetType(type_id)
	if not type then return end

	local game_property = Game_Property:Create(id, type, value)

	if not game_property then return end

	local index = #game_properties + 1

	game_properties[index] = game_property
	game_property_indices[id] = index
end

---
-- @param string id the identifier/name of the Game_Property
-- @return table the Game_Property that was registered under the specified name
-- @realm shared
function GetGameProperty(id)
	local index = game_property_indices[id]

	if not index then return end

	return game_properties[index]
end

-- caches all settings (full_id -> setting)
local all_settings = {}
-- caches all namespaces (full_id -> namespace)
local all_namespaces = {}

-- TODO documentation for Setting class
local Setting = {}
Setting.__index = Setting

---
-- Creates a new Setting
-- @param string the full_id of the namespace this Setting is a part of
-- @param string id the name/identifier of this Setting
-- @param Type type the Type of this Setting's value
-- @param any value the value of this Setting
-- @return the new Setting
-- @note if the value doesn't fit the Type it will return nil
function Setting:Create(path_id, id, type, value)
	if not type:IsValueValid(value) then return end

	local setting = {}
	setmetatable(setting, self)

	local full_id = path_id .. setting_separator .. PrepareString(id)

	setting.id = id
	setting.full_id = full_id
	setting.type = type
	setting.value = value
	setting.active_value = value
	setting.active_source_id = nil
	setting.sources = {}
	setting.source_indices = {}
	setting.depends_on = nil
	setting.parent = nil

	all_settings[full_id] = setting

	return setting
end

function Setting:AddCallback(id, callback)
	AddCallback(self.full_id, id, callback)
end

function Setting:RemoveCallback(id)
	RemoveCallback(self.full_id, id)
end

function Setting:CallCallbacks()
	CallCallbacks(self.full_id, self.active_value)
end

---
-- Notifies this Setting and it's sources about it's removal
function Setting:Remove()
	RemoveCallbacks(self.full_id)
	self:MakeIndependent()
	all_settings[self.full_id] = nil
end

---
-- changes the value of this Setting and calls Setting:OnActiveValueChanged if necessary
-- @param any new_value the new value
-- @note will not do anything when the new value doesn't fit this Setting's type
function Setting:SetValue(new_value)
	if not self.type:IsValueValid(new_value) then return end

	self.value = new_value

	self:OnValueChanged()

	-- if this setting has a source setting that overrides the active value it should not change it's active value
	if self.active_source_id then return end

	self:SetActiveValue(new_value)
end

---
-- changes the currently active setting to the source setting with the given id
-- @param string setting_id the id of the setting to set as active
function Setting:SetActiveSourceID(setting_id)
	local source_index = self.source_indices[setting_id]

	-- if no source is found with that id it should use the default value
	if not source_index then
		self.active_source_id = nil
		self:SetActiveValue(self.value)
		return
	end

	self.active_source_id = setting_id
	self:SetActiveValue(self.sources[source_index].active_value)
end

---
-- changes the currently active value of this Setting and calls OnActiveValueChanged
-- @param any new_value the new active value
-- @note won't do anything when the provided value doesn't fit the Type of this Setting
function Setting:SetActiveValue(new_value)
	if not self.type:IsValueValid(new_value) then return end

	self.active_value = new_value

	self:OnActiveValueChanged()

	-- update the parent setting when this setting is a source and currently active
	if not self.parent or not parent.active_source_id == self.id then return end

	parent:SetActiveValue(new_value)
	self.CallCallbacks()
end

---
-- returns this Setting's currently active value
-- override this function to customise the value this setting returns
-- @hook
function Setting:GetActiveValue()
	return self.active_value
end

---
-- @return bool true when this Setting depends on a Game_Property, false otherwise
function Setting:IsDependent()
	return self.depends_on ~= nil
end

---
-- makes this Setting depend on a Game_Property
-- @param Game_Property game_property the property to depend on
-- @note In case this Setting already depends on a Game_Property it will remove the old dependency first.
function Setting:MakeDependent(game_property)
	if self:IsDependent() then
		self:MakeIndependent()
	end

	self.depends_on = game_property

	game_property:AddCallback(self.full_id, function()
		self:Update()
	end)
end

---
-- removes this Setting's dependence on a Game_Property
function Setting:MakeIndependent()
	if not self:IsDependent() then return end

	-- update active value to default
	self:SetActiveSourceID(nil)

	-- inform the sources about their imminent removal
	for i = 1, #self.sources do
		self.sources[i]:Remove()
	end

	-- remove game property callback
	self.depends_on:RemoveCallback(self.full_id)
	self.depends_on = nil

	-- remove sources
	self.sources = {}
	self.source_indices = {}
end

---
-- Adds a new Setting to this Setting's sources
-- The new Setting will inherit this Setting's hooks
-- @param string id the id of the new source Setting
-- @param any value the value of the new source Setting
function Setting:AddSource(id, value)
	-- return when this setting doesn't depend on a game property
	local game_property = self.depends_on
	if not game_property then return end

	local gp_type = game_property.type
	local type = self.type

	-- return when the value isn't valid or when the id can't be deserialised by the game properties type
	if not type:IsValueValid(value) or not gp_type:Deserialize(id) then return end

	-- add new source
	local index = #self.sources + 1

	local source_setting = Setting:Create(self.full_id, id, type, value)
	source_setting.parent = self

	self.sources[index] = source_setting
	self.source_indices[source_setting.id] = index

	self:OnSourceAdded(source_setting)

	-- check if the new setting should be the active setting
	self:Update()

	return source_setting
end

---
-- Removes a Setting from this Setting's sources
-- @param string id the id of the source Setting that will be removed
function Setting:RemoveSource(source_id)
	-- return when the source doesn't exist
	local index = self.source_indices[source_id]
	if not index then return end

	local source_setting = sources[index]

	-- inform source about imminent removal
	source_setting:Remove()

	-- simple removal for when it was the last source
	if index == #self.sources then
		self.sources[index] = nil
		self.source_indices[source_id] = nil
		return
	end

	-- remove source and reorder source list to remove potential gaps
	local last_index = #self.sources
	local last_setting = self.sources[last_index]

	self.sources[index] = last_setting
	source_indices[source_id] = nil

	self.sources[last_index] = nil
	source_indices[last_setting.id] = index

	-- call OnSourceRemoved hook
	self.OnSourceRemoved(source_setting)

	-- update this setting when the active source got removed
	if source_id != self.active_source_id then return end

	self:Update()
end

---
-- Determines this Setting's active source and updates this Setting's active value
function Setting:Update()
	-- return when this setting is independent
	local game_property = self.depends_on
	if not game_property then return end

	local gp_value = game_property.value
	local gp_type = game_property.type

	-- when the game property's type is not comparable it picks the source that fits precisely
	if not gp_type:IsComparable() then
		self:SetActiveSourceID(gp_type:Serialize(gp_value))
		return
	end

	-- search for the best fitting source by iterating over all sources
	local sources = self.sources
	local best_id = nil
	local comparable_best_id = nil

	for i = 1, #sources do
		local current = sources[i]
		local current_id = current.id
		local comparable_id = gp_type:Deserialize(current_id)
		if gp_type:CompareValues(comparable_id, gp_value) and (not comparable_best_id or gp_type:CompareValues(comparable_id, comparable_best_id)) then
			best = current_id
			comparable_best = comparable_id
		end
	end

	self:SetActiveSourceID(best)
end

---
-- Will be called whenever this Setting's value changes
-- @hook
function Setting:OnValueChanged()

end

---
-- Will be called whenever a source is added to this Setting's sources
-- @param Setting source_setting the added source
-- @hook
function Setting.OnSourceAdded(source_setting)

end

---
-- Will be called when a source from this Setting is removed
-- @hook
function Setting.OnSourceRemoved(source_setting)

end

-- TODO documentation for Namespace class
local Namespace = {}
Namespace.__index = Namespace

---
-- creates a new Namespace
-- @param string path_id the full id of the parent namespace
-- @param string id the name/identifier for this namespace
-- @return Namespace the new Namespace
function Namespace:Create(path_id, id)
	local namespace = {}
	setmetatable(namespace, self)

	local full_id = id and path_id .. namespace_separator .. PrepareString(id) or PrepareString(path_id)

	namespace.id = id or path_id
	namespace.full_id = full_id
	namespace.children = {}
	namespace.children_indices = {}
	namespace.settings = {}
	namespace.setting_indices = {}

	all_namespaces[full_id] = namespace

	return namespace
end

---
-- Adds a child Namespace to this Namespace
-- @param Namespace child the Namespace to adopt
-- @note If a child with the same name already exists within this Namespace's children, it won't be adopted.
function Namespace:AddChild(child_id)
	local child = self:GetChild(child_id)
	if child then return child end

	local index = #self.children + 1

	local namespace = Namespace:Create(self.full_id, child_id)
	namespace.OnSettingAdded = self.OnSettingAdded
	namespace.OnSettingRemoved = self.OnSettingRemoved
	namespace.OnChildAdded = self.OnChildAdded

	self.children[index] = namespace
	self.children_indices[child_id] = index

	return namespace
end

---
-- Gets a child Namespace from this Namespace
-- @param string id The name/identifier of the child
-- @return Namespace the child
-- @note will return nil when no child with that name is found
function Namespace:GetChild(child_id)
	local index = self.children_indices[child_id]
	if not index then return end

	return self.children[index]
end

---
-- @return table All Child Namespaces this Namespace has
function Namespace:GetChildren()
	return self.children
end

---
-- Adds a Setting to this Namespace's Settings
-- @param string setting_id the id of the setting to add
-- @param Type type the type of the setting
-- @param any value the value of the setting
-- @note If a Setting with the same name/identifier already exists within this Namespace's Settings, it will be overriden.
function Namespace:AddSetting(setting_id, type, value)
	self:RemoveSetting(setting_id)

	local index = #self.settings + 1

	local setting = Setting:Create(self.full_id, setting_id, type, value)

	if not setting then return end

	self.settings[index] = setting
	self.setting_indices[setting_id] = index

	setting.OnSourceAdded = self.OnSettingAdded
	setting.OnSourceRemoved = self.OnSettingRemoved

	return setting
end

---
-- Gets a Setting from this Namespace's Settings
-- @param string setting_id The name/identifier of the Setting
-- @return Setting the setting with the correct name/identifier
-- @note will return nil when no Setting with that name/identifier is found
function Namespace:GetSetting(setting_id)
	local index = self.setting_indices[setting_id]
	if not index then return end

	return self.settings[index]
end

---
-- Removes a Setting from this Namespace
-- @param string setting_id the name/identifier of the Setting that will be removed
function Namespace:RemoveSetting(setting_id)
	local index = self.setting_indices[setting_id]
	if not index then return end

	local setting = self.settings[index]
	setting:Remove()

	-- simple removal for when it was the last setting
	if index == #self.settings then
		self.settings[index] = nil
		self.setting_indices[setting_id] = nil
		return
	end

	-- remove setting and reorder setting list to remove potential gaps
	local last_index = #self.settings
	local last_setting = self.settings[last_index]

	self.settings[index] = last_setting
	self.setting_indices[setting_id] = nil

	self.settings[last_index] = nil
	self.setting_indices[last_setting.id] = index

	-- call OnSettingRemoved hook
	self.OnSettingRemoved(setting)
end

---
-- @return table this Namespace's Settings
function Namespace:GetSettings()
	return self.settings
end

---
-- will be called whenever a Child Namespace is created in this namespace
-- this function will also be passed to any children that are added to this namespace
-- @param Setting setting the setting that will be added
-- @hook
function Namespace:OnChildAdded(child_namespace)

end

---
-- will be called whenever a Setting is added to this namespace
-- this function will also be passed to any children that are added to this namespace
-- @param Setting setting the setting that will be added
-- @hook
function Namespace:OnSettingAdded(setting)

end

---
-- will be called whenever a Setting is removed from this namespace
-- this function will also be passed to any children that are added to this namespace
-- @param Setting setting the setting that was be removed
-- @hook
function Namespace:OnSettingRemoved(setting)

end

if SERVER then
	local server_settings_id = "server_settings"
	local client_overrides_id = "client_overrides"

	-- root namespace for all server settings
	server_settings = Namespace:Create(server_settings_id, nil)
	-- root namespace for all client overrides
	client_overrides = Namespace:Create(client_overrides_id, nil)

	local function OnServerSettingAdded(self, setting)
		-- TODO load value from database

		setting.OnValueChanged = function(self)
			-- TODO save value in database
			BroadcastValueChange(self)
		end

		-- TODO save value in database when it wasn't loaded
	end

	local function OnServerSettingRemoved(self, setting)
		-- TODO delete Setting from database
		BroadcastSettingRemoval(self)
	end

	local function OnChildAdded(self, child_namespace)
		BroadcastNamespaceCreation(self, child_namespace)
	end

	server_settings.OnSettingAdded = OnServerSettingAdded
	server_settings.OnSettingRemoved = OnServerSettingRemoved
	server_settings.OnChildAdded = OnChildAdded

	local function OnClientOverrideAdded(self, setting)
		setting.OnValueChanged = function(self)
			-- TODO save setting in database
			BroadcastValueChange(self)
		end

		-- TODO save setting in database when it wasn't loaded
		BroadcastSettingCreation(self, setting)
	end

	local function OnClientOverrideRemoved(self, setting)
		-- TODO delete Setting from database
		BroadcastSettingRemoval(self, setting)
	end

	client_overrides.OnSettingAdded = OnClientOverrideAdded
	client_overrides.OnSettingRemoved = OnClientOverrideRemoved
	client_overrides.OnChildAdded = OnChildAdded

	-- networking
	util.AddNetworkString("PACOMAN_GamePropertyChanged")
	util.AddNetworkString("PACOMAN_ValueChanged")
	util.AddNetworkString("PACOMAN_SettingRemoved")
	util.AddNetworkString("PACOMAN_NamespaceCreated")
	util.AddNetworkString("PACOMAN_SettingCreated")
	util.AddNetworkString("PACOMAN_SettingDependencyChanged")
	util.AddNetworkString("PACOMAN_RequestFullState")
	util.AddNetworkString("PACOMAN_SendFullState")

	local function BroadcastGamePropertyChange(game_property)
		net.Start("PACOMAN_GamePropertyChanged")
		net.WriteString(game_property.id)
		net.WriteString(game_property.type:Serialize(game_property.value))
		net.Broadcast()
	end

	local function BroadcastValueChange(setting)
		net.Start("PACOMAN_ValueChanged")
		net.WriteString(setting.full_id)
		net.WriteString(setting.type:Serialize(setting.value))
		net.Broadcast()
	end

	local function BroadcastSettingRemoval(parent, setting)
		net.Start("PACOMAN_SettingRemoved")
		net.WriteString(parent.full_id)
		net.WriteString(setting.id)
		net.Broadcast()
	end

	local function BroadcastNamespaceCreation(parent, child)
		net.Start("PACOMAN_NamespaceCreated")
		net.WriteString(parent.full_id)
		net.WriteString(child.id)
		net.Broadcast()
	end

	local function BroadcastSettingCreation(parent, setting)
		local type = setting.type
		net.Start("PACOMAN_SettingCreated")
		net.WriteString(parent.full_id)
		net.WriteString(setting.id)
		net.WriteString(type.id)
		net.WriteString(type:Serialize(setting.value))
		net.Broadcast()
	end

	local function BroadcastSettingDependencyChange(setting)
		local game_property = setting.depends_on
		net.Start("PACOMAN_SettingDependencyChanged")
		net.Write(setting.full_id)
		if game_property then
			net.Write(game_property.id)
		end
		net.Broadcast()
	end

	local function SendFullState(len, ply)
		error("not yet implemented")
	end
	net.Receive("PACOMAN_RequestFullState", SendFullState)
else
	local client_settings_id = "client_settings"
	local server_settings_id = "server_settings"
	local client_overrides_id = "client_overrides"

	-- stores which client settings are currently overriden
	local overrides = {}

	-- root namespace for all client settings
	client_settings = Namespace:Create(client_settings_id, nil)
	-- root namespace for a copy of all server settings
	server_settings = Namespace:Create(server_settings_id, nil)
	-- root namespace for a copy of all client overrides
	client_overrides = Namespace:Create(client_overrides_id, nil)

	local function OverrideIDToClientSettingID(override_id)
		return client_settings_id .. string.sub(override_id, #client_overrides_id + 1, -1)
	end

	local function ClientSettingIDToOverrideID(override_id)
		return client_overrides_id .. string.sub(override_id, #client_settings_id + 1, -1)
	end

	local function OnClientSettingAdded(self, setting)
		-- TODO load Setting from database

		setting.OnValueChanged = function(self)
			-- TODO save setting in database
		end

		setting.GetActiveValue = function(self)
			local full_id = self.full_id
			if not overrides[full_id] then
				return self.active_value
			end

			return all_settings[ClientSettingIDToOverrideID(full_id)]:GetActiveValue()
		end

		setting.CallCallbacks = function(self)
			-- only call callbacks when this setting isn't overriden
			local full_id = self.full_id
			if overrides[full_id] then return end

			CallCallbacks(full_id, self.active_value)
		end

		-- TODO save setting in database when it wasn't loaded before
	end

	local function OnClientSettingRemoved(self, setting)
		-- TODO delete Setting in database
	end

	client_settings.OnSettingAdded = OnClientSettingAdded
	client_settings.OnSettingRemoved = OnClientSettingRemoved

	local function OnClientOverrideAdded(self, setting)
		-- mark callback id as overriden
		local full_id = setting.full_id
		local setting_id = OverrideIDToClientSettingID(full_id)
		overrides[setting_id] = true

		setting.CallCallbacks = function(self)
			-- call callbacks for self
			local new_value = self.active_value
			CallCallbacks(full_id, new_value)

			-- call callbacks from original setting
			CallCallbacks(setting_id, new_value)
		end

		-- call callbacks for original setting
		CallCallbacks(setting_id, self.active_value)
	end

	local function OnClientOverrideRemoved(self, setting)
		local full_id = setting.full_id;
		local setting_id = OverrideIDToClientSettingID(full_id)

		overrides[setting_id] = nil

		-- call callbacks for original setting
		all_settings[setting_id]:CallCallbacks()
	end

	client_overrides.OnSettingAdded = OnClientOverrideAdded
	client_overrides.OnSettingRemoved = OnClientOverrideRemoved

	local function ReceiveGamePropertyChange(len)
		local game_property = GetGameProperty(net.ReadString())
		if not game_property then return end

		game_property:SetValue(game_property.type:Deserialize(net.ReadString()))
	end
	net.Receive("PACOMAN_GamePropertyChanged", ReceiveGamePropertyChange)

	local function ReceiveValueChange(len)
		local setting = all_settings[net.ReadString()]
		if not setting then return end

		setting:SetValue(setting.type:Deserialize(net.ReadString))
	end
	net.Receive("PACOMAN_ValueChanged", ReceiveValueChange)

	local function ReceiveSettingRemoval(len)
		local full_parent_id = net.ReadString()
		local child_id = net.ReadString()
		local parent = all_namespaces[full_parent_id]
		if parent then
			parent:RemoveSetting(child_id)
			return
		end

		parent = all_settings[full_parent_id]
		if not parent then return end

		parent.RemoveSource(child_id)
	end
	net.Receive("PACOMAN_SettingRemoved", ReceiveSettingRemoval)

	local function ReceiveNamespaceCreation(len)
		local parent = all_namespaces[net.ReadString()]
		if not parent then return end
		parent:AddChild(net.ReadString())
	end
	net.Receive("PACOMAN_NamespaceCreated", ReceiveNamespaceCreation)

	local function ReceiveSettingCreation(len)
		local full_parent_id = net.ReadString()
		local id = net.ReadString()
		local type = GetType(net.ReadString())
		if not type then return end

		local value = type:Deserialize(net.ReadString())
		if not value then return end

		local parent = all_namespaces[full_parent_id]
		if parent then
			parent:AddSetting(id, type, value)
			return
		end

		parent = all_settings[full_parent_id]
		if not parent then return end

		parent:AddSource(id, value)
	end
	net.Receive("PACOMAN_SettingCreated", ReceiveSettingCreation)

	local function ReceiveSettingDependencyChange(len)
		local setting = all_settings[net.ReadString()]
		if not setting then return end

		setting:MakeIndependent()

		if len == 1 then return end

		local game_property = GetGameProperty(net.ReadString())
		if not game_property then return end

		setting:MakeDependent(game_property)
	end
	net.Receive("PACOMAN_SettingDependencyChanged", ReceiveSettingDependencyChange)

	local function ReceiveFullState(len)
		error("not yet implemented")
	end
	net.Receive("PACOMAN_SendFullState", ReceiveFullState)

	hook.Add("InitPostEntity", "PACOMAN_RequestState", function()
		net.Start("PACOMAN_RequestFullState")
		net.SendToServer()
	end)
end
