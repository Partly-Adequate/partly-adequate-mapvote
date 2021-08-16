-- colors
local col_base = {r = 40, g = 40, b = 40, a = 255}
local col_base_darker = {r = 30, g = 30, b = 30, a = 255}
local col_base_darkest = {r = 20, g = 20, b = 20, a = 255}
local col_text = {r = 255, g = 255, b = 255, a = 200}

local TITLE_BAR_HEIGHT = 25
local HEADER_HEIGHT = 25
local INDENTATION = 15
local TREE_WIDTH = 300

local pacoman_ui = nil

local type_panel_ids = {}

local function RegisterTypePanel(id, panel_id)
	type_panel_ids[id] = panel_id
end

local TYPE_PANEL_BASE = {}

function TYPE_PANEL_BASE:Init()
	self.setting_panel = nil
end

function TYPE_PANEL_BASE:SetSettingPanel(setting_panel)
	self.setting_panel = setting_panel
	self.type = setting_panel.setting.type
	self:SetValue(self.setting_panel.setting.value)
end

function TYPE_PANEL_BASE:SetValue()

end

function TYPE_PANEL_BASE:GetValue()

end

derma.DefineControl("pacoman_type_base", "", TYPE_PANEL_BASE, "DPanel")


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
		self.setting_panel:SetKeyboardInputEnabled(true)
	end
	self.txt_setting_value.OnLoseFocus = function(s)
		self.setting_panel:SetKeyboardInputEnabled(false)
	end
	self.txt_setting_value.OnEnter = function(s, serialized_value)
		self.setting_panel:AttemptValueChange()
	end
end

function ANY_TYPE_PANEL:SetValue(value)
	self.txt_setting_value:SetText(self.type:Serialize(value))
end

function ANY_TYPE_PANEL:GetValue()
	return self.type:Deserialize(self.txt_setting_value:GetText())
end

derma.DefineControl("pacoman_type_any", "", ANY_TYPE_PANEL, "pacoman_type_base")


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
		self.setting_panel:AttemptValueChange()
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


local PERCENTAGE_TYPE_PANEL = {}

function PERCENTAGE_TYPE_PANEL:Init()
	self:SetPaintBackground(false)
	self.sld_setting_value = vgui.Create("DNumSlider", self)
	self.sld_setting_value:Dock(FILL)
	self.sld_setting_value:DockMargin(0, 0, 5, 0)
	self.sld_setting_value:SetMax(100)
	self.sld_setting_value:SetDecimals(2)
	self.sld_setting_value.OnValueChanged = function(s, value)
		self.setting_panel:AttemptValueChange()
	end

	self.sld_setting_value:GetChild(2):Dock(RIGHT)
	self.sld_setting_value:GetChild(0):Dock(LEFT)

	self.txt_setting_value = self.sld_setting_value:GetTextArea()
	self.txt_setting_value:SetTextColor(col_text)
	self.txt_setting_value:SetCursorColor(col_text)
	self.txt_setting_value.OnGetFocus = function(s)
		self.setting_panel:SetKeyboardInputEnabled(true)
	end
	self.txt_setting_value.OnLoseFocus = function(s)
		self.setting_panel:SetKeyboardInputEnabled(false)
	end
	self.txt_setting_value.OnEnter = function(s, serialized_value)
		self.setting_panel:AttemptValueChange()
	end
end

function PERCENTAGE_TYPE_PANEL:SetValue(value)
	self.sld_setting_value:SetValue(value * 100)
end

function PERCENTAGE_TYPE_PANEL:GetValue()
	return self.sld_setting_value:GetValue() / 100
end

derma.DefineControl("pacoman_type_percentage", "", PERCENTAGE_TYPE_PANEL, "pacoman_type_base")
RegisterTypePanel(pacoman.TYPE_PERCENTAGE.id, "pacoman_type_percentage")


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


local TREE_NODE = {}

function TREE_NODE:Init()
	self.header = vgui.Create("DButton", self)
	self.header:SetIsToggle(true)
	self.header:SetToggle(false)
	self.header:SetHeight(HEADER_HEIGHT)
	self.header:SetPos(0, 0)
	self.header:SetTextColor(col_text)
	self.header:SetContentAlignment(4)

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


local function AddSettingPanel(parent_panel, setting, on_selected)
	local setting_panel = vgui.Create("pacoman_tree_node", parent_panel)
	setting_panel.OnClicked = on_selected
	setting_panel.header:SetText(" " .. setting.id)
	setting_panel.header.DoClick = function(self)
		setting_panel:OnClicked()
	end
	setting_panel.setting = setting

	for i = 1, #setting.sources do
		AddSettingPanel(setting_panel.children, setting.sources[i], on_selected)
	end

	return setting_panel
end

local function AddNamespacePanel(parent_panel, namespace, on_selected)
	local namespace_panel = vgui.Create("pacoman_tree_node", parent_panel)
	namespace_panel.header:SetText(" " .. namespace.id)

	namespace_panel.namespace = namespace
	for i = 1, #namespace.children do
		AddNamespacePanel(namespace_panel.children, namespace.children[i], on_selected)
	end

	for i = 1, #namespace.settings do
		AddSettingPanel(namespace_panel.children, namespace.settings[i], on_selected)
	end

	return namespace_panel
end


local DEFAULT_SETTING_SCREEN = {}

function DEFAULT_SETTING_SCREEN:Init()
	local width = ScrW() * 0.5
	local height = ScrH() * 0.75
	self.setting_pos_x = TREE_WIDTH
	self.setting_width = width - TREE_WIDTH

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
		surface.SetDrawColor(col_base_darker)
		surface.DrawRect(self.setting_pos_x, HEADER_HEIGHT, self.setting_width, HEADER_HEIGHT * 3)
		surface.SetDrawColor(col_base_darkest)
		surface.DrawRect(self.setting_pos_x + 0.25 * self.setting_width, HEADER_HEIGHT * 2, self.setting_width * 0.75, HEADER_HEIGHT)
	end

	local lbl_title = vgui.Create("DLabel", self)
	lbl_title:SetPos(0, 0)
	lbl_title:SetSize(width, HEADER_HEIGHT)
	lbl_title:SetTextColor(col_text)
	lbl_title:SetContentAlignment(5)
	lbl_title:SetPaintBackground(false)
	lbl_title:SetText("Partly Adequate Configuration Manager")

	self.setting = nil
	self.is_server_setting = false

	local lbl_setting_name = vgui.Create("DLabel", self)
	lbl_setting_name:SetPos(self.setting_pos_x, HEADER_HEIGHT)
	lbl_setting_name:SetSize(self.setting_width * 0.25, HEADER_HEIGHT)
	lbl_setting_name:SetText(" Name:")
	lbl_setting_name:SetTextColor(col_text)
	lbl_setting_name:SetPaintBackground(false)

	self.lbl_setting_id = vgui.Create("DLabel", self)
	self.lbl_setting_id:SetPos(self.setting_pos_x + self.setting_width * 0.25, HEADER_HEIGHT)
	self.lbl_setting_id:SetSize(self.setting_width * 0.75, HEADER_HEIGHT)
	self.lbl_setting_id:SetContentAlignment(4)
	self.lbl_setting_id:SetText("")
	self.lbl_setting_id:SetTextColor(col_text)

	local lbl_setting_value = vgui.Create("DLabel", self)
	lbl_setting_value:SetPos(self.setting_pos_x, HEADER_HEIGHT * 2)
	lbl_setting_value:SetSize(self.setting_width * 0.25, HEADER_HEIGHT)
	lbl_setting_value:SetText(" Value: ")
	lbl_setting_value:SetTextColor(col_text)

	local lbl_setting_dependency = vgui.Create("DLabel", self)
	lbl_setting_dependency:SetPos(self.setting_pos_x, HEADER_HEIGHT * 3)
	lbl_setting_dependency:SetSize(self.setting_width * 0.25, HEADER_HEIGHT)
	lbl_setting_dependency:SetText(" Depends on: ")
	lbl_setting_dependency:SetTextColor(col_text)

	self.cb_setting_dependency = vgui.Create("DComboBox", self)
	self.cb_setting_dependency:SetPos(self.setting_pos_x + self.setting_width * 0.25, HEADER_HEIGHT * 3)
	self.cb_setting_dependency:SetSize(self.setting_width * 0.75, HEADER_HEIGHT)
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

	local tree_container = vgui.Create("DScrollPanel", self)
	tree_container:SetPos(0, TITLE_BAR_HEIGHT)
	tree_container:SetSize(TREE_WIDTH, height - TITLE_BAR_HEIGHT)
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

	local function OnClientSettingSelected(s)
		self:SetSetting(s.setting, false)
	end

	local function OnServerSettingSelected(s)
		self:SetSetting(s.setting, true)
	end

	self.client_settings_panel = AddNamespacePanel(tree_list, pacoman.client_settings, OnClientSettingSelected)
	self.client_overrides_panel = AddNamespacePanel(tree_list, pacoman.client_overrides, OnServerSettingSelected)
	self.server_settings_panel = AddNamespacePanel(tree_list, pacoman.server_settings, OnServerSettingSelected)

	self:MakePopup()
	self:SetKeyboardInputEnabled(false)
end

function DEFAULT_SETTING_SCREEN:SetSetting(setting, is_server_setting)
	local type_id = setting.type.id
	local panel_id = type_panel_ids[type_id] or "pacoman_type_any"

	if self.pnl_setting_value then
		self.pnl_setting_value:Remove()
	end

	if setting then
		self.setting = setting
		self.is_server_setting = is_server_setting

		self.pnl_setting_value = vgui.Create(panel_id, self)
		self.pnl_setting_value:SetPos(self.setting_pos_x + self.setting_width * 0.25 + 4, HEADER_HEIGHT * 2)
		self.pnl_setting_value:SetSize(self.setting_width * 0.75 - 4, HEADER_HEIGHT)
		self.pnl_setting_value:SetSettingPanel(self)

		self.cb_setting_dependency:SetDisabled(false)
		local depends_on = self.setting.depends_on

		if depends_on then
			self.cb_setting_dependency:ChooseOptionID(pacoman.game_property_indices[depends_on.id] + 1)
		else
			self.cb_setting_dependency:ChooseOptionID(1)
		end

		self.cb_setting_dependency:SetText(setting.depends_on and setting.depends_on.id or "Nothing")
		self.lbl_setting_id:SetText(setting.id)
		return
	end
	self.setting = nil
	self.is_server_setting = false
	self.cb_setting_dependency:ChooseOptionID(1)
	self.cb_setting_dependency:SetDisabled(true)
	self.cb_setting_dependency:SetText("Nothing")
	self.lbl_setting_id:SetText("")
end

function DEFAULT_SETTING_SCREEN:AttemptDependencyChange(game_property)
	if not self.setting or self.setting.depends_on == game_property then return end

	if self.is_server_setting then
		pacoman.RequestDependencyChange(self.setting, game_property)
		return
	end

	if game_property then
		self.setting:MakeDependent(game_property)
	else
		self.setting:MakeIndependent()
	end
end

function DEFAULT_SETTING_SCREEN:AttemptValueChange()
	if not self.setting then return end

	local value = self.pnl_setting_value:GetValue()
	if value == nil then
		self.pnl_setting_value:SetValue(self.setting.value)
		return
	end

	if self.is_server_setting then
		pacoman.RequestValueChange(self.setting, value)
		return
	end

	self.setting:SetValue(value)
end

derma.DefineControl("pacoman_default_setting_screen", "", DEFAULT_SETTING_SCREEN, "DFrame")

--toggle menu visibility
concommand.Add("pacoman_toggle_menu", function(player, cmd, args, arg_str)
	if pacoman_ui then
		pacoman_ui:SetVisible(not pacoman_ui:IsVisible())
		return
	end
	pacoman_ui = vgui.Create("pacoman_default_setting_screen")
end)
