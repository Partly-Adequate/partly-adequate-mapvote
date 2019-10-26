local PANEL = {}

// alignment helping values
local mapButtonSize = 180;
local mapImageSize = mapButtonSize - 50;
local mapButtonLabelSize = (mapButtonSize - mapImageSize) / 2
local avatarSize = mapButtonLabelSize - 6;
local scrollBarSize = 25;
local settingsHeight = 20;
local borderSize = 8;
local avatarsPerRow = math.floor(mapImageSize / mapButtonLabelSize)
local avatarSpace = mapImageSize / avatarsPerRow

function PANEL:Init()
	local width = ScrW() * 0.5
	local height = ScrH() * 0.75
	// adjust width to button width + scrollbar
	width = width + (mapButtonSize - (width % mapButtonSize)) + scrollBarSize;

	self:SetSize(width, height)
	self:SetPos((ScrW() - width) * 0.5, (ScrH() - height) * 0.5)
	self:SetZPos(-100)

	self.Paint = function(s, w, h)
		surface.SetDrawColor(75, 75, 75)
		surface.DrawRect(0, 0, width, height)
	end

	self.searchTerm = ""
	self.showFavorites = false
	self.showVotedOn = false
	self.Voters = {}
	self.MapButtons = {}
	self.timeLeft = 0
	self.winnerID = nil

	self:InitSettings(width - borderSize, height - borderSize)
	self:InitMapList(width - borderSize, height - borderSize)

	self:MakePopup()
	self:SetKeyboardInputEnabled(false)
end

function PANEL:InitSettings(width, height)
	local VoteSettings = vgui.Create("Panel", self)
	VoteSettings:SetSize(width, 3 * settingsHeight)
	VoteSettings:SetPos(borderSize / 2, settingsHeight + borderSize / 2)
	self:InitCountDown(VoteSettings, width, height)
	self:InitSortBox(VoteSettings, width, height)
	self:InitSearchArea(VoteSettings, width, height)
	self:InitFavorites(VoteSettings, width, height)
	self:InitVotedOn(VoteSettings, width, height)
end

function PANEL:InitCountDown(parent, width, height)
	local LBLCountDown = vgui.Create("DLabel", parent)
	LBLCountDown:SetFont("PAM_VoteFontCountdown")
	LBLCountDown:SetContentAlignment(5)
	LBLCountDown:SetSize(width, settingsHeight)
	LBLCountDown:SetPos(0, 0)
	LBLCountDown.Think = function()
		local timeLeft = math.Round(math.max(PAM.EndsAt - CurTime(), 0))
		LBLCountDown:SetText(timeLeft .. " seconds left!")
	end
end

function PANEL:InitSortBox(parent, width, height)
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
	CBSortBy:SetSize(width / 2, settingsHeight)
	CBSortBy:SetPos(width / 2, settingsHeight)

	CBSortBy:AddChoice("Mapname [ASC]", function(map_button_1, map_button_2)
		return CompareStrings(map_button_1.map.name, map_button_2.map.name)
	end)
	CBSortBy:AddChoice("Mapname [DESC]", function(map_button_1, map_button_2)
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

function PANEL:InitSearchArea(parent, width, height)
	local TXTSearch = vgui.Create("DTextEntry", parent)
	TXTSearch:SetPlaceholderText("search for maps")
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
	TXTSearch:SetSize(width / 2, settingsHeight)
	TXTSearch:SetPos(0, settingsHeight)
end

function PANEL:InitFavorites(parent, width, height)
	local BTNToggleFavorites = vgui.Create("DButton", parent)
	BTNToggleFavorites:SetText("favorites")
	BTNToggleFavorites:SetSize(width / 2, settingsHeight)
	BTNToggleFavorites:SetPos(width / 2, settingsHeight * 2)

	local imageFavorites = "vgui/ttt/pam_ic_fav"
	local imageNotFavorites = "vgui/ttt/pam_ic_nofav"

	local icon = vgui.Create("DImage", BTNToggleFavorites)
	icon:SetPos(width / 2 - settingsHeight, 0)
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

function PANEL:InitVotedOn(parent, width, height)
	local BTNToggleVotedOn = vgui.Create("DButton", parent)
	BTNToggleVotedOn:SetText("voted on")
	BTNToggleVotedOn:SetSize(width / 2, settingsHeight)
	BTNToggleVotedOn:SetPos(0, settingsHeight * 2)

	local imageVotedOn = "vgui/ttt/pam_ic_fav"
	local imageNotVotedOn = "vgui/ttt/pam_ic_nofav"

	local icon = vgui.Create("DImage", BTNToggleVotedOn)
	icon:SetPos(width / 2 - settingsHeight, 0)
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

function PANEL:InitMapList(width, height)
	self.MapList = vgui.Create("DPanelList", self)
	self.MapList:SetSize(width, height - 4 * settingsHeight)
	self.MapList:SetPos(borderSize / 2, settingsHeight * 4 + borderSize / 2)
	self.MapList:EnableHorizontal(true)
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
		surface.SetDrawColor(0, 0, 0)
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
		mapButton.NumVotes = 0
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
					local row = math.floor(mapButton.NumVotes / avatarsPerRow)
					local newY = 0
					local newX = 0

					if row < 2 then
						newY = mapButtonLabelSize + avatarSpace * (mapButton.NumVotes % avatarsPerRow)
						newX = (mapImageSize + avatarSpace) * row
					else
						newX = mapButtonLabelSize + avatarSpace * (mapButton.NumVotes % avatarsPerRow)
						newY = mapButtonLabelSize + avatarSpace * (row - 2)
					end

					print(tostring(newX) .. ", " .. tostring(newY))
					voter:SetPos(newX, newY)
					mapButton.NumVotes = mapButton.NumVotes + 1
				end
			end
		end
	end
	self:RefreshMapList()
end

function PANEL:FitsSearchTerm(button)
	local searchTerm = self.SearchTerm

	if not searchTerm or searchTerm == "" then
		return true
	end

	if #searchTerm > #button.map.name then
		return false
	end

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
		if (not winnerID or mapButton.map.id == winnerID) and self:FitsSearchTerm(mapButton) and (not self.showFavorites or mapButton.isFavorite) and (not self.showVotedOn or mapButton.NumVotes > 0) then
			self.MapList:AddItem(mapButton)
		end
	end
end

function PANEL:ShowMapButton(MapButton)
	if IsValid(MapButton) then
		self.winnerID = MapButton.map.id
		self:RefreshMapList()
	end
end

function PANEL:InitMapButtons()
	local map_missing_material = Material("vgui/ttt/pam_ic_missing.png")
	local button_material = Material("vgui/ttt/pam_map_button.png")
	for k, mapinfo in pairs(PAM.Maps) do
		local button = vgui.Create("DButton")
		button.voterCount = 0
		button.map = mapinfo
		button:SetSize(mapButtonSize, mapButtonSize)
		button:SetText("")

		// on button clicked
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
			surface.SetDrawColor(0, 0, 0)
			surface.DrawOutlinedRect(0, 0, mapImageSize, mapImageSize)
		end

		// mapname label
		local lblMapName = vgui.Create("DLabel", button)
		lblMapName:SetPos(0, 0)
		lblMapName:SetSize(mapButtonSize, mapButtonLabelSize)
		lblMapName:SetContentAlignment(4)
		lblMapName:SetText(mapinfo.name)
		lblMapName:SetFont("PAM_MapNameFont")

		// playcount label
		local lblPlayCount = vgui.Create("DLabel", button)
		lblPlayCount:SetPos(0, mapButtonSize - mapButtonLabelSize)
		lblPlayCount:SetSize(mapButtonSize, mapButtonLabelSize)
		lblPlayCount:SetContentAlignment(4)
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
			ibtnFavorite:SetImage("vgui/ttt/pam_ic_fav.vmt")
			button.isFavorite = true
		else
			ibtnFavorite:SetImage("vgui/ttt/pam_ic_nofav.vmt")
			button.isFavorite = false
		end
		ibtnFavorite:SetSize(mapButtonLabelSize, mapButtonLabelSize)
		ibtnFavorite:SetPos(mapButtonSize - mapButtonLabelSize, mapButtonSize - mapButtonLabelSize)
		ibtnFavorite.DoClick = function()
			if button.isFavorite then
				if PAM.Panel:RemoveFromFavorites(button.map.name) then
					button.isFavorite = false

					ibtnFavorite:SetImage("vgui/ttt/pam_ic_nofav.vmt")
					PAM.Panel:RefreshMapList()
				end
			else
				if PAM.Panel:AddToFavorites(button.map.name) then
					button.isFavorite = true

					ibtnFavorite:SetImage("vgui/ttt/pam_ic_fav.vmt")
					PAM.Panel:RefreshMapList()
				end
			end
		end

		// override default texture
		button.Paint = function(s, w, h)
			surface.SetDrawColor(50, 50, 50)
			surface.DrawRect(0, 0, mapButtonSize, mapButtonSize);
			surface.SetDrawColor(100, 100, 100)
			surface.DrawRect(0, 0, mapButtonSize, mapButtonLabelSize);
			surface.DrawRect(0, mapButtonSize - mapButtonLabelSize, mapButtonSize, mapButtonLabelSize);
			surface.SetDrawColor(0, 0, 0)
			surface.DrawOutlinedRect(0, 0, mapButtonSize, mapButtonSize);
			surface.DrawOutlinedRect(0, mapButtonLabelSize, mapButtonSize, mapImageSize);
			surface.DrawOutlinedRect(0, mapButtonLabelSize - 1, mapButtonSize, mapImageSize + 2);
			surface.DrawOutlinedRect(mapButtonLabelSize - 1, mapButtonLabelSize - 1, mapImageSize + 2, mapImageSize + 2);
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

	local selectedMapButton = self:GetMapButton(id)

	if IsValid(selectedMapButton) then
		self:ShowMapButton(selectedMapButton)

		timer.Create("ttt_pam_notification", 0.4, 3, function()
			surface.PlaySound("hl1/fvox/blip.wav")
		end)
	end
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
