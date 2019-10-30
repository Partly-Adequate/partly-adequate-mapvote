local vote_menus = {}
local vote_menu_count = 0

local PANEL = {}

local button_height = 25
local button_width = 500
local menu_bar_height = 25
local scroll_bar_width = 14

local ic_selected = Material("vgui/ttt/pam/ic_voted")
local ic_not_selected = Material("vgui/ttt/pam/ic_not_voted")

local col_base = {r = 40, g = 40, b = 40, a = 255}
local col_base_darker = {r = 30, g = 30, b = 30, a = 255}
local col_base_darkest = {r = 20, g = 20, b = 20, a = 255}
local col_text = {r = 150, g = 150, b = 150, a = 255}

function PANEL:Init()
	local width = 500 + scroll_bar_width
	local height = ScrH() * 0.75
	self:SetSize(width, height)
	self:SetPos((ScrW() - width) / 2, (ScrH() - height) / 2)
	self:SetZPos(-100)
	self:SetTitle("PAM Menu Selection")
	self.Paint = function(s, w, h)
		surface.SetDrawColor(col_base_darker)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(col_base_darkest)
		surface.DrawRect(0, 0, w, menu_bar_height)
	end

	local sp_container = vgui.Create("DScrollPanel", self)
	sp_container:SetSize(width, height - menu_bar_height)
	sp_container:SetPos(0, menu_bar_height)

	local ilo_buttons = vgui.Create("DIconLayout", sp_container)
	ilo_buttons:SetSize(width - scroll_bar_width, height - menu_bar_height)
	ilo_buttons:SetPos(0, 0)

	for _, vote_menu in pairs(vote_menus) do
		local menu_button = ilo_buttons:Add("DButton")
		menu_button:SetSize(button_width, button_height)
		menu_button.Paint = function(s, w, h)
			surface.SetDrawColor(col_base_darkest)
			surface.DrawRect(0, 0, button_width, button_height)
			surface.SetDrawColor(col_base_darker)
			surface.DrawRect(2, 2, button_width - 4, button_height - 4)
		end
		menu_button:SetText(vote_menu.name)
		menu_button:SetContentAlignment(5)

		menu_button.vote_menu = vote_menu

		local ic_is_selected = vgui.Create("DImage", menu_button)
		ic_is_selected:SetSize(button_height, button_height)
		ic_is_selected:SetPos(0, 0)

		ic_is_selected:SetMaterial(ic_not_selected)

		menu_button.DoClick = function()
			PAM.EnableMenu(menu_button.vote_menu)
		end

		-- TODO find better way to show icons
		menu_button.Think = function()
			if PAM.vote_menu.id == menu_button.vote_menu.id then
				ic_is_selected:SetMaterial(ic_selected)
			else
				ic_is_selected:SetMaterial(ic_not_selected)
			end
		end
	end

	self:MakePopup()
	self:SetKeyboardInputEnabled(false)
end

derma.DefineControl("pam_menu_selection", "", PANEL, "DFrame")

function PAM.RegisterMenu(name, vote_menu)
	print('[PAM] Registering votescreen "' .. name .. '"')
	vote_menu_count = vote_menu_count + 1
	vote_menu.name = name
	vote_menu.id = vote_menu_count
	vote_menus[vote_menu_count] = vote_menu
end

function PAM.EnableMenu(to_enable)
	if PAM.state == PAM.STATE_DISABLED and IsValid(to_enable) then
		if IsValid(PAM.menu) then
			PAM.menu.OnDisable()
		end
		PAM.menu = to_enable
		PAM.menu.OnEnable()
	end
end

hook.Add("Initialize", "PAM_GuiManager", function()
	hook.Run("PAM_Register_Menus")
	PAM.EnableMenu(vote_menus[1])
end)
