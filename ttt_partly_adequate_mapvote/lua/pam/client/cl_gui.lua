PANEL = {}

// alignment helping values
local mapButtonSize = 150
local mapImageSize = mapButtonSize - 50
local mapButtonLabelSize = (mapButtonSize - mapImageSize) / 2
local avatarSize = mapButtonLabelSize - 6
local borderSize = 0
local scrollBarSize = 14
local settingsHeight = 25
local avatarsPerRow = math.floor(mapImageSize / mapButtonLabelSize)
local avatarSpace = mapImageSize / avatarsPerRow

// Colors
local colBase = {r = 40, g = 40, b = 40, a = 255}
local colBaseDarker = {r = 30, g = 30, b = 30, a = 255}
local colBaseDarkest = {r = 20, g = 20, b = 20, a = 255}
local colText = {r = 150, g = 150, b = 150, a = 255}

surface.CreateFont("PAM_MapNameFont", {
	font = "Trebuchet MS",
	size = mapButtonLabelSize * 0.75
})

surface.CreateFont("PAM_PlayCountFont", {
	font = "Trebuchet MS",
	size = mapButtonLabelSize * 0.5
})

surface.CreateFont("PAM_VoteFontCountdown", {
	font = "Trebuchet MS",
	size = settingsHeight - 1
})

surface.CreateFont("PAM_Settings", {
	font = "Trebuchet MS",
	size = settingsHeight * 0.66
})

function PANEL:Init()
	local width = ScrW() * 0.5
	local height = ScrH() * 0.75 + borderSize / 2
	// adjust width to button width + scrollbar
	width = width + (mapButtonSize - (width % mapButtonSize)) + scrollBarSize + borderSize;
	self:SetSize(width, height)
	self:SetPos((ScrW() - width) * 0.5, (ScrH() - height) * 0.5)
	self:SetZPos(-100)
	self:SetTitle("Partly Adequate Mapvote")
	self:SetDeleteOnClose(false)

	self.Paint = function(s, w, h)
		surface.SetDrawColor(colBaseDarkest)
		surface.DrawRect(0, 0, w, 25)
		surface.SetDrawColor(colBase)
		surface.DrawRect(0, 25, w, h - 25)
	end

	self.searchTerm = ""
	self.showFavorites = false
	self.showVotedOn = false
	self.Voters = {}
	self.MapButtons = {}
	self.timeLeft = 0

	local container = vgui.Create("DPanel", self)
	container:SetSize(width - borderSize, height - borderSize - 25)
	container:SetPos(borderSize / 2, 25 + borderSize / 2)
	container.Paint = function(s, w, h) end

	self:InitSettings(container, 0, 0, width - borderSize, settingsHeight * 3)
	self:InitMapList(container, 0, settingsHeight * 3, width - borderSize, height - borderSize / 2 - 25 - settingsHeight * 3)

	self:MakePopup()
	self:SetKeyboardInputEnabled(false)
end

function PANEL:InitSettings(parent, posX, posY, width, height)
	local VoteSettings = vgui.Create("Panel", parent)
	VoteSettings:SetSize(width, height)
	VoteSettings:SetPos(posX, posY)
	VoteSettings.Paint = function(s, w, h) end

	self:InitCountDown(VoteSettings, 0, 0, width, settingsHeight)
	self:InitSearchArea(VoteSettings, 0, settingsHeight, width / 2, settingsHeight)
	self:InitFavorites(VoteSettings, width / 2, settingsHeight, width / 2, settingsHeight)
	self:InitVotedOn(VoteSettings, width / 2, 2 * settingsHeight, width / 2, settingsHeight)
	self:InitSortBox(VoteSettings, 0, 2 * settingsHeight, width / 2, settingsHeight)
end

function PANEL:InitCountDown(parent, posX, posY, width, height)
	local LBLCountDown = vgui.Create("DLabel", parent)
	LBLCountDown:SetFont("PAM_VoteFontCountdown")
	LBLCountDown:SetTextColor(colText)
	LBLCountDown:SetContentAlignment(5)
	LBLCountDown:SetSize(width, height)
	LBLCountDown:SetPos(posX, posY)
	LBLCountDown.Paint = function(s, w, h)
		surface.SetDrawColor(colBaseDarkest)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(colBase)
		surface.DrawRect(2, 2, w - 4, h - 4)
	end
	LBLCountDown.Think = function()
		local timeLeft = math.Round(math.max(PAM.EndsAt - CurTime(), 0))
		LBLCountDown:SetText(timeLeft .. " seconds left!")
	end
end

function PANEL:InitSearchArea(parent, posX, posY, width, height)
	local container = vgui.Create("DPanel", parent)
	container:SetSize(width, height)
	container:SetPos(posX, posY)
	container.Paint = function(s, w, h)
		surface.SetDrawColor(colBaseDarkest)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(colBase)
		surface.DrawRect(2, 2, w - 4, h - 4)
	end

	local TXTSearch = vgui.Create("DTextEntry", container)
	TXTSearch:SetPlaceholderText("Search for maps...")
	TXTSearch:SetFont("PAM_Settings")
	TXTSearch.OnChange = function()
		self.SearchTerm = TXTSearch:GetValue()
		self:RefreshMapList()
	end
	TXTSearch.OnGetFocus = function()
		self:SetKeyboardInputEnabled(true)
	end
	TXTSearch.OnLoseFocus = function()
		self:SetKeyboardInputEnabled(false)
	end
	TXTSearch:SetSize(width, height)
	TXTSearch:SetPos(0, 0)
	TXTSearch:SetPaintBackground(false)
	TXTSearch:SetTextColor(colText)
	TXTSearch:SetCursorColor(colText)
	TXTSearch:SetPlaceholderColor(colText)
end

function PANEL:InitSortBox(parent, posX, posY, width, height)
	local function CompareStrings(string1, string2)
		string1 = string.lower(string1)
		string2 = string.lower(string2)

		for i = 1, math.min(#string1, #string2) do
			byte1 = string.byte(string1:sub(i, i))
			byte2 = string.byte(string2:sub(i, i))
			if byte1 < byte2 then
				return true
			elseif byte1 > byte2 then
				return false
			end
		end
		return #string1 < #string2
	end

	local CBSortBy = vgui.Create("DComboBox", parent)
	CBSortBy:SetValue("Sort by...")
	CBSortBy:SetSize(width, height)
	CBSortBy:SetPos(posX, posY)
	CBSortBy.Paint = function(s, w, h)
		surface.SetDrawColor(colBaseDarkest)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(colBase)
		surface.DrawRect(2, 2, w - 4, h - 4)
	end
	CBSortBy:SetTextColor(colText)
	CBSortBy:SetFont("PAM_Settings")

	CBSortBy:AddChoice("Name [a-z]", function(map_button_1, map_button_2)
		return CompareStrings(map_button_1.map.name, map_button_2.map.name)
	end)
	CBSortBy:AddChoice("Name [z-a]", function(map_button_1, map_button_2)
		return not CompareStrings(map_button_1.map.name, map_button_2.map.name)
	end)
	CBSortBy:AddChoice("Least played", function(map_button_1, map_button_2)
		if not map_button_1 or not map_button_2 then
			return true
		end
		return map_button_1.map.playcount < map_button_2.map.playcount
	end)
	CBSortBy:AddChoice("Most played", function(map_button_1, map_button_2)
		if not map_button_1 or not map_button_2 then
			return true
		end
		return map_button_1.map.playcount > map_button_2.map.playcount
	end)

	CBSortBy.OnSelect = function(cb, index, text)
		local _, comparator = cb:GetSelected()
		self:SortMapList(comparator)
	end
end

function PANEL:InitFavorites(parent, posX, posY, width, height)
	local BTNToggleFavorites = vgui.Create("DButton", parent)
	BTNToggleFavorites:SetText("Show favorites")
	BTNToggleFavorites:SetSize(width, height)
	BTNToggleFavorites:SetPos(posX, posY)
	BTNToggleFavorites:SetTextColor(colText)
	BTNToggleFavorites:SetFont("PAM_Settings")
	BTNToggleFavorites.Paint = function(s, w, h)
		surface.SetDrawColor(colBaseDarkest)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(colBase)
		surface.DrawRect(2, 2, w - 4, h - 4)
	end

	local imageFavorites = "vgui/ttt/pam/ic_favorite"
	local imageNotFavorites = "vgui/ttt/pam/ic_not_favorite"

	local icon = vgui.Create("DImage", BTNToggleFavorites)
	icon:SetPos(0, 0)
	icon:SetSize(settingsHeight, settingsHeight)
	icon:SetImage(imageNotFavorites)

	BTNToggleFavorites.DoClick = function()
		self.showFavorites = not self.showFavorites
		if self.showFavorites then
			icon:SetImage(imageFavorites)
		else
			icon:SetImage(imageNotFavorites)
		end
		self:RefreshMapList()
	end
end

function PANEL:InitVotedOn(parent, posX, posY, width, height)
	local BTNToggleVotedOn = vgui.Create("DButton", parent)
	BTNToggleVotedOn:SetText("Show maps being voted on")
	BTNToggleVotedOn:SetSize(width, height)
	BTNToggleVotedOn:SetPos(posX, posY)
	BTNToggleVotedOn:SetTextColor(colText)
	BTNToggleVotedOn:SetFont("PAM_Settings")
	BTNToggleVotedOn.Paint = function(s, w, h)
		surface.SetDrawColor(colBaseDarkest)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(colBase)
		surface.DrawRect(2, 2, w - 4, h - 4)
	end

	local imageVotedOn = "vgui/ttt/pam/ic_voted"
	local imageNotVotedOn = "vgui/ttt/pam/ic_not_voted"

	local icon = vgui.Create("DImage", BTNToggleVotedOn)
	icon:SetPos(0, 0)
	icon:SetSize(settingsHeight, settingsHeight)
	icon:SetImage(imageNotVotedOn)

	BTNToggleVotedOn.DoClick = function()
		self.showVotedOn = not self.showVotedOn
		if self.showVotedOn then
			icon:SetImage(imageVotedOn)
		else
			icon:SetImage(imageNotVotedOn)
		end
		self:RefreshMapList()
	end
end

function PANEL:InitMapList(parent, posX, posY, width, height)
	local mapListContainer = vgui.Create("DPanel", parent)
	mapListContainer:SetSize(width, height)
	mapListContainer:SetPos(posX, posY)

	mapListContainer.Paint = function(s, w, h)
		surface.SetDrawColor(colBaseDarker)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(colBaseDarkest)
		surface.DrawRect(w - scrollBarSize, 0, scrollBarSize, h)
	end

	self.MapList = vgui.Create("DPanelList", mapListContainer)
	self.MapList:SetSize(width, height)
	self.MapList:SetPos(0, 0)
	self.MapList:EnableHorizontal(true)
	self.MapList:EnableVerticalScrollbar()
	self:InitMapButtons()
	self:RefreshMapList()
end

function PANEL:AddVoter(ply)
	for _, voter in pairs(self.Voters) do
		if voter.player == ply then
			self:UpdateVoters()
			return false
		end
	end

	print("adding voter")

	local newVoter = vgui.Create("DPanel")
	newVoter.player = ply
	newVoter:SetSize(mapButtonLabelSize, mapButtonLabelSize)
	newVoter:SetTooltip(ply:Name())
	newVoter.Paint = function(s, w, h)
		surface.SetDrawColor(colBaseDarkest)
		surface.DrawRect(1, 1, mapButtonLabelSize - 2, mapButtonLabelSize - 2)
	end

	local icon = vgui.Create("AvatarImage", newVoter)
	icon:SetSize(avatarSize, avatarSize)
	icon:SetPos(3, 3)
	icon:SetPlayer(ply, 32)
	icon:SetTooltip(ply:Name())

	table.insert(self.Voters, newVoter)
	self:UpdateVoters()
end

function PANEL:RemoveVoter(ply)
	for _, voter in pairs(self.Voters) do
		if(voter.player.SteamID() == ply.SteamID()) then
			table.RemoveByValue(self.Voters, voter)
			voter:Remove()
			self:UpdateVoters()
			return
		end
	end
end

function PANEL:UpdateVoters()
	for _, mapButton in pairs(self.MapButtons) do
		mapButton.voterCount = 0
	end

	for _, voter in pairs(self.Voters) do
		if not IsValid(voter.player) then
			voter:Remove()
		else
			if not PAM.Votes[voter.player:SteamID()] then
				voter:Remove()
			else
				local mapButton = self:GetMapButton(PAM.Votes[voter.player:SteamID()])

				if IsValid(mapButton) then
					voter:SetParent(mapButton)
					local row = math.floor(mapButton.voterCount / avatarsPerRow)
					local newY = 0
					local newX = 0

					if row < 2 then
						newY = mapButtonLabelSize + avatarSpace * (mapButton.voterCount % avatarsPerRow)
						newX = (mapImageSize + avatarSpace) * row
					else
						newX = mapButtonLabelSize + avatarSpace * (mapButton.voterCount % avatarsPerRow)
						newY = mapButtonLabelSize + avatarSpace * (row - 2)
					end

					print(tostring(newX) .. ", " .. tostring(newY))
					voter:SetPos(newX, newY)
					mapButton.voterCount = mapButton.voterCount + 1
				end
			end
		end
	end
	self:RefreshMapList()
end

function PANEL:FitsSearchTerm(button)
	local searchTerm = self.SearchTerm

	if not searchTerm or searchTerm == "" then return true end
	if #searchTerm > #button.map.name then return false end

	local i = 1
	for j = 1, #button.map.name do
		if button.map.name:sub(j, j):lower() == searchTerm:sub(i, i):lower() then
			if i >= #searchTerm then
				return true
			end
			i = i + 1
		end
	end

	return false
end

function PANEL:SortMapList(comparator)
	table.sort(self.MapButtons, comparator)
	self:RefreshMapList()
end

function PANEL:RefreshMapList()
	self.MapList:Clear()
	for _, mapButton in pairs(self.MapButtons) do
		if (not self.winnerID or mapButton.map.id == self.winnerID) and self:FitsSearchTerm(mapButton) and (not self.showFavorites or mapButton.isFavorite) and (not self.showVotedOn or mapButton.voterCount > 0) then
			self.MapList:AddItem(mapButton)
			mapButton:SetVisible(true)
		else
			mapButton:SetVisible(false)
		end
	end
end

function PANEL:InitMapButtons()
	local map_missing_material = Material("vgui/ttt/pam/img_missing.png")
	for k, mapinfo in pairs(PAM.Maps) do
		local button = vgui.Create("DButton")
		button.voterCount = 0
		button.map = mapinfo
		button:SetSize(mapButtonSize, mapButtonSize)
		button:SetText("")

		button.DoClick = function()
			net.Start("PAM_Vote")
			net.WriteUInt(mapinfo.id, 32)
			net.SendToServer()
		end

		// map thumbnail
		local mapImage = vgui.Create("DImage", button)
		local mapImageMat = map_missing_material
		if file.Exists("maps/thumb/" .. mapinfo.name .. ".png", "GAME") then
			mapImageMat = Material("maps/thumb/" .. mapinfo.name .. ".png")
		end
		mapImage:SetMaterial(mapImageMat)
		mapImage:SetSize(mapImageSize, mapImageSize)
		mapImage:SetPos(mapButtonLabelSize, mapButtonLabelSize)

		local imageBorder = vgui.Create("DPanel", mapImage)
		imageBorder:SetSize(mapImageSize, mapImageSize)
		imageBorder.Paint = function(s, w, h)
			surface.SetDrawColor(colBaseDarkest)
			surface.DrawOutlinedRect(0, 0, mapImageSize, mapImageSize)
		end

		// mapname label
		local lblMapName = vgui.Create("DLabel", button)
		lblMapName:SetPos(0, 0)
		lblMapName:SetSize(mapButtonSize, mapButtonLabelSize)
		lblMapName:SetContentAlignment(5)
		lblMapName:SetText(mapinfo.name)
		lblMapName:SetTextColor(colText)
		lblMapName:SetFont("PAM_MapNameFont")

		// playcount label
		local lblPlayCount = vgui.Create("DLabel", button)
		lblPlayCount:SetPos(0, mapButtonSize - mapButtonLabelSize)
		lblPlayCount:SetSize(mapButtonSize, mapButtonLabelSize)
		lblPlayCount:SetContentAlignment(5)
		lblPlayCount:SetTextColor(colText)
		lblPlayCount:SetFont("PAM_PlayCountFont")
		if mapinfo.playcount == 0 then
			lblPlayCount:SetText("Not played yet")
		elseif mapinfo.playcount == 1 then
			lblPlayCount:SetText("Played once")
		else
			lblPlayCount:SetText("Played " .. mapinfo.playcount .. " times")
		end

		// heart for favorites
		local ibtnFavorite = vgui.Create("DImageButton", button)
		if table.HasValue(PAM.FavoriteMaps, button.map.name) then
			ibtnFavorite:SetImage("vgui/ttt/pam/ic_favorite.vmt")
			button.isFavorite = true
		else
			ibtnFavorite:SetImage("vgui/ttt/pam/ic_not_favorite.vmt")
			button.isFavorite = false
		end
		ibtnFavorite:SetSize(mapButtonLabelSize, mapButtonLabelSize)
		ibtnFavorite:SetPos(mapButtonSize - mapButtonLabelSize, mapButtonSize - mapButtonLabelSize)
		ibtnFavorite.DoClick = function()
			if button.isFavorite then
				if self:RemoveFromFavorites(button.map.name) then
					button.isFavorite = false

					ibtnFavorite:SetImage("vgui/ttt/pam/ic_not_favorite.vmt")
					self:RefreshMapList()
				end
			else
				if self:AddToFavorites(button.map.name) then
					button.isFavorite = true

					ibtnFavorite:SetImage("vgui/ttt/pam/ic_favorite.vmt")
					self:RefreshMapList()
				end
			end
		end

		// override default texture
		button.Paint = function(s, w, h)
			surface.SetDrawColor(colBase)
			surface.DrawRect(0, 0, mapButtonSize, mapButtonSize);
			surface.SetDrawColor(colBaseDarkest)
			surface.DrawRect(0, 0, mapButtonSize, mapButtonLabelSize);

			surface.DrawOutlinedRect(0, 0, mapButtonSize, mapButtonSize);
			surface.DrawOutlinedRect(mapButtonLabelSize - 1, mapButtonLabelSize - 1, mapImageSize + 2, mapImageSize + 2)
			surface.DrawLine(0, mapButtonLabelSize, mapButtonSize, mapButtonLabelSize);
			surface.DrawLine(0, mapButtonLabelSize - 1, mapButtonSize, mapButtonLabelSize - 1);
		end

		table.insert(self.MapButtons, button)
		button:SetPaintBackground(false)
	end
end

function PANEL:GetMapButton(id)
	for _, button in pairs(self.MapButtons) do
		if button.map.id == id then
			return button
		end
	end
	return false
end

function PANEL:Flash(id)
	self:SetVisible(true)

	self.winnerID = id
	self:RefreshMapList()

	timer.Create("ttt_pam_notification", 0.4, 3, function()
		surface.PlaySound("hl1/fvox/blip.wav")
	end)
end

function PANEL:AddToFavorites(mapname)
	if not table.HasValue(PAM.FavoriteMaps, mapname) then
		table.insert(PAM.FavoriteMaps, mapname)
		file.Write("pam/favoritemaps.txt", util.TableToJSON(PAM.FavoriteMaps))

		print("added " .. mapname .. " to favorites")

		return true
	end

	return false
end

function PANEL:RemoveFromFavorites(mapname)
	if table.HasValue(PAM.FavoriteMaps, mapname) then
		table.RemoveByValue(PAM.FavoriteMaps, mapname)
		file.Write("pam/favoritemaps.txt", util.TableToJSON(PAM.FavoriteMaps))

		print("removed " .. mapname .. " from favorites")

		return true
	end

	return false
end

derma.DefineControl("ttt_pam_votescreen", "", PANEL, "DFrame")
