local PANEL = {}

-- alignment helping values
local map_button_size = 150
local map_image_size = map_button_size - 50
local map_button_label_size = (map_button_size - map_image_size) / 2
local avatar_size = map_button_label_size - 6
local scroll_bar_size = 14
local settings_height = 25
local avatars_per_row = math.floor(map_image_size / map_button_label_size)
local avatar_space = map_image_size / avatars_per_row

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

local mat_missing_map = Material("vgui/pam/img_missing")

surface.CreateFont("PAM_NameFont", {
	font = "Trebuchet MS",
	size = map_button_label_size * 0.75
})

surface.CreateFont("PAM_PlaycountFont", {
	font = "Trebuchet MS",
	size = map_button_label_size * 0.5
})

surface.CreateFont("PAM_CountdownFont", {
	font = "Trebuchet MS",
	size = settings_height - 1
})

surface.CreateFont("PAM_SettingsFont", {
	font = "Trebuchet MS",
	size = settings_height * 0.66
})

function PANEL:Init()
	local width = ScrW() * 0.5
	local height = ScrH() * 0.75
	-- adjust width to button width + scrollbar
	width = width + (map_button_size - (width % map_button_size)) + scroll_bar_size;
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
	self.map_buttons = {}

	local container = vgui.Create("DPanel", self)
	container:SetSize(width, height - 25)
	container:SetPos(0, 25)
	container.Paint = function(s, w, h) end

	self:InitSettings(container, 0, 0, width, settings_height * 3)
	self:InitMapList(container, 0, settings_height * 3, width, height - 25 - settings_height * 3)

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
	txt_search:SetPlaceholderText("Search for maps...")
	txt_search:SetFont("PAM_SettingsFont")
	txt_search.OnChange = function()
		self.search_term = txt_search:GetValue()
		self:RefreshMapList()
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

	cb_sort_by:AddChoice("Name [a-z]", function(map_button_1, map_button_2)
		return CompareStrings(map_button_1.map.name, map_button_2.map.name)
	end)
	cb_sort_by:AddChoice("Name [z-a]", function(map_button_1, map_button_2)
		return not CompareStrings(map_button_1.map.name, map_button_2.map.name)
	end)
	cb_sort_by:AddChoice("Least played", function(map_button_1, map_button_2)
		if not map_button_1 or not map_button_2 then
			return true
		end
		return map_button_1.map.playcount < map_button_2.map.playcount
	end)
	cb_sort_by:AddChoice("Most played", function(map_button_1, map_button_2)
		if not map_button_1 or not map_button_2 then
			return true
		end
		return map_button_1.map.playcount > map_button_2.map.playcount
	end)

	cb_sort_by.OnSelect = function(cb, index, text)
		local _, comparator = cb:GetSelected()
		self:SortMapList(comparator)
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
		self:RefreshMapList()
	end
end

function PANEL:InitVotedOn(parent, pos_x, pos_y, width, height)
	local btn_toggle_voted_on = vgui.Create("DButton", parent)
	btn_toggle_voted_on:SetText("Show maps being voted on")
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
		self:RefreshMapList()
	end
end

function PANEL:InitMapList(parent, pos_x, pos_y, width, height)
	local pnl_container = vgui.Create("DPanel", parent)
	pnl_container:SetSize(width, height)
	pnl_container:SetPos(pos_x, pos_y)

	pnl_container.Paint = function(s, w, h)
		surface.SetDrawColor(col_base_darker)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(col_base_darkest)
		surface.DrawRect(w - scroll_bar_size, 0, scroll_bar_size, h)
	end

	self.map_list = vgui.Create("DPanelList", pnl_container)
	self.map_list:SetSize(width, height)
	self.map_list:SetPos(0, 0)
	self.map_list:EnableHorizontal(true)
	self.map_list:EnableVerticalScrollbar()
	self:InitMapButtons()
	self:RefreshMapList()
end

function PANEL:AddVoter(ply, map_id)
	for _, voter in pairs(self.voters) do
		if voter.player == ply then
			self:UpdateVoters()
			return false
		end
	end

	local new_voter = vgui.Create("DPanel")
	new_voter.player = ply
	new_voter:SetSize(map_button_label_size, map_button_label_size)
	new_voter:SetTooltip(ply:Name())
	new_voter.Paint = function(s, w, h)
		surface.SetDrawColor(col_base_darkest)
		surface.DrawRect(1, 1, map_button_label_size - 2, map_button_label_size - 2)
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
	for _, map_button in pairs(self.map_buttons) do
		map_button.voter_count = 0
	end

	for _, voter in pairs(self.voters) do
		if not IsValid(voter.player) then
			voter:Remove()
		else
			if not PAM.votes[voter.player:SteamID()] then
				voter:Remove()
			else
				local map_button = self:GetMapButton(PAM.votes[voter.player:SteamID()])

				if IsValid(map_button) then
					voter:SetParent(map_button)
					local row = math.floor(map_button.voter_count / avatars_per_row)
					local newY = 0
					local newX = 0

					if row < 2 then
						newY = map_button_label_size + avatar_space * (map_button.voter_count % avatars_per_row)
						newX = (map_image_size + avatar_space) * row
					else
						newX = map_button_label_size + avatar_space * (map_button.voter_count % avatars_per_row)
						newY = map_button_label_size + avatar_space * (row - 2)
					end

					voter:SetPos(newX, newY)
					map_button.voter_count = map_button.voter_count + 1
				end
			end
		end
	end
	self:RefreshMapList()
end

function PANEL:FitsSearchTerm(button)
	local search_term = self.search_term

	if not search_term or search_term == "" then return true end
	if #search_term > #button.map.name then return false end

	local i = 1
	for j = 1, #button.map.name do
		if button.map.name:sub(j, j):lower() == search_term:sub(i, i):lower() then
			if i >= #search_term then
				return true
			end
			i = i + 1
		end
	end

	return false
end

function PANEL:SortMapList(comparator)
	table.sort(self.map_buttons, comparator)
	self:RefreshMapList()
end

function PANEL:RefreshMapList()
	self.map_list:Clear()
	for _, map_button in pairs(self.map_buttons) do
		if (not PAM.winning_map_id and self:FitsSearchTerm(map_button) and (not self.show_favorites or PAM.IsFavorite(map_button.map.name)) and (not self.show_voted_on or map_button.voter_count > 0)) or PAM.winning_map_id == map_button.map.id then
			self.map_list:AddItem(map_button)
			map_button:SetVisible(true)
		else
			map_button:SetVisible(false)
		end
	end
end

function PANEL:InitMapButtons()
	for k, mapinfo in pairs(PAM.maps) do
		local map_button = vgui.Create("DButton")
		map_button:SetSize(map_button_size, map_button_size)
		map_button:SetText("")
		map_button:SetPaintBackground(false)
		map_button.voter_count = 0
		map_button.map = mapinfo
		map_button.DoClick = function()
			PAM.Vote(map_button.map.id)
		end

		-- map thumbnail
		local map_image = vgui.Create("DImage", map_button)

		local mat_map_icon = PAM.GetMapIconMat(map_button.map.name)
		if mat_map_icon then
			map_image:SetMaterial(mat_map_icon)
		else
			map_image:SetMaterial(mat_missing_map)
		end

		map_image:SetSize(map_image_size, map_image_size)
		map_image:SetPos(map_button_label_size, map_button_label_size)

		local image_border = vgui.Create("DPanel", map_image)
		image_border:SetSize(map_image_size, map_image_size)
		image_border.Paint = function(s, w, h)
			surface.SetDrawColor(col_base_darkest)
			surface.DrawOutlinedRect(0, 0, map_image_size, map_image_size)
		end

		-- mapname label
		local lbl_map_name = vgui.Create("DLabel", map_button)
		lbl_map_name:SetPos(0, 0)
		lbl_map_name:SetSize(map_button_size, map_button_label_size)
		lbl_map_name:SetContentAlignment(5)
		lbl_map_name:SetText(mapinfo.name)
		lbl_map_name:SetTextColor(col_text)
		lbl_map_name:SetFont("PAM_NameFont")

		-- playcount label
		local lbl_playcount = vgui.Create("DLabel", map_button)
		lbl_playcount:SetPos(0, map_button_size - map_button_label_size)
		lbl_playcount:SetSize(map_button_size, map_button_label_size)
		lbl_playcount:SetContentAlignment(5)
		lbl_playcount:SetTextColor(col_text)
		lbl_playcount:SetFont("PAM_PlaycountFont")
		if mapinfo.playcount == 0 then
			lbl_playcount:SetText("Not played yet")
		elseif mapinfo.playcount == 1 then
			lbl_playcount:SetText("Played once")
		else
			lbl_playcount:SetText("Played " .. mapinfo.playcount .. " times")
		end

		-- heart for favorites
		local ibtn_favorite = vgui.Create("DImageButton", map_button)
		if PAM.IsFavorite(map_button.map.name) then
			ibtn_favorite:SetMaterial(ic_favorite)
			map_button.is_favorite = true
		else
			ibtn_favorite:SetMaterial(ic_not_favorite)
			map_button.is_favorite = false
		end
		ibtn_favorite:SetSize(map_button_label_size, map_button_label_size)
		ibtn_favorite:SetPos(map_button_size - map_button_label_size, map_button_size - map_button_label_size)
		ibtn_favorite.DoClick = function()
			if PAM.IsFavorite(map_button.map.name) then
				PAM.RemoveFromFavorites(map_button.map.name)
				ibtn_favorite:SetMaterial(ic_not_favorite)
			else
				PAM.AddToFavorites(map_button.map.name)
				ibtn_favorite:SetMaterial(ic_favorite)
			end
			self:RefreshMapList()
		end

		-- override default texture
		map_button.Paint = function(s, w, h)
			surface.SetDrawColor(col_base)
			surface.DrawRect(0, 0, map_button_size, map_button_size);
			surface.SetDrawColor(col_base_darkest)
			surface.DrawRect(0, 0, map_button_size, map_button_label_size);

			surface.DrawOutlinedRect(0, 0, map_button_size, map_button_size);
			surface.DrawOutlinedRect(map_button_label_size - 1, map_button_label_size - 1, map_image_size + 2, map_image_size + 2)
			surface.DrawLine(0, map_button_label_size, map_button_size, map_button_label_size);
			surface.DrawLine(0, map_button_label_size - 1, map_button_size, map_button_label_size - 1);
		end

		table.insert(self.map_buttons, map_button)
	end
end

function PANEL:GetMapButton(id)
	for _, button in pairs(self.map_buttons) do
		if button.map.id == id then
			return button
		end
	end
	return false
end

function PANEL:AnnounceWinner()
	self:SetVisible(true)
	self:RefreshMapList()
end

derma.DefineControl("pam_votescreen_dark", "", PANEL, "DFrame")
