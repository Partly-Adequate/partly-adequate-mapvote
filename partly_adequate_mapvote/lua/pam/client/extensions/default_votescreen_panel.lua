local PANEL = {}

local scale = 1

local cv_scale = GetConVar("pam_votescreen_scale")
if cv_scale then
	scale = cv_scale:GetInt() / 100
end

-- alignment helping values
local option_button_size = math.floor(150 * scale)
local option_image_size = math.floor(100 * scale)
local option_button_label_size = math.floor(25 * scale)
local avatar_size = option_button_label_size - 6
local scroll_bar_size = 14
local settings_height = math.floor(25 * scale)
local avatars_per_row = math.floor(option_image_size / option_button_label_size)
local avatar_space = option_image_size / avatars_per_row

-- colors
local col_base = {r = 40, g = 40, b = 40, a = 255}
local col_base_darker = {r = 30, g = 30, b = 30, a = 255}
local col_base_darkest = {r = 20, g = 20, b = 20, a = 255}
local col_text = {r = 150, g = 150, b = 150, a = 255}

-- images and icons
local ic_favorite = Material("vgui/pam/ic_favorite")
local ic_not_favorite = Material("vgui/pam/ic_not_favorite")
local ic_voted_on = Material("vgui/pam/ic_selected")
local ic_not_voted_on = Material("vgui/pam/ic_not_selected")

local mat_missing_option = Material("vgui/pam/img_missing")

surface.CreateFont("PAM_NameFont", {
	font = "Trebuchet MS",
	size = option_button_label_size - 6
})

surface.CreateFont("PAM_PickCountFont", {
	font = "Trebuchet MS",
	size = option_button_label_size - 10
})

surface.CreateFont("PAM_CountdownFont", {
	font = "Trebuchet MS",
	size = settings_height - 2
})

surface.CreateFont("PAM_SettingsFont", {
	font = "Trebuchet MS",
	size = settings_height - 8
})

function PANEL:Init()
	local width = ScrW() * 0.5
	local height = ScrH() * 0.75
	-- adjust width to button width + scrollbar
	width = width + (option_button_size - (width % option_button_size)) + scroll_bar_size;
	self:SetSize(width, height)
	self:SetPos((ScrW() - width) * 0.5, (ScrH() - height) * 0.5)
	self:SetZPos(-100)
	self:SetTitle("Partly Adequate Mapvote")
	self:SetDeleteOnClose(false)

	self.Paint = function(s, w, h)
		surface.SetDrawColor(col_base_darkest)
		surface.DrawRect(0, 0, w, 25)
		surface.SetDrawColor(col_base)
		surface.DrawRect(0, 25, w, h - 25)
	end

	self.search_term = ""
	self.show_favorites = false
	self.show_voted_on = false
	self.voters = {}
	self.option_buttons = {}

	local container = vgui.Create("DPanel", self)
	container:SetSize(width, height - 25)
	container:SetPos(0, 25)
	container.Paint = function(s, w, h) end

	self:InitSettings(container, 0, 0, width, settings_height * 3)
	self:InitOptionList(container, 0, settings_height * 3, width, height - 25 - settings_height * 3)

	self:MakePopup()
	self:SetKeyboardInputEnabled(false)
end

function PANEL:InitSettings(parent, pos_x, pos_y, width, height)
	local pnl_vote_settings = vgui.Create("Panel", parent)
	pnl_vote_settings:SetSize(width, height)
	pnl_vote_settings:SetPos(pos_x, pos_y)
	pnl_vote_settings.Paint = function(s, w, h) end

	self:InitCountDown(pnl_vote_settings, 0, 0, width, settings_height)
	self:InitSearchArea(pnl_vote_settings, 0, settings_height, width / 2, settings_height)
	self:InitFavorites(pnl_vote_settings, width / 2, settings_height, width / 2, settings_height)
	self:InitVotedOn(pnl_vote_settings, width / 2, 2 * settings_height, width / 2, settings_height)
	self:InitSortBox(pnl_vote_settings, 0, 2 * settings_height, width / 2, settings_height)
end

function PANEL:InitCountDown(parent, pos_x, pos_y, width, height)
	local lbl_countdown = vgui.Create("DLabel", parent)
	lbl_countdown:SetFont("PAM_CountdownFont")
	lbl_countdown:SetTextColor(col_text)
	lbl_countdown:SetContentAlignment(5)
	lbl_countdown:SetSize(width, height)
	lbl_countdown:SetPos(pos_x, pos_y)
	lbl_countdown.Paint = function(s, w, h)
		surface.SetDrawColor(col_base_darkest)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(col_base)
		surface.DrawRect(2, 2, w - 4, h - 4)
	end
	lbl_countdown.Think = function()
		local time_left = math.Round(math.max(PAM.ends_at - CurTime(), 0))
		lbl_countdown:SetText(time_left .. " seconds left!")
	end
end

function PANEL:InitSearchArea(parent, pos_x, pos_y, width, height)
	local pnl_container = vgui.Create("DPanel", parent)
	pnl_container:SetSize(width, height)
	pnl_container:SetPos(pos_x, pos_y)
	pnl_container.Paint = function(s, w, h)
		surface.SetDrawColor(col_base_darkest)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(col_base)
		surface.DrawRect(2, 2, w - 4, h - 4)
	end

	local txt_search = vgui.Create("DTextEntry", pnl_container)
	txt_search:SetPlaceholderText("Search for options...")
	txt_search:SetFont("PAM_SettingsFont")
	txt_search.OnChange = function()
		self.search_term = txt_search:GetValue()
		self:RefreshOptionList()
	end
	txt_search.OnGetFocus = function()
		self:SetKeyboardInputEnabled(true)
	end
	txt_search.OnLoseFocus = function()
		self:SetKeyboardInputEnabled(false)
	end
	txt_search:SetSize(width, height)
	txt_search:SetPos(0, 0)
	txt_search:SetPaintBackground(false)
	txt_search:SetTextColor(col_text)
	txt_search:SetCursorColor(col_text)
	txt_search:SetPlaceholderColor(col_text)
end

function PANEL:InitSortBox(parent, pos_x, pos_y, width, height)
	local function CompareStrings(string_1, string_2)
		string_1 = string.lower(string_1)
		string_2 = string.lower(string_2)

		for i = 1, math.min(#string_1, #string_2) do
			byte_1 = string.byte(string_1:sub(i, i))
			byte_2 = string.byte(string_2:sub(i, i))
			if byte_1 < byte_2 then
				return true
			elseif byte_1 > byte_2 then
				return false
			end
		end
		return #string_1 < #string_2
	end

	local cb_sort_by = vgui.Create("DComboBox", parent)
	cb_sort_by:SetValue("Sort by...")
	cb_sort_by:SetSize(width, height)
	cb_sort_by:SetPos(pos_x, pos_y)
	cb_sort_by.Paint = function(s, w, h)
		surface.SetDrawColor(col_base_darkest)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(col_base)
		surface.DrawRect(2, 2, w - 4, h - 4)
	end
	cb_sort_by:SetTextColor(col_text)
	cb_sort_by:SetFont("PAM_SettingsFont")

	cb_sort_by:AddChoice("Name [a-z]", function(option_button_1, option_button_2)
		return CompareStrings(option_button_1.option.name, option_button_2.option.name)
	end)
	cb_sort_by:AddChoice("Name [z-a]", function(option_button_1, option_button_2)
		return not CompareStrings(option_button_1.option.name, option_button_2.option.name)
	end)
	cb_sort_by:AddChoice("Least picked", function(option_button_1, option_button_2)
		if not option_button_1 or not option_button_2 then
			return true
		end
		return option_button_1.option.pick_count < option_button_2.option.pick_count
	end)
	cb_sort_by:AddChoice("Most picked", function(option_button_1, option_button_2)
		if not option_button_1 or not option_button_2 then
			return true
		end
		return option_button_1.option.pick_count > option_button_2.option.pick_count
	end)

	cb_sort_by.OnSelect = function(cb, index, text)
		local _, comparator = cb:GetSelected()
		self:SortOptionList(comparator)
	end
end

function PANEL:InitFavorites(parent, pos_x, pos_y, width, height)
	local btn_toggle_favorites = vgui.Create("DButton", parent)
	btn_toggle_favorites:SetText("Show favorites")
	btn_toggle_favorites:SetSize(width, height)
	btn_toggle_favorites:SetPos(pos_x, pos_y)
	btn_toggle_favorites:SetTextColor(col_text)
	btn_toggle_favorites:SetFont("PAM_SettingsFont")
	btn_toggle_favorites.Paint = function(s, w, h)
		surface.SetDrawColor(col_base_darkest)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(col_base)
		surface.DrawRect(2, 2, w - 4, h - 4)
	end

	local icon = vgui.Create("DImage", btn_toggle_favorites)
	icon:SetPos(0, 0)
	icon:SetSize(settings_height, settings_height)
	icon:SetMaterial(ic_not_favorite)

	btn_toggle_favorites.DoClick = function()
		self.show_favorites = not self.show_favorites
		if self.show_favorites then
			icon:SetMaterial(ic_favorite)
		else
			icon:SetMaterial(ic_not_favorite)
		end
		self:RefreshOptionList()
	end
end

function PANEL:InitVotedOn(parent, pos_x, pos_y, width, height)
	local btn_toggle_voted_on = vgui.Create("DButton", parent)
	btn_toggle_voted_on:SetText("Show options being voted on")
	btn_toggle_voted_on:SetSize(width, height)
	btn_toggle_voted_on:SetPos(pos_x, pos_y)
	btn_toggle_voted_on:SetTextColor(col_text)
	btn_toggle_voted_on:SetFont("PAM_SettingsFont")
	btn_toggle_voted_on.Paint = function(s, w, h)
		surface.SetDrawColor(col_base_darkest)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(col_base)
		surface.DrawRect(2, 2, w - 4, h - 4)
	end

	local icon = vgui.Create("DImage", btn_toggle_voted_on)
	icon:SetPos(0, 0)
	icon:SetSize(settings_height, settings_height)
	icon:SetMaterial(ic_not_voted_on)

	btn_toggle_voted_on.DoClick = function()
		self.show_voted_on = not self.show_voted_on
		if self.show_voted_on then
			icon:SetMaterial(ic_voted_on)
		else
			icon:SetMaterial(ic_not_voted_on)
		end
		self:RefreshOptionList()
	end
end

function PANEL:InitOptionList(parent, pos_x, pos_y, width, height)
	local pnl_container = vgui.Create("DPanel", parent)
	pnl_container:SetSize(width, height)
	pnl_container:SetPos(pos_x, pos_y)

	pnl_container.Paint = function(s, w, h)
		surface.SetDrawColor(col_base_darker)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(col_base_darkest)
		surface.DrawRect(w - scroll_bar_size, 0, scroll_bar_size, h)
	end

	self.option_list = vgui.Create("DPanelList", pnl_container)
	self.option_list:SetSize(width, height)
	self.option_list:SetPos(0, 0)
	self.option_list:EnableHorizontal(true)
	self.option_list:EnableVerticalScrollbar()
	self:InitOptionButtons()
	self:RefreshOptionList()
end

function PANEL:AddVoter(ply, option_id)
	for _, voter in pairs(self.voters) do
		if voter.player == ply then
			self:UpdateVoters()
			return false
		end
	end

	local new_voter = vgui.Create("DPanel")
	new_voter.player = ply
	new_voter:SetSize(option_button_label_size, option_button_label_size)
	new_voter:SetTooltip(ply:Name())
	new_voter.Paint = function(s, w, h)
		surface.SetDrawColor(col_base_darkest)
		surface.DrawRect(1, 1, option_button_label_size - 2, option_button_label_size - 2)
	end

	local icon = vgui.Create("AvatarImage", new_voter)
	icon:SetSize(avatar_size, avatar_size)
	icon:SetPos(3, 3)
	icon:SetPlayer(ply, 32)
	icon:SetTooltip(ply:Name())

	table.insert(self.voters, new_voter)
	self:UpdateVoters()
end

function PANEL:RemoveVoter(ply)
	for _, voter in pairs(self.voters) do
		if(voter.player.SteamID() == ply.SteamID()) then
			table.RemoveByValue(self.voters, voter)
			voter:Remove()
			self:UpdateVoters()
			return
		end
	end
end

function PANEL:UpdateVoters()
	for _, option_button in pairs(self.option_buttons) do
		option_button.voter_count = 0
	end

	for _, voter in pairs(self.voters) do
		if not IsValid(voter.player) then
			voter:Remove()
		else
			if not PAM.votes[voter.player:SteamID()] then
				voter:Remove()
			else
				local option_button = self:GetOptionButton(PAM.votes[voter.player:SteamID()])

				if IsValid(option_button) then
					voter:SetParent(option_button)
					local row = math.floor(option_button.voter_count / avatars_per_row)
					local newY = 0
					local newX = 0

					if row < 2 then
						newY = option_button_label_size + avatar_space * (option_button.voter_count % avatars_per_row)
						newX = (option_image_size + avatar_space) * row
					else
						newX = option_button_label_size + avatar_space * (option_button.voter_count % avatars_per_row)
						newY = option_button_label_size + avatar_space * (row - 2)
					end

					voter:SetPos(newX, newY)
					option_button.voter_count = option_button.voter_count + 1
				end
			end
		end
	end
	self:RefreshOptionList()
end

function PANEL:FitsSearchTerm(button)
	local search_term = self.search_term

	if not search_term or search_term == "" then return true end
	if #search_term > #button.option.name then return false end

	local i = 1
	for j = 1, #button.option.name do
		if button.option.name:sub(j, j):lower() == search_term:sub(i, i):lower() then
			if i >= #search_term then
				return true
			end
			i = i + 1
		end
	end

	return false
end

function PANEL:SortOptionList(comparator)
	table.sort(self.option_buttons, comparator)
	self:RefreshOptionList()
end

function PANEL:RefreshOptionList()
	self.option_list:Clear()
	for _, option_button in pairs(self.option_buttons) do
		if (not PAM.winning_option_id and self:FitsSearchTerm(option_button) and (not self.show_favorites or PAM.IsFavorite(option_button.option.name)) and (not self.show_voted_on or option_button.voter_count > 0)) or PAM.winning_option_id == option_button.option.id then
			self.option_list:AddItem(option_button)
			option_button:SetVisible(true)
		else
			option_button:SetVisible(false)
		end
	end
end

function PANEL:InitOptionButtons()
	for i = 1, #PAM.options do
		local optioninfo = PAM.options[i]
		local option_button = vgui.Create("DButton")
		option_button:SetSize(option_button_size, option_button_size)
		option_button:SetText("")
		option_button:SetPaintBackground(false)
		option_button.voter_count = 0
		option_button.option = optioninfo
		option_button.DoClick = function()
			PAM.Vote(option_button.option.id)
		end

		-- option thumbnail
		local option_image = vgui.Create("DImage", option_button)

		local mat_option_icon = PAM.extension_handler.GetIconMaterial(option_button.option)
		if mat_option_icon then
			option_image:SetMaterial(mat_option_icon)
		else
			option_image:SetMaterial(mat_missing_option)
		end

		option_image:SetSize(option_image_size, option_image_size)
		option_image:SetPos(option_button_label_size, option_button_label_size)

		local image_border = vgui.Create("DPanel", option_image)
		image_border:SetSize(option_image_size, option_image_size)
		image_border.Paint = function(s, w, h)
			surface.SetDrawColor(col_base_darkest)
			surface.DrawOutlinedRect(0, 0, option_image_size, option_image_size)
		end

		-- option-name label
		local lbl_option_name = vgui.Create("DLabel", option_button)
		lbl_option_name:SetPos(0, 0)
		lbl_option_name:SetSize(option_button_size, option_button_label_size)
		lbl_option_name:SetContentAlignment(5)
		lbl_option_name:SetText(optioninfo.name)
		lbl_option_name:SetTextColor(col_text)
		lbl_option_name:SetFont("PAM_NameFont")

		-- pick-count label
		local lbl_pick_count = vgui.Create("DLabel", option_button)
		lbl_pick_count:SetPos(0, option_button_size - option_button_label_size)
		lbl_pick_count:SetSize(option_button_size, option_button_label_size)
		lbl_pick_count:SetContentAlignment(5)
		lbl_pick_count:SetTextColor(col_text)
		lbl_pick_count:SetFont("PAM_PickCountFont")
		if optioninfo.pick_count == 0 then
			lbl_pick_count:SetText("Not picked yet")
		elseif optioninfo.pick_count == 1 then
			lbl_pick_count:SetText("Picked once")
		else
			lbl_pick_count:SetText("Picked " .. optioninfo.pick_count .. " times")
		end

		-- heart for favorites
		local ibtn_favorite = vgui.Create("DImageButton", option_button)
		if PAM.IsFavorite(option_button.option.name) then
			ibtn_favorite:SetMaterial(ic_favorite)
			option_button.is_favorite = true
		else
			ibtn_favorite:SetMaterial(ic_not_favorite)
			option_button.is_favorite = false
		end
		ibtn_favorite:SetSize(option_button_label_size, option_button_label_size)
		ibtn_favorite:SetPos(option_button_size - option_button_label_size, option_button_size - option_button_label_size)
		ibtn_favorite.DoClick = function()
			if PAM.IsFavorite(option_button.option.name) then
				PAM.RemoveFromFavorites(option_button.option.name)
				ibtn_favorite:SetMaterial(ic_not_favorite)
			else
				PAM.AddToFavorites(option_button.option.name)
				ibtn_favorite:SetMaterial(ic_favorite)
			end
			self:RefreshOptionList()
		end

		-- override default texture
		option_button.Paint = function(s, w, h)
			surface.SetDrawColor(col_base)
			surface.DrawRect(0, 0, option_button_size, option_button_size);
			surface.SetDrawColor(col_base_darkest)
			surface.DrawRect(0, 0, option_button_size, option_button_label_size);

			surface.DrawOutlinedRect(0, 0, option_button_size, option_button_size);
			surface.DrawOutlinedRect(option_button_label_size - 1, option_button_label_size - 1, option_image_size + 2, option_image_size + 2)
			surface.DrawLine(0, option_button_label_size, option_button_size, option_button_label_size);
			surface.DrawLine(0, option_button_label_size - 1, option_button_size, option_button_label_size - 1);
		end

		table.insert(self.option_buttons, option_button)
	end
end

function PANEL:GetOptionButton(id)
	for _, button in pairs(self.option_buttons) do
		if button.option.id == id then
			return button
		end
	end
	return false
end

function PANEL:AnnounceWinner()
	self:SetVisible(true)
	self:RefreshOptionList()
end

derma.DefineControl("pam_default_votescreen", "", PANEL, "DFrame")
