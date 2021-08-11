-- colors
local col_base = {r = 40, g = 40, b = 40, a = 255}
local col_base_darker = {r = 30, g = 30, b = 30, a = 255}
local col_base_darkest = {r = 20, g = 20, b = 20, a = 255}
local col_text = {r = 200, g = 200, b = 200, a = 255}

local TITLE_BAR_HEIGHT = 25
local HEADER_HEIGHT = 25
local INDENTATION = 15
local TREE_WIDTH = 300

local pacoman_ui = nil

surface.CreateFont("PACOMAN_default_font", {
	font = "Trebuchet MS",
	size = 25
})

local PANEL_LIST = {}

function PANEL_LIST:Init()
	self:SetBackgroundColor(col_base)
end

function PANEL_LIST:Paint(w, h)
	surface.SetDrawColor(col_base)
	surface.DrawRect(0, 0, w, h)
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
		surface.SetDrawColor(col_base_darkest)
		surface.DrawRect(0, 0, w - 1, h - 2)
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

local all_nodes = {}

local function AddSettingPanel(parent_panel, setting, on_selected)
	local setting_panel = vgui.Create("pacoman_tree_node", parent_panel)
	setting_panel.OnClicked = on_selected
	setting_panel.header:SetText(setting.id)
	setting_panel.header.DoClick = function(self)
		setting_panel:OnClicked()
	end
	setting_panel.setting = setting

	all_nodes[setting.full_id] = setting_panel
	for i = 1, #setting.sources do
		AddSettingPanel(setting_panel.children, setting.sources[i], on_selected)
	end

	return setting_panel
end

local function AddNamespacePanel(parent_panel, namespace, on_selected)
	local namespace_panel = vgui.Create("pacoman_tree_node", parent_panel)
	namespace_panel.header:SetText(namespace.id)

	namespace_panel.namespace = namespace
	all_nodes[namespace.full_id] = namespace_panel
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

	self:SetSize(width, height)
	self:SetPos((ScrW() - width) * 0.5, (ScrH() - height) * 0.5)
	self:SetZPos(-100)
	self:SetTitle("Partly Adequate Configuration Manager")
	self:SetDeleteOnClose(false)

	self.Paint = function(s, w, h)
		surface.SetDrawColor(col_base_darkest)
		surface.DrawRect(0, 0, w, TITLE_BAR_HEIGHT)
		surface.SetDrawColor(col_base)
		surface.DrawRect(0, TITLE_BAR_HEIGHT, w, h - TITLE_BAR_HEIGHT)
	end

	self.setting = nil
	self.is_server_setting = false

	local setting_pos_x = TREE_WIDTH
	local setting_width = width - TREE_WIDTH

	self.lbl_setting_name = vgui.Create("DLabel", self)
	self.lbl_setting_name:SetPos(setting_pos_x, HEADER_HEIGHT)
	self.lbl_setting_name:SetSize(setting_width, HEADER_HEIGHT)
	self.lbl_setting_name:SetContentAlignment(5)
	self.lbl_setting_name:SetText("")
	self.lbl_setting_name:SetTextColor(col_text)
	self.lbl_setting_name.Paint = function(s, w, h)
		surface.SetDrawColor(col_base_darkest)
		surface.DrawRect(0, 0, w, h)
	end

	local lbl_setting_dependency = vgui.Create("DLabel", self)
	lbl_setting_dependency:SetPos(setting_pos_x, HEADER_HEIGHT * 2)
	lbl_setting_dependency:SetSize(setting_width * 0.25, HEADER_HEIGHT)
	lbl_setting_dependency:SetText("Depends on: ")
	lbl_setting_dependency:SetTextColor(col_text)

	self.cb_setting_dependency = vgui.Create("DComboBox", self)
	self.cb_setting_dependency:SetPos(setting_pos_x + setting_width * 0.25, HEADER_HEIGHT * 2)
	self.cb_setting_dependency:SetSize(setting_width * 0.75, HEADER_HEIGHT)
	self.cb_setting_dependency:SetText("Nothing")

	local lbl_setting_value = vgui.Create("DLabel", self)
	lbl_setting_value:SetPos(setting_pos_x, HEADER_HEIGHT * 3)
	lbl_setting_value:SetSize(setting_width * 0.25, HEADER_HEIGHT)
	lbl_setting_value:SetText("Value: ")
	lbl_setting_value:SetTextColor(col_text)

	self.txt_setting_value = vgui.Create("DTextEntry", self)
	self.txt_setting_value:SetText("")
	self.txt_setting_value:SetPos(setting_pos_x + setting_width * 0.25, HEADER_HEIGHT * 3)
	self.txt_setting_value:SetSize(setting_width * 0.75, HEADER_HEIGHT)
	self.txt_setting_value:SetTextColor(col_text)
	self.txt_setting_value:SetPaintBackground(false)
	self.txt_setting_value.OnGetFocus = function(s)
		self:SetKeyboardInputEnabled(true)
	end
	self.txt_setting_value.OnLoseFocus = function(s)
		self:SetKeyboardInputEnabled(false)
	end
	self.txt_setting_value.OnEnter = function(s, serialized_value)
		local value = self.setting.type:Deserialize(serialized_value)

		self:AttemptValueChange(value)
	end

	local tree_container = vgui.Create("DScrollPanel", self)
	tree_container:SetPos(0, TITLE_BAR_HEIGHT)
	tree_container:SetSize(TREE_WIDTH, height - TITLE_BAR_HEIGHT)
	tree_container.Paint = function(s, w, h)
		surface.SetDrawColor(col_base_darker)
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
	if setting then
		self.setting = setting
		self.is_server_setting = is_server_setting
		self.cb_setting_dependency:SetDisabled(false)
		self.cb_setting_dependency:SetText(setting.depends_on and setting.depends_on.id or "Nothing")
		self.lbl_setting_name:SetText(setting.full_id)
		self.txt_setting_value:SetText(setting.type:Serialize(setting.value))
		return
	end
	self.setting = nil
	self.is_server_setting = false
	self.cb_setting_dependency:SetDisabled(true)
	self.cb_setting_dependency:SetText("Nothing")
	self.lbl_setting_name:SetText("")
	self.txt_setting_value:SetText("")
end

function DEFAULT_SETTING_SCREEN:AttemptValueChange(value)
	if value == nil then
		self.txt_setting_value:SetText(self.setting.type:Serialize(self.setting.value))
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
