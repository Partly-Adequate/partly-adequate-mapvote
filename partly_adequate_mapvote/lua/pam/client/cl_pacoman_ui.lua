-- colors
local col_base = {r = 40, g = 40, b = 40, a = 255}
local col_base_darker = {r = 30, g = 30, b = 30, a = 255}
local col_base_darkest = {r = 20, g = 20, b = 20, a = 255}
local col_text = {r = 150, g = 150, b = 150, a = 255}

local PANEL = {}

surface.CreateFont("PACOMAN_default_font", {
	font = "Trebuchet MS",
	size = 25
})

local function AddSetting(parent_node, setting)
	local node = parent_node:AddNode(setting.id)
end

local function AddNamespace(parent_node, namespace)
	local node = parent_node:AddNode(namespace.id)
	for i = 1, #namespace.children do
		AddNamespace(node, namespace.children[i])
	end
	for i = 1, #namespace.settings do
		AddSetting(node, namespace.settings[i])
	end
end

function PANEL:Init()
	local width = ScrW() * 0.5
	local height = ScrH() * 0.75

	self:SetSize(width, height)
	self:SetPos((ScrW() - width) * 0.5, (ScrH() - height) * 0.5)
	self:SetZPos(-100)
	self:SetTitle("Partly Adequate Configuration Manager")
	self:SetDeleteOnClose(true)

	self.Paint = function(s, w, h)
		surface.SetDrawColor(col_base_darkest)
		surface.DrawRect(0, 0, w, 25)
		surface.SetDrawColor(col_base)
		surface.DrawRect(0, 25, w, h - 25)
	end

	local tree = vgui.Create("DTree", self)
	tree:SetPos(0, 25)
	tree:SetSize(width / 2, height - 25)

	AddNamespace(tree, pacoman.client_settings)
	AddNamespace(tree, pacoman.server_settings)
	AddNamespace(tree, pacoman.client_overrides)

	self:MakePopup()
	self:SetKeyboardInputEnabled(false)
end

derma.DefineControl("pacoman_default_setting_screen", "", PANEL, "DFrame")

local panel = nil

--toggle menu visibility
concommand.Add("pacoman_toggle_menu", function(player, cmd, args, arg_str)
	if panel and IsValid(panel) then
		panel:Close()
		return
	end
	panel = vgui.Create("pacoman_default_setting_screen")
end)
