local PANEL = {}

local button_height = 25
local button_width = 500
local menu_bar_height = 25
local scroll_bar_width = 14

local ic_selected = Material("vgui/pam/ic_selected")
local ic_not_selected = Material("vgui/pam/ic_not_selected")

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
	self:SetTitle("PAM Extension Manager")
	self.Paint = function(s, w, h)
		surface.SetDrawColor(col_base_darker)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(col_base_darkest)
		surface.DrawRect(0, 0, w, menu_bar_height)
	end

	local lbl_info = vgui.Create("DLabel", self)
	lbl_info:SetSize(width, button_height)
	lbl_info:SetPos(0, menu_bar_height)
	lbl_info:SetTextColor(col_text)
	lbl_info:SetContentAlignment(5)
	lbl_info:SetText("Click to activate/deactivate extensions!")
	lbl_info.Paint = function(s, w, h)
		surface.SetDrawColor(col_base_darkest)
		surface.DrawRect(0, 0, width, button_height)
		surface.SetDrawColor(col_base)
		surface.DrawRect(2, 2, width - 4, button_height - 4)
	end

	local sp_container = vgui.Create("DScrollPanel", self)
	sp_container:SetSize(width, height - menu_bar_height - button_height)
	sp_container:SetPos(0, menu_bar_height + button_height)
	sp_container.Paint = function(s, w, h)
		surface.SetDrawColor(col_base_darker)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(col_base_darkest)
		surface.DrawRect(w - scroll_bar_width, 0, scroll_bar_width, h)
	end

	local ilo_buttons = vgui.Create("DIconLayout", sp_container)
	ilo_buttons:SetSize(width - scroll_bar_width, height - menu_bar_height - button_height)
	ilo_buttons:SetPos(0, 0)

	for _, extension in pairs(PAM.extensions) do
		local btn_extension = ilo_buttons:Add("DButton")
		btn_extension:SetSize(button_width, button_height)
		btn_extension.Paint = function(s, w, h)
			surface.SetDrawColor(col_base_darkest)
			surface.DrawRect(0, 0, button_width, button_height)
			surface.SetDrawColor(col_base)
			surface.DrawRect(2, 2, button_width - 4, button_height - 4)
		end
		btn_extension:SetTextColor(col_text)
		btn_extension:SetText(extension.name)
		btn_extension:SetContentAlignment(5)

		btn_extension.extension = extension

		local ic_is_selected = vgui.Create("DImage", btn_extension)
		ic_is_selected:SetSize(button_height, button_height)
		ic_is_selected:SetPos(0, 0)

		if extension.is_enabled then
			ic_is_selected:SetMaterial(ic_selected)
		else
			ic_is_selected:SetMaterial(ic_not_selected)
		end

		btn_extension.DoClick = function()
			local extension = btn_extension.extension
			if extension.is_enabled then
				PAM.DisableExtension(extension)
				ic_is_selected:SetMaterial(ic_not_selected)
			else
				PAM.EnableExtension(extension)
				ic_is_selected:SetMaterial(ic_selected)
			end
		end
	end

	self:MakePopup()
	self:SetKeyboardInputEnabled(false)
end

derma.DefineControl("pam_extension_manager", "", PANEL, "DFrame")
