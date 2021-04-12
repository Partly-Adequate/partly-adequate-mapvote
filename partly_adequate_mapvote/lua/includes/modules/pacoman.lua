---
-- This is the <code>pacoman</code> module
-- @author Reispfannenfresser
-- @module pacoman
module("pacoman", package.seeall)
pacoman = {}

-- @TypeText string string that's used to separate namespaces when a path is turned into a string
local namespace_separator = "/"
-- @TypeText string string that's used to separate settings when a path is turned into a string
local setting_separator = "."

-- @TypeText string identifier for a pacoman <code>Type</code> that represents all types of values
P_TYPE_ANY = "any"
-- @TypeText string identifier for a pacoman <code>Type</code> that represents strings
P_TYPE_STRING = "string"
-- @TypeText string identifier for a pacoman <code>Type</code> that represents bools
P_TYPE_BOOLEAN = "bool"
-- @TypeText string identifier for a pacoman <code>Type</code> that represents numbers
P_TYPE_NUMBER = "number"
-- @TypeText string identifier for a pacoman <code>Type</code> that represents percentages
P_TYPE_PERCENTAGE = "percentage"
-- @TypeText string identifier for a pacoman <code>Type</code> that represents integers
P_TYPE_INTEGER = "integer"

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

local function SaveSettingToDatabase(setting)
	print("[NYI] Settings can't be saved")
end

local function LoadSettingFromDatabase(setting)
	print("[NYI] Settings can't be loaded")
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
-- serializes a value of this <code>Type</code>
-- @param any value the value to serialize
-- @return string|nil the serialized value or nil when the value is invalid
function Type:Serialize(value)
	if not self:IsValueValid(value) then return end

	return self.serialize(value)
end

---
-- deserializes a string that was serialized using this <code>Type</code>'s Serialize function
-- @param string srt the string to deserialize
-- @return any|nil the deserialized value or nil when the value is invalid
function Type:Deserialize(str)
	local value = self.deserialize(str)
	if not self:IsValueValid(value) then return end

	return value
end

---
-- compares two values of this <code>Type</code>
-- @param any value_1 the first value
-- @param any value_2 the second value
-- @return bool value_1 <= value_2 or nil when this <code>Type</code> is not comparable
-- @realm shared
function Type:CompareValues(value_1, value_2)
	if not self:IsComparable() then return end

	return self.compare_values(value_1, value_2)
end

local types = {}

---
-- creates and registers a new Type
-- @param string id the new <code>Type</code>'s id
-- @param[opt] function is_value_valid a function that can be used to determine if a value is of the new <code>Type</code>
-- @param[opt] function compare_values a function that can be used to compare two values of the new <code>Type</code> (a <= b)
-- @note won't do anything when a type with the id already exists
-- @realm shared
function RegisterType(id, is_value_valid, serialize, deserialize, compare_values)
	if types[id] then return end
	types[id] = Type:Create(id, is_value_valid, serialize, deserialize, compare_values)
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

RegisterType(P_TYPE_ANY, nil, SerializeAny, DeserializeAny)
RegisterType(P_TYPE_STRING, isstring, tostring, tostring)
RegisterType(P_TYPE_BOOLEAN, isbool, tostring, tobool)
RegisterType(P_TYPE_NUMBER, isnumber, tostring, tonumber, CompareNumber)
RegisterType(P_TYPE_PERCENTAGE, IsPercentage, tostring, tonumber, CompareNumber)
RegisterType(P_TYPE_INTEGER, IsInteger, tostring, tonumber, CompareNumber)

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
-- @return string the name/identifier of this Game_Property
function Game_Property:GetID()
	return self.id
end

---
-- @return Type the Type of this Game_Property
function Game_Property:GetType()
	return self.type
end

---
-- @return the current value of this Game_Property
function Game_Property:GetValue()
	return self.value
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
-- @local
-- @realm shared
local function GetGameProperty(id)
	local index = game_property_indices[id]

	if not index then return end

	return game_properties[index]
end

---
-- Changes the value of a Game_Property
-- @param string id the identifier/name of the Game_Property
-- @param any value the new value of the Game_Property
-- @note the new value has to be valid in regards to the Type of the Game_Property
-- @realm shared
function UpdateGameProperty(id, value)
	local game_property = GetGameProperty(id)
	if not game_property then return end

	if not game_property:GetType():IsValueValid(value) then return end

	game_property:SetValue(value)
end

-- cache for full_id -> setting
local all_settings = {}

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
	setting.sources = {}
	setting.source_indices = {}

	all_settings[full_id] = setting

	return setting
end

---
-- @return Type this Setting's Type
function Setting:GetType()
	return self.type
end

---
-- @return string this Setting's name/identifier
function Setting:GetID()
	return self.id
end

---
-- @return string this Setting's global identifier (unique for each setting)
function Setting:GetFullID()
	return self.full_id
end

---
-- @return any this Setting's value
function Setting:GetValue()
	return self.value
end

---
-- Will be called whenever this Setting's active value changes
-- @hook
function Setting:OnActiveValueChanged()

end

---
-- Will be called whenever this Setting's value changes
-- @hook
function Setting:OnValueChanged()

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
	if self.active_setting_id then return end

	self:SetActiveValue(new_value)
end

---
-- changes the currently active setting to the source setting with the given id
-- @param string setting_id the id of the setting to set as active
function Setting:SetActiveSettingID(setting_id)
	local source_index = self.source_indices[setting_id]

	-- if no source is found with that id it should use the default value
	if not source_index then
		self.active_setting_id = nil
		self:SetActiveValue(self.value)
		return
	end

	self.active_setting_id = setting_id
	self:SetActiveValue(self.sources[source_index]:GetActiveValue())
end

---
-- @return any the currently active value of this Setting (will be of this Setting's Type)
function Setting:GetActiveValue()
	return self.active_value
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
	if not self.parent or not parent.active_setting_id == self.id then return end

	parent:SetActiveValue(new_value)
end

---
-- @return bool true when this Setting depends on a Game_Property, false otherwise
function Setting:IsDependent()
	return self.depends_on and true or false
end

---
-- makes this Setting depend on a Game_Property
-- @param string game_property_id the id of the property to depend on
-- @note In case no game_property with that id is found it won't do anything.
-- @note In case this Setting already depends on a Game_Property it will remove the dependency first.
function Setting:MakeDependent(game_property_id)
	local game_property = GetGameProperty(game_property_id)

	if not game_property then return end

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
	self:SetActiveSettingID(nil)

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

	local gp_type = game_property:GetType()
	local type = self.type

	-- return when the value isn't valid or when the id can't be deserialised by the game properties type
	if not type:IsValueValid(value) or not gp_type:Deserialize(id) then return end

	-- add new source
	local index = #self.sources + 1

	local source_setting = Setting:Create(self.full_id, id, type, value)
	source_setting.parent = self

	self.sources[index] = source_setting
	self.source_indices[source_setting:GetID()] = index

	self:OnSourceAdded(source_setting)

	-- check if the new setting should be the active setting
	self:Update()
end

---
-- Will be called whenever a source is added to this Setting's sources
-- @param Setting source_setting the added source
-- @hook
function Setting:OnSourceAdded(source_setting)

end

---
-- Notifies this Setting and it's sources about it's removal
function Setting:Remove()
	self:MakeIndependent()
	self:OnRemoved()
	all_settings[self.full_id] = nil
end

---
-- Will be called when this Setting is removed
-- @hook
function Setting:OnRemoved()

end

---
-- Removes a Setting from this Setting's sources
-- @param string id the id of the source Setting that will be removed
function Setting:RemoveSource(source_id)
	-- return when the source doesn't exist
	local index = self.source_indices[source_id]
	if not index then return end

	-- inform source about imminent removal
	self.sources[index]:Remove()

	-- remove source
	if index == #self.sources then
		self.sources[index] = nil
		self.source_indices[source_id] = nil
		return
	end

	local last_index = #self.sources
	local last_setting = self.sources[last_index]

	self.sources[index] = last_setting
	source_indices[source_id] = nil

	self.sources[last_index] = nil
	source_indices[last_setting:GetID()] = index

	-- update this setting when the active source got removed
	if source_id != self.active_setting_id then return end

	self:Update()
end

---
-- Determines this Setting's active source and updates this Setting's active value
function Setting:Update()
	-- return when this setting is independent
	local game_property = self.depends_on
	if not game_property then return end

	local gp_value = game_property:GetValue()
	local gp_type = game_property:GetType()

	-- when the game property's type is not comparable it picks the source that fits precisely
	if not gp_type:IsComparable() then
		self:SetActiveSettingID(gp_type:Serialize(gp_value))
		return
	end

	-- search for the best fitting source by iterating over all sources
	local sources = self.sources
	local best_id = nil
	local comparable_best_id = nil

	for i = 1, #sources do
		local current = sources[i]
		local current_id = current:GetID()
		local comparable_id = gp_type:Deserialize(current_id)
		if gp_type:CompareValues(comparable_id, gp_value) and (not comparable_best_id or gp_type:CompareValues(comparable_id, comparable_best_id)) then
			best = current_id
			comparable_best = comparable_id
		end
	end

	self:SetActiveSettingID(best)
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

	namespace.id = id
	namespace.full_id = path_id .. namespace_separator .. PrepareString(id)
	namespace.children = {}
	namespace.children_indices = {}
	namespace.settings = {}
	namespace.setting_indices = {}

	return namespace
end

---
-- @return the id of this Namespace
function Namespace:GetID()
	return self.id
end

---
-- Adds a child Namespace to this Namespace
-- @param Namespace child the Namespace to adopt
-- @note If a child with the same name already exists within this Namespace's children, it won't be adopted.
function Namespace:AddChild(child_id)
	if self:GetChild(child_id) then return end

	local index = #self.children + 1

	local namespace = Namespace:Create(self.full_id, child_id)

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
-- @param Setting setting the Setting to add
-- @note If a Setting with the same name/identifier already exists within this Namespace's Settings, it won't be added.
function Namespace:AddSetting(setting_id, type, value)
	if self:GetSetting(setting_id) then return end

	local index = #self.settings + 1

	local setting = Setting:Create(self.full_id, setting_id, type, value)

	self.settings[index] = setting
	self.setting_indices[setting_id] = index

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

	if index == #self.settings then
		self.settings[index] = nil
		self.setting_indices[setting_id] = nil
		return
	end

	local last_index = #self.settings
	local last_setting = self.settings[last_index]

	self.settings[index] = last_setting
	self.setting_indices[setting_id] = nil

	self.settings[last_index] = nil
	self.setting_indices[last_setting:GetID()] = index
end

---
-- @return table this Namespace's Settings
function Namespace:GetSettings()
	return self.settings
end

-- TODO documentation for Root_Namespace class
local Root_Namespace = {}
Root_Namespace.__index = Root_Namespace
setmetatable(Root_Namespace, Namespace)

---
-- creates a new Root_Namespace
-- @param string id the name/identifier for this Namespace (will also be used as this Namespace's full_id)
-- @return Root_Namespace the new Root_Namespace
function Root_Namespace:Create(id)
	local namespace = {}
	setmetatable(namespace, self)

	namespace.id = id
	namespace.full_id = PrepareString(id)
	namespace.children = {}
	namespace.children_indices = {}
	namespace.settings = {}
	namespace.setting_indices = {}

	return namespace
end

---
-- Adds a setting at the given path to this Root_Namespace
-- @param table path a list of strings that represent the Setting's position in the Namespace tree
-- @param Setting setting the Setting to add
-- @note this calls the Root_Namespace:OnSettingAdded hook which can be used to add callbacks or change the setting's value
-- @note this will automatically create Namespaces if necessary
function Root_Namespace:AddSetting(path, id, type_id, value)
	local type = GetType(type_id)
	if not type then return end

	local namespace = self
	for i = 1, #path do
		local segment = path[i]
		local next_namespace = namespace:GetChild(segment) or namespace:AddChild(segment)

		namespace = next_namespace
	end

	local setting = namespace:AddSetting(id, type, value)

	if not setting then return end

	setting.OnSourceAdded = self.OnSettingAdded

	self:OnSettingAdded(setting)
end

---
-- Removes the Setting at the given path from this Root_Namespace
-- @param table path a list of strings that represent the Setting's position in the Namespace tree
-- @param string setting_id the name/identifier of the setting that should be removed
function Root_Namespace:RemoveSetting(path, setting_id)
	local namespace = self
	for i = 1, #path do
		local segment = path[i]
		local next_namespace = namespace:GetChild(segment)
		if not next_namespace then return end

		namespace = next_namespace
	end

	namespace:RemoveSetting(setting_id)
end

---
-- returns the full id of a setting that's inside this namespace
-- @param table path a list of strings that represent the Setting's position in the Namespace tree
-- @param string setting_id the name/identifier of the setting that should be removed
-- @return the full id of the Setting with the given setting_id at the given path
-- @note will return nil when no Setting is found
function Root_Namespace:GetFullID(path, setting_id)
	local full_id = self.full_id
	for i = 1, #path do
		full_id = full_id .. namespace_separator .. PrepareString(path[i])
	end
	full_id = full_id .. setting_separator .. PrepareString(setting_id)

	if all_settings[full_id] then
		return full_id
	end
end

---
-- @param table path a list of strings that represent the Setting's position in the Namespace tree
-- @param string setting_id the name/identifier of the setting that should be removed
-- @return Setting the Setting with the given setting_id at the given path
-- @note will return nil when no Setting with the given id is found
function Root_Namespace:GetSetting(path, setting_id)
	local full_id = GetFullID(path, setting_id)
	if not full_id then return end

	return all_settings[full_id]
end

---
-- returns the active value of the setting
-- @param table path a list of strings that represent the Setting's position in the Namespace tree
-- @param string setting_id the name/identifier of the setting that should be removed
-- @return any the active value of the setting
function Root_Namespace:GetActiveValue(path, setting_id)
	local setting = self:GetSetting(path, setting_id)
	if not setting then return end

	return setting:GetActiveValue()
end

---
-- adds a callback to the setting
-- the setting needs to exist in this namespace
-- @param table path a list of strings that represent the Setting's position in the Namespace tree
-- @param string setting_id the name/identifier of the setting that should be removed
-- @param string callback_id the id to store this callback with
-- @param function callback the function to call
function Root_Namespace:AddCallback(path, setting_id, callback_id, callback)
	local setting = self:GetSetting(path, setting_id)
	if not setting then return end

	AddCallback(setting:GetFullID(), callback_id, callback)
end

---
-- removes a callback
-- the setting needs to exist in this namespace
-- @param table path a list of strings that represent the Setting's position in the Namespace tree
-- @param string setting_id the name/identifier of the setting that should be removed
-- @param string callback_id the id of the callback that should be removed
function Root_Namespace:RemoveCallback(path, setting_id, callback_id)
	local setting = self:GetSetting(path, setting_id)
	if not setting then return end

	RemoveCallback(setting:GetFullID(), callback_id)
end

---
-- will be called whenever a Setting is added to this Root_Namespace
-- @param Setting setting the setting that will be added
-- @hook
function Root_Namespace:OnSettingAdded(setting)

end

if SERVER then
	local server_settings_id = "server_settings"
	local client_overrides_id = "client_overrides"

	-- root namespace for all server settings
	server_settings = Root_Namespace:Create(server_settings_id)
	-- root namespace for all client overrides
	client_overrides = Root_Namespace:Create(client_overrides_id)

	local function UpdateSettingOnClients(setting)
		print("[NYI] Settings can't be sent to clients")
	end

	local function RemoveSettingFromClients(setting)
		print("[NYI] Settings can't be removed from clients")
	end

	local function OnServerSettingRemoved(self, setting)
		RemoveCallbacks(setting:GetFullID())
		DeleteSettingFromDatabase(setting)
		RemoveSettingFromClients(setting)
	end

	local function OnServerSettingAdded(self, setting)
		LoadSettingFromDatabase(setting)

		setting.OnValueChanged = function(self)
			SaveSettingToDatabase(self)
			UpdateSettingOnClients(self)
		end

		-- Tasty spaghetti
		setting.OnSourceAdded = OnServerSettingAdded
		setting.OnActiveValueChanged = function(self)
			CallCallbacks(self:GetFullID(), self:GetActiveValue())
		end
		setting.OnRemoved = OnServerSettingRemoved

		SaveSettingToDatabase(setting)
		UpdateSettingOnClients(setting)
	end

	server_settings.OnSettingAdded = OnServerSettingAdded

	local function OnClientOverrideRemoved(self, setting)
		DeleteSettingFromDatabase(setting)
		RemoveSettingFromClients(setting)
	end

	local function OnClientOverrideAdded(self, setting)
		setting.OnValueChanged = function(self)
			SaveSettingToDatabase(self)
			UpdateSettingOnClients(self)
		end

		-- Tasty spaghetti
		setting.OnSourceAdded = OnClientOverrideAdded
		setting.OnRemoved = OnClientOverrideRemoved

		SaveSettingToDatabase(setting)
		UpdateSettingOnClients(setting)
	end

	client_overrides.OnSettingAdded = OnClientOverrideAdded
else
	local client_settings_id = "client_settings"
	local server_settings_id = "server_settings"
	local client_overrides_id = "client_overrides"

	-- stores which client settings are currently overriden
	local overrides = {}

	-- root namespace for all client settings
	client_settings = Root_Namespace:Create(client_settings_id)
	-- root namespace for a copy of all server settings
	server_settings = Root_Namespace:Create(server_settings_id)
	-- root namespace for a copy of all client overrides
	client_overrides = Root_Namespace:Create(client_overrides_id)

	local function OverrideIDToClientSettingID(override_id)
		return client_settings_id .. string.sub(override_id, #client_overrides_id + 1, -1)
	end

	local function ClientSettingIDToOverrideID(override_id)
		return client_overrides_id .. string.sub(override_id, #client_settings_id + 1, -1)
	end

	local function OnClientSettingRemoved(self, setting)
		RemoveCallbacks(setting:GetFullID())
		DeleteSettingFromDatabase(setting)
	end

	local function OnClientSettingAdded(self, setting)
		LoadSettingFromDatabase(setting)

		setting.OnValueChanged = function(self)
			SaveSettingToDatabase(self)
		end

		-- Tasty spaghetti
		setting.OnSourceAdded = OnClientSettingAdded
		setting.OnActiveValueChanged = function(self)
			-- only call callbacks when this setting isn't overriden
			local full_id = self:GetFullID()
			if overrides[full_id] then return end

			CallCallbacks(full_id, self:GetActiveValue())
		end
		setting.OnRemoved = OnClientSettingRemoved

		SaveSettingToDatabase(setting)
	end

	client_settings.OnSettingAdded = OnClientSettingAdded
	-- return overriden values whenever the active value is requested
	client_settings.GetActiveValue = function(self, path, setting_id)
		local setting = self:GetSetting(path, setting_id)
		if not setting then return end

		local full_id = setting:GetFullID()
		if not overrides[full_id] then
			return setting:GetActiveValue()
		end

		return all_settings[ClientSettingIDToOverrideID(full_id)]:GetActiveValue()
	end

	local function OnServerSettingRemoved(self, setting)
		RemoveCallbacks(setting:GetFullID())
	end

	local function OnServerSettingAdded(self, setting)
		-- Tasty spaghetti
		setting.OnSourceAdded = OnServerSettingAdded
		setting.OnActiveValueChanged = function(self)
			CallCallbacks(self:GetFullID(), self:GetActiveValue())
		end
		setting.OnRemoved = OnServerSettingRemoved
	end

	server_settings.OnSettingAdded = OnServerSettingAdded

	local function OnClientOverrideRemoved(self, setting)
		local full_id = setting:GetFullID();
		local setting_id = OverrideIDToClientSettingID(full_id)

		overrides[setting_id] = nil
		RemoveCallbacks(full_id)

		-- call callbacks for original setting
		CallCallbacks(setting_id, all_settings[setting_id]:GetActiveValue())
	end

	local function OnClientOverrideAdded(self, setting)
		-- mark callback id as overriden
		local full_id = setting:GetFullID()
		local setting_id = OverrideIDToClientSettingID(full_id)
		overrides[setting_id] = true

		-- Tasty spaghetti
		setting.OnSourceAdded = OnServerSettingAdded
		setting.OnActiveValueChanged = function(self)
			local new_value = self:GetActiveValue()
			CallCallbacks(full_id, new_value)
			-- call callbacks for original setting
			CallCallbacks(setting_id, new_value)
		end

		setting.OnRemoved = OnClientOverrideRemoved

		-- call callbacks
		CallCallbacks(setting_id, self:GetActiveValue())
	end

	client_overrides.OnSettingAdded = OnClientOverrideAdded
end
