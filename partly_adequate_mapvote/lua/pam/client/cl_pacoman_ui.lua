-- colors
local col_base = {r = 40, g = 40, b = 40, a = 255}
local col_base_darker = {r = 30, g = 30, b = 30, a = 255}
local col_base_darkest = {r = 20, g = 20, b = 20, a = 255}
local col_text = {r = 255, g = 255, b = 255, a = 200}

-- images and icons
local ic_setting = Material("vgui/pam/ic_setting")
local ic_namespace = Material("vgui/pam/ic_namespace")

-- namespace types
local CLIENT_SETTING = 0
local CLIENT_OVERRIDE = 1
local SERVER_SETTING = 2

-- size constants
local TITLE_BAR_HEIGHT = 25
local HEADER_HEIGHT = 25
local INDENTATION = 15
local TREE_WIDTH = 300

-- table of all panels
local full_id_to_panel = {}

-- the current configuration screen
local pacoman_ui = nil

-- panels for different datatypes
local type_panel_ids = {}

local function RegisterTypePanel(id, panel_id)
	type_panel_ids[id] = panel_id
end

local TYPE_PANEL_BASE = {}

function TYPE_PANEL_BASE:Init()
	self.setting_panel = nil
end

function TYPE_PANEL_BASE:SetType(pnl_type)
	self.type = pnl_type
end

function TYPE_PANEL_BASE:SetValue()

end

function TYPE_PANEL_BASE:GetValue()

end

function TYPE_PANEL_BASE:OnValueChanged(new_value)

end

derma.DefineControl("pacoman_type_base", "", TYPE_PANEL_BASE, "DPanel")

-- Panel for changing any values
local ANY_TYPE_PANEL = {}

function ANY_TYPE_PANEL:Init()
	self:SetPaintBackground(false)
	self.txt_setting_value = vgui.Create("DTextEntry", self)
	self.txt_setting_value:SetText("")
	self.txt_setting_value:Dock(FILL)
	self.txt_setting_value:DockMargin(0, 0, 0, 0)
	self.txt_setting_value:SetTextColor(col_text)
	self.txt_setting_value:SetCursorColor(col_text)
	self.txt_setting_value:SetPaintBackground(false)
	self.txt_setting_value.OnGetFocus = function(s)
		pacoman_ui:SetKeyboardInputEnabled(true)
	end
	self.txt_setting_value.OnLoseFocus = function(s)
		pacoman_ui:SetKeyboardInputEnabled(false)
	end
	self.txt_setting_value.OnEnter = function(s, serialized_value)
		self:OnValueChanged(self:GetValue())
	end
end

function ANY_TYPE_PANEL:SetValue(value)
	self.txt_setting_value:SetText(self.type:Serialize(value))
end

function ANY_TYPE_PANEL:GetValue()
	return self.type:Deserialize(self.txt_setting_value:GetText())
end

derma.DefineControl("pacoman_type_any", "", ANY_TYPE_PANEL, "pacoman_type_base")

-- Panel for changing Boolean values
local BOOLEAN_TYPE_PANEL = {}

function BOOLEAN_TYPE_PANEL:Init()
	self:SetPaintBackground(false)
	self.btn_setting_value = vgui.Create("DButton", self)
	self.btn_setting_value:SetText("")
	self.btn_setting_value:Dock(FILL)
	self.btn_setting_value:DockMargin(5, 0, 5, 0)
	self.btn_setting_value:SetTextColor(col_text)
	self.btn_setting_value:SetContentAlignment(4)
	self.btn_setting_value:SetIsToggle(true)
	self.btn_setting_value:SetPaintBackground(false)
	self.btn_setting_value.OnToggled = function(s, toggle_state)
		self.btn_setting_value:SetText(tostring(toggle_state))
		self:OnValueChanged(self:GetValue())
	end
end

function BOOLEAN_TYPE_PANEL:SetValue(value)
	self.btn_setting_value:SetToggle(value)
	self.btn_setting_value:SetText(tostring(value))
end

function BOOLEAN_TYPE_PANEL:GetValue()
	return self.btn_setting_value:GetToggle()
end

derma.DefineControl("pacoman_type_boolean", "", BOOLEAN_TYPE_PANEL, "pacoman_type_base")
RegisterTypePanel(pacoman.TYPE_BOOLEAN.id, "pacoman_type_boolean")

-- Panel for changing percentage values
local PERCENTAGE_TYPE_PANEL = {}

function PERCENTAGE_TYPE_PANEL:Init()
	self:SetPaintBackground(false)
	self.sld_setting_value = vgui.Create("DNumSlider", self)
	self.sld_setting_value:Dock(FILL)
	self.sld_setting_value:DockMargin(0, 0, 5, 0)
	self.sld_setting_value:SetMax(100)
	self.sld_setting_value:SetDecimals(2)

	self.changed_externally = false
	self.sld_setting_value.OnValueChanged = function(s, value)
		if self.changed_externally then return end

		self:OnValueChanged(self:GetValue())
	end

	self.sld_setting_value:GetChild(2):Dock(RIGHT)
	self.sld_setting_value:GetChild(0):Dock(LEFT)

	self.txt_setting_value = self.sld_setting_value:GetTextArea()
	self.txt_setting_value:SetTextColor(col_text)
	self.txt_setting_value:SetCursorColor(col_text)
	self.txt_setting_value.OnGetFocus = function(s)
		pacoman_ui:SetKeyboardInputEnabled(true)
	end
	self.txt_setting_value.OnLoseFocus = function(s)
		pacoman_ui:SetKeyboardInputEnabled(false)
	end
end

function PERCENTAGE_TYPE_PANEL:SetValue(value)
	self.changed_externally = true
	self.sld_setting_value:SetValue(value * 100)
	self.changed_externally = false
end

function PERCENTAGE_TYPE_PANEL:GetValue()
	return self.sld_setting_value:GetValue() * 0.01
end

derma.DefineControl("pacoman_type_percentage", "", PERCENTAGE_TYPE_PANEL, "pacoman_type_base")
RegisterTypePanel(pacoman.TYPE_PERCENTAGE.id, "pacoman_type_percentage")

-- Panel for displaying a list of panels
local PANEL_LIST = {}

function PANEL_LIST:Init()
	self:SetPaintBackground(false)
end

function PANEL_LIST:Paint(w, h)
	surface.SetDrawColor(col_base_darkest)
	surface.DrawRect(INDENTATION - 5, 0, 5, h - 2)
end

function PANEL_LIST:PerformLayout()
	local current_width, current_height = self:GetSize()
	local new_height = 0

	for _, panel in ipairs(self:GetChildren()) do
		if not panel:IsMarkedForDeletion() then
			-- change position
			panel:SetPos(INDENTATION, new_height)
			panel:SetWidth(current_width - INDENTATION)

			-- update current height
			if panel:IsVisible() then
				local _, h = panel:GetSize()
				new_height = new_height + h
			end
		end
	end

	if new_height ~= current_height then
		self:SetSize(current_width, new_height)
		return
	end
end

derma.DefineControl("pacoman_panel_list", "", PANEL_LIST, "DPanel")

-- Tree node panel
-- Has a header panel and a list of panels
local TREE_NODE = {}

function TREE_NODE:Init()
	self.header = vgui.Create("DButton", self)
	self.header:SetIsToggle(true)
	self.header:SetToggle(false)
	self.header:SetHeight(HEADER_HEIGHT)
	self.header:SetPos(0, 0)
	self.header:SetText("")
	self.header:SetContentAlignment(4)

	self.header.lbl_text = vgui.Create("DLabel", self.header)
	self.header.lbl_text:SetPos(HEADER_HEIGHT, 0)

	self.header.img_icon = vgui.Create("DImage", self.header)
	self.header.img_icon:SetPos(4, 3)
	self.header.img_icon:SetSize(HEADER_HEIGHT - 8, HEADER_HEIGHT - 8)

	self.header.Paint = function(s, w, h)
		surface.SetDrawColor(col_base_darker)
		surface.DrawRect(0, 0, w - 1, h - 2)
		surface.SetDrawColor(col_base_darkest)
		surface.DrawRect(0, h - 4, w - 1, 2)
	end

	self.Paint = function(s, w, h)
		surface.SetDrawColor(col_base)
		surface.DrawRect(0, 0, w, h)
	end

	self.children = vgui.Create("pacoman_panel_list", self)
	self.children:SetPos(0, HEADER_HEIGHT)
	self.children:SetVisible(false)

	self.header.OnToggled = function(header, state)
		self.children:SetVisible(state)
		self:InvalidateLayout()
	end
end

function TREE_NODE:PerformLayout()
	local w, old_h = self:GetSize()
	self.header:SetWidth(w)
	self.header.lbl_text:SetWidth(w - HEADER_HEIGHT)
	self.children:SetWidth(w)

	local new_h = HEADER_HEIGHT
	if self.children:IsVisible() then
		local _, children_h = self.children:GetSize()
		new_h = new_h + children_h
	end

	if new_h ~= old_h then
		self:SetSize(w, new_h)
	end
end

function TREE_NODE:OnClicked()

end

derma.DefineControl("pacoman_tree_node", "", TREE_NODE, "DPanel")

-- search function for strings
local function StringFitsSearchTerm(to_test, search_term)
	if not search_term or search_term == "" then return true end
	if #search_term > #to_test then return false end

	local i = 1
	for j = 1, #to_test do
		if to_test:sub(j, j):lower() == search_term:sub(i, i):lower() then
			if i >= #search_term then
				return true
			end
			i = i + 1
		end
	end

	return false
end

-- search function for setting panels
local function SettingPanelSearch(self, search_term)
	local fits = StringFitsSearchTerm(self.setting.full_id, search_term)

	if self.header:GetToggle() then
		self.header:Toggle()
	else
		self.children:InvalidateLayout()
	end

	self:InvalidateLayout()
	self:SetVisible(fits)

	return fits
end

-- search function for namespace panels
local function NamespacePanelSearch(self, search_term)
	local fits = false
	for _, child in pairs(self.children:GetChildren()) do
		fits = child:Search(search_term) or fits
	end

	if self.header:GetToggle() ~= (fits and search_term ~= "") then
		self.header:Toggle()
	else
		self.children:InvalidateLayout()
	end

	self:InvalidateLayout()
	self:SetVisible(fits or search_term == "")

	return fits
end

-- function to add a setting panel to a panel list
local function AddSettingPanel(parent_panel, setting, namespace_type)
	local setting_panel = vgui.Create("pacoman_tree_node", parent_panel)
	setting_panel.setting = setting
	setting_panel.namespace_type = namespace_type
	setting_panel.header.lbl_text:SetText(setting.id)
	setting_panel.header.img_icon:SetMaterial(ic_setting)
	setting_panel.header.DoClick = function(self)
		pacoman_ui:SetSetting(setting_panel.setting, setting_panel.namespace_type)
		self:Toggle()
	end

	setting_panel.Search = SettingPanelSearch
	full_id_to_panel[setting.full_id] = setting_panel

	for i = 1, #setting.sources do
		AddSettingPanel(setting_panel.children, setting.sources[i], namespace_type)
	end

	return setting_panel
end

-- function to add a namespace panel to a panel list
local function AddNamespacePanel(parent_panel, namespace, namespace_type)
	local namespace_panel = vgui.Create("pacoman_tree_node", parent_panel)
	namespace_panel.namespace = namespace
	namespace_panel.namespace_type = namespace_type
	namespace_panel.header.lbl_text:SetText(namespace.id)
	namespace_panel.header.img_icon:SetMaterial(ic_namespace)
	namespace_panel.Search = NamespacePanelSearch
	full_id_to_panel[namespace.full_id] = namespace_panel

	for i = 1, #namespace.children do
		AddNamespacePanel(namespace_panel.children, namespace.children[i], namespace_type)
	end

	for i = 1, #namespace.settings do
		AddSettingPanel(namespace_panel.children, namespace.settings[i], namespace_type)
	end

	return namespace_panel
end

-- Pacoman hooks
-- Child added to Namespace
hook.Add("PACOMAN_NamespaceChildAdded", "PACOMAN_UI_NamespaceChildAdded", function(parent, child)
	local parent_panel = full_id_to_panel[parent.full_id]
	if not parent_panel then return end

	AddNamespacePanel(parent_panel.children, child, parent_panel.namespace_type)
end)

-- Setting added to Namespace
hook.Add("PACOMAN_NamespaceSettingAdded", "PACOMAN_UI_NamespaceSettingAdded", function(parent, setting)
	local parent_panel = full_id_to_panel[parent.full_id]
	if not parent_panel then return end

	AddSettingPanel(parent_panel.children, setting, parent_panel.namespace_type)
end)

-- Setting removed from Namespace
hook.Add("PACOMAN_NamespaceSettingRemoved", "PACOMAN_UI_NamespaceSettingRemoved", function(parent, setting)
	local full_id = setting.full_id
	local setting_panel = full_id_to_panel[full_id]
	if not setting_panel then return end

	setting_panel:Remove()
	full_id_to_panel[full_id] = nil
end)

-- Source added to Setting
hook.Add("PACOMAN_SettingSourceAdded", "PACOMAN_UI_SettingSourceAdded", function(parent, source)
	local parent_panel = full_id_to_panel[parent.full_id]
	if not parent_panel then return end

	AddSettingPanel(parent_panel.children, source, parent_panel.namespace_type)
end)

-- Source removed from Setting
hook.Add("PACOMAN_SettingSourceRemoved", "PACOMAN_UI_SettingSourceRemoved", function(parent, source)
	print("Source removed")
	local full_id = source.full_id
	local source_panel = full_id_to_panel[full_id]
	print(source_panel)
	if not source_panel then return end

	source_panel:Remove()
	full_id_to_panel[full_id] = nil
end)

-- Setting made dependent
hook.Add("PACOMAN_SettingMadeDependent", "PACOMAN_UI_SettingMadeDependent", function(setting)
	if pacoman_ui and setting == pacoman_ui.setting_panel.setting then
		pacoman_ui:RefreshSettingPanel()
	end
end)

-- Setting made independent
hook.Add("PACOMAN_SettingMadeIndependent", "PACOMAN_UI_SettingMadeIndependent", function(setting)
	if pacoman_ui and setting == pacoman_ui.setting_panel.setting then
		pacoman_ui:RefreshSettingPanel()
	end
end)

-- Setting made independent
hook.Add("PACOMAN_SettingValueChanged", "PACOMAN_UI_SettingValueChanged", function(setting)
	if pacoman_ui and setting == pacoman_ui.setting_panel.setting then
		pacoman_ui:RefreshSettingPanel()
	end
end)

-- Setting screen that allows modifying the currently selected setting
local DEFAULT_SETTING_PANEL = {}

function DEFAULT_SETTING_PANEL:Init()
	self.Paint = function(s, w, h)
		surface.SetDrawColor(col_base)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(col_base_darker)
		surface.DrawRect(0, 0, w, HEADER_HEIGHT * 4)
		surface.SetDrawColor(col_base_darkest)
		surface.DrawRect(w * 0.25, HEADER_HEIGHT, w * 0.75, HEADER_HEIGHT * 3)
	end
end

function DEFAULT_SETTING_PANEL:SetSetting(setting, namespace_type)
	self.setting = setting
	self.namespace_type = namespace_type

	local width, height = self:GetSize()
	local quarter_width = width * 0.25
	local three_quarter_width = width * 0.75
	local panel_id = type_panel_ids[setting.type.id] or "pacoman_type_any"
	local depends_on = self.setting.depends_on

	local lbl_setting_name = vgui.Create("DLabel", self)
	lbl_setting_name:SetPos(0, 0)
	lbl_setting_name:SetSize(quarter_width, HEADER_HEIGHT)
	lbl_setting_name:SetText(" Name:")
	lbl_setting_name:SetTextColor(col_text)
	lbl_setting_name:SetPaintBackground(false)

	local lbl_setting_id = vgui.Create("DLabel", self)
	lbl_setting_id:SetPos(quarter_width, 0)
	lbl_setting_id:SetSize(three_quarter_width, HEADER_HEIGHT)
	lbl_setting_id:SetContentAlignment(4)
	lbl_setting_id:SetText("  " .. setting.full_id)
	lbl_setting_id:SetTextColor(col_text)

	local lbl_setting_value = vgui.Create("DLabel", self)
	lbl_setting_value:SetPos(0, HEADER_HEIGHT)
	lbl_setting_value:SetSize(quarter_width, HEADER_HEIGHT)
	lbl_setting_value:SetText(" Value: ")
	lbl_setting_value:SetTextColor(col_text)

	self.pnl_setting_value = vgui.Create(panel_id, self)
	self.pnl_setting_value:SetPos(quarter_width + 4, HEADER_HEIGHT)
	self.pnl_setting_value:SetSize(three_quarter_width - 4, HEADER_HEIGHT)
	self.pnl_setting_value:SetType(self.setting.type)
	self.pnl_setting_value:SetValue(self.setting.value)
	self.pnl_setting_value.OnValueChanged = function(s, value)
		self:AttemptValueChange(value)
	end

	local lbl_setting_dependency = vgui.Create("DLabel", self)
	lbl_setting_dependency:SetPos(0, HEADER_HEIGHT * 2)
	lbl_setting_dependency:SetSize(quarter_width, HEADER_HEIGHT)
	lbl_setting_dependency:SetText(" Depends on: ")
	lbl_setting_dependency:SetTextColor(col_text)

	self.cb_setting_dependency = vgui.Create("DComboBox", self)
	self.cb_setting_dependency:SetPos(quarter_width, HEADER_HEIGHT * 2)
	self.cb_setting_dependency:SetSize(three_quarter_width, HEADER_HEIGHT)
	self.cb_setting_dependency:SetText("Nothing")
	self.cb_setting_dependency:SetTextColor(col_text)
	self.cb_setting_dependency:AddChoice("Nothing", nil, true)
	self.cb_setting_dependency.Paint = function(s, w, h)
		surface.SetDrawColor(col_base_darker)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(col_base_darkest)
		surface.DrawRect(0, 0, w, h)
	end

	for i = 1, #pacoman.game_properties do
		local game_property = pacoman.game_properties[i]
		self.cb_setting_dependency:AddChoice(game_property.id, game_property)
	end

	self.cb_setting_dependency.OnSelect = function(s, index, gp_id, game_property)
		self:AttemptDependencyChange(game_property)
	end


	if depends_on then
		self.cb_setting_dependency:ChooseOptionID(pacoman.game_property_indices[depends_on.id] + 1)

		local lbl_add_source = vgui.Create("DLabel", self)
		lbl_add_source:SetPos(0, HEADER_HEIGHT * 3)
		lbl_add_source:SetSize(quarter_width, HEADER_HEIGHT)
		lbl_add_source:SetText(" Add Source: ")
		lbl_add_source:SetTextColor(col_text)

		local panel_id = type_panel_ids[depends_on.type.id] or "pacoman_type_any"
		self.pnl_new_source_id = vgui.Create(panel_id, self)
		self.pnl_new_source_id:SetPos(quarter_width + 4, HEADER_HEIGHT * 3)
		self.pnl_new_source_id:SetSize(three_quarter_width - 4 - HEADER_HEIGHT, HEADER_HEIGHT)
		self.pnl_new_source_id:SetType(depends_on.type)
		self.pnl_new_source_id:SetValue(depends_on.value)

		local btn_add_source = vgui.Create("DButton", self)
		btn_add_source:SetPos(width - HEADER_HEIGHT, HEADER_HEIGHT * 3)
		btn_add_source:SetSize(HEADER_HEIGHT, HEADER_HEIGHT)
		btn_add_source:SetText("+")
		btn_add_source:SetTextColor(col_text)
		btn_add_source:SetContentAlignment(4)
		btn_add_source:SetPaintBackground(false)
		btn_add_source.DoClick = function(s)
			self:AttemptSourceAddition(self.pnl_new_source_id:GetValue())
		end
	else
		self.cb_setting_dependency:ChooseOptionID(1)
	end
end

function DEFAULT_SETTING_PANEL:AttemptDependencyChange(game_property)
	if self.setting.depends_on == game_property then return end

	-- change dependency of server sided setting
	if self.namespace_type ~= CLIENT_SETTING then
		pacoman.RequestDependencyChange(self.setting, game_property)
		return
	end

	-- change dependency of client setting
	if game_property then
		self.setting:MakeDependent(game_property)
	else
		self.setting:MakeIndependent()
	end
end

function DEFAULT_SETTING_PANEL:AttemptValueChange(value)
	if value == nil then
		self.pnl_setting_value:SetValue(self.setting.value)
		return
	end

	if self.namespace_type ~= CLIENT_SETTING then
		pacoman.RequestValueChange(self.setting, value)
		return
	end

	self.setting:SetValue(value)
end

function DEFAULT_SETTING_PANEL:AttemptSourceAddition(id)
	if self.namespace_type ~= CLIENT_SETTING then
		pacoman.RequestSourceAddition(self.setting, id, self.setting.value)
		return
	end

	self.setting:AddSource(id, self.setting.value)
end

function DEFAULT_SETTING_PANEL:AttemptSourceRemoval(id)
	if self.namespace_type ~= CLIENT_SETTING then
		pacoman.RequestSourceRemoval(self.setting, id)
		return
	end

	self.setting:RemoveSource(id)
end

function DEFAULT_SETTING_PANEL:AttemptOverrideAddition()
	if self.namespace_type ~= CLIENT_SETTING then return end

	pacoman.RequestOverrideAddition(self.setting)
end

function DEFAULT_SETTING_PANEL:AttemptOverrideRemoval()
	if self.namespace_type ~= CLIENT_SETTING then return end

	pacoman.RequestOverrideRemoval(self.setting)
end

derma.DefineControl("pacoman_default_setting_panel", "", DEFAULT_SETTING_PANEL, "DPanel")

-- Configuration screen that shows a list of the setting trees and a setting screen
local DEFAULT_CONFIGURATION_SCREEN = {}

function DEFAULT_CONFIGURATION_SCREEN:Init()
	-- size
	local width = ScrW() * 0.5
	local height = ScrH() * 0.75

	-- position and size of the setting panel
	self.setting_panel = nil
	self.setting_pos_x = TREE_WIDTH
	self.setting_pos_y = TITLE_BAR_HEIGHT
	self.setting_width = width - TREE_WIDTH
	self.setting_height = height - TITLE_BAR_HEIGHT

	-- basic setup
	self:SetSize(width, height)
	self:SetPos((ScrW() - width) * 0.5, (ScrH() - height) * 0.5)
	self:SetZPos(-100)
	self:SetTitle("")
	self:SetDeleteOnClose(false)

	self.Paint = function(s, w, h)
		surface.SetDrawColor(col_base)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(col_base_darkest)
		surface.DrawRect(0, 0, w, TITLE_BAR_HEIGHT)
		surface.DrawRect(0, TITLE_BAR_HEIGHT, TREE_WIDTH, HEADER_HEIGHT)
	end

	-- title bar
	local lbl_title = vgui.Create("DLabel", self)
	lbl_title:SetPos(0, 0)
	lbl_title:SetSize(width, HEADER_HEIGHT)
	lbl_title:SetTextColor(col_text)
	lbl_title:SetContentAlignment(5)
	lbl_title:SetPaintBackground(false)
	lbl_title:SetText("Partly Adequate Configuration Manager")

	-- setting trees
	local tree_container = vgui.Create("DScrollPanel", self)
	tree_container:SetPos(0, TITLE_BAR_HEIGHT  + HEADER_HEIGHT)
	tree_container:SetSize(TREE_WIDTH, height - TITLE_BAR_HEIGHT - HEADER_HEIGHT)
	tree_container.Paint = function(s, w, h)
		surface.SetDrawColor(col_base)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(col_base_darkest)
		surface.DrawRect(w - 15, 0, 15, h)
	end

	local scroll_bar = tree_container:GetVBar()
	function scroll_bar:Paint(w, h)

	end

	function scroll_bar.btnUp:Paint(w, h)
		surface.SetDrawColor(col_base)
		surface.DrawRect(2, 2, w - 4, h - 4)
	end

	function scroll_bar.btnGrip:Paint(w, h)
		surface.SetDrawColor(col_base)
		surface.DrawRect(2, 2, w - 4, h - 4)
	end

	function scroll_bar.btnDown:Paint(w, h)
		surface.SetDrawColor(col_base)
		surface.DrawRect(2, 2, w - 4, h - 4)
	end

	local tree_list = vgui.Create("pacoman_panel_list", tree_container)
	tree_list:SetBackgroundColor(col_base_darkest)
	tree_list:SetWidth(TREE_WIDTH - 15)

	self.client_settings_panel = AddNamespacePanel(tree_list, pacoman.client_settings, CLIENT_SETTING)
	self.client_overrides_panel = AddNamespacePanel(tree_list, pacoman.client_overrides, CLIENT_OVERRIDE)
	self.server_settings_panel = AddNamespacePanel(tree_list, pacoman.server_settings, SERVER_SETTING)

	hook.Add("PACOMAN_SettingValueChanged", "PACOMAN_UI_value_changed", function(setting)
		if self.setting == setting then
			self.pnl_setting_value:SetValue(setting.value)
		end
	end)

	-- Search bar for the setting trees
	local txt_search = vgui.Create("DTextEntry", self)
	txt_search:SetPos(0, TITLE_BAR_HEIGHT)
	txt_search:SetSize(TREE_WIDTH, HEADER_HEIGHT)
	txt_search:DockMargin(0, 0, 0, 0)
	txt_search:SetTextColor(col_text)
	txt_search:SetCursorColor(col_text)
	txt_search:SetPlaceholderText("Search for settings...")
	txt_search:SetPaintBackground(false)
	txt_search.OnGetFocus = function(s)
		self:SetKeyboardInputEnabled(true)
	end
	txt_search.OnLoseFocus = function(s)
		self:SetKeyboardInputEnabled(false)
	end
	txt_search.OnChange = function(s)
		self:Search(s:GetValue())
		tree_list:InvalidateLayout()
	end

	-- Open Panel
	self:MakePopup()
	self:SetKeyboardInputEnabled(false)
end

-- Search the setting trees
function DEFAULT_CONFIGURATION_SCREEN:Search(search_term)
	self.client_settings_panel:Search(search_term)
	self.client_overrides_panel:Search(search_term)
	self.server_settings_panel:Search(search_term)
end

-- Switch the currently selected setting
function DEFAULT_CONFIGURATION_SCREEN:SetSetting(setting, namespace_type)
	-- remove old panel if it exists
	if IsValid(self.setting_panel) then
		self.setting_panel:Remove()
	end

	-- create new panel
	self.setting_panel = vgui.Create("pacoman_default_setting_panel", self)
	self.setting_panel:SetPos(self.setting_pos_x, self.setting_pos_y)
	self.setting_panel:SetSize(self.setting_width, self.setting_height)

	-- add setting information
	self.setting_panel:SetSetting(setting, namespace_type)
end

function DEFAULT_CONFIGURATION_SCREEN:RefreshSettingPanel()
	self:SetSetting(self.setting_panel.setting, self.setting_panel.namespace_type)
end

derma.DefineControl("pacoman_default_configuration_screen", "", DEFAULT_CONFIGURATION_SCREEN, "DFrame")

--toggle menu visibility
concommand.Add("pacoman_toggle_menu", function(player, cmd, args, arg_str)
	if pacoman_ui then
		pacoman_ui:SetVisible(not pacoman_ui:IsVisible())
		return
	end
	pacoman_ui = vgui.Create("pacoman_default_configuration_screen")
end)
