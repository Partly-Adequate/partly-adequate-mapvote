surface.CreateFont("PAM_MapNameFont", {
	font = "Trebuchet MS",
	size = 25,
	weight = 700,
	antialias = true,
	shadow = true
})

surface.CreateFont("PAM_PlayCountFont", {
	font = "Trebuchet MS",
	size = 20,
	weight = 700,
	antialias = true,
	shadow = true
})

surface.CreateFont("PAM_VoteFontCountdown", {
	font = "Tahoma",
	size = 32,
	weight = 700,
	antialias = true,
	shadow = true
})

PAM.EndsAt = 0
PAM.Panel = false
PAM.FavoriteMaps = {}

if file.Exists("pam/favoritemaps.txt", "DATA") then
	PAM.FavoriteMaps = util.JSONToTable(file.Read("pam/favoritemaps.txt", "DATA"))
end

net.Receive("PAM_Start", function()
	PAM.Maps = {}
	PAM.Votes = {}
	PAM.Playcounts = {}
	PAM.State = PAM.STATE_STARTED

	local amount = net.ReadUInt(32)

	for i = 1, amount do
		local mapinfo = {};
		mapinfo.id = i
		mapinfo.name = net.ReadString()
		mapinfo.playcount = net.ReadUInt(32)
		PAM.Maps[i] = mapinfo
	end

	--the point in time at which the mapvote will end
	PAM.EndsAt = CurTime() + net.ReadUInt(32)

	if IsValid(PAM.Panel) then
		PAM.Panel:Remove()
	end

	PAM.Panel = vgui.Create("VoteScreen")
	PAM.Panel:InitMapListButtons()
	PAM.Panel:RefreshMapList()
end)

net.Receive("PAM_Vote", function()
	local ply = net.ReadEntity()

	if IsValid(ply) then
		PAM.Votes[ply:SteamID()] = net.ReadUInt(32) -- map_id

		if IsValid(PAM.Panel) then
			PAM.Panel:AddVoter(ply)
		end
	end
end)

net.Receive("PAM_UnVote", function()
	local ply = net.ReadEntity()
	if IsValid(ply) then
		PAM.Panel:RemoveVoter(ply)
	end
end)

net.Receive("PAM_Announce_Winner", function()
	if IsValid(PAM.Panel) then
		PAM.State = PAM.STATE_FINISHED
		PAM.Panel:Flash(net.ReadUInt(32))
	end
end)

net.Receive("PAM_Cancel", function()
	if IsValid(PAM.Panel) then
		PAM.Panel:Remove()
		PAM.State = PAM.STATE_DISABLED
	end
end)

local PANEL = {}

function PANEL:Init()
	// menu size
	local width = ScrW() * 0.5
	local height = ScrH() * 0.75
	// adjust width to button width + scrollbar
	width = width + (200 - (width % 200)) + 23
	self:SetSize(width, height)

	//menu position (centered)
	self:SetPos((ScrW() - width) * 0.5, (ScrH() - height) * 0.5)
	self:SetZPos(-100)

	// other menu settings
	self:SetTitle("Partly Adequate Mapvote")
	self:SetDeleteOnClose(false)
	self:SetIcon("vgui/ttt/pam_ic_menu.png")
	self.searchTerm = ""
	self.showFavorites = false

	// upper settings menu
	self.VoteSettings = vgui.Create("Panel", self)
	// countdown
	self.LBLCountDown = vgui.Create("DLabel", self.VoteSettings)
	self.LBLCountDown:SetFont("PAM_VoteFontCountdown")
	self.LBLCountDown:SetContentAlignment(5)
	self.LBLCountDown:SetSize(width - 10, 30)
	self.LBLCountDown:SetPos(0, 0)
	//search textentry
	self.TXTSearch = vgui.Create("DTextEntry", self.VoteSettings)
	self.TXTSearch:SetPlaceholderText("search for maps")
	self.TXTSearch.OnChange = function()
		self.SearchTerm = self.TXTSearch:GetValue()
		self:RefreshMapList()
	end
	self.TXTSearch.OnGetFocus = function()
		self:SetKeyboardInputEnabled(true)
	end
	self.TXTSearch.OnLoseFocus = function()
		self:SetKeyboardInputEnabled(false)
	end
	self.TXTSearch:SetSize(width - 10, 30)
	self.TXTSearch:SetPos(0, 30)

	// sort combobox
	// sort function
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
	self.CBSortBy = vgui.Create("DComboBox", self.VoteSettings)
	self.CBSortBy:SetValue("Sort by...")
	self.CBSortBy:SetSize((width - 10) / 2, 30)
	self.CBSortBy:SetPos(0, 60)
	//choices
	self.CBSortBy:AddChoice("Mapname [ASC]", function(map_button_1, map_button_2)
		return CompareStrings(map_button_1.map.name, map_button_2.map.name)
	end)
	self.CBSortBy:AddChoice("Mapname [DESC]", function(map_button_1, map_button_2)
		return not CompareStrings(map_button_1.map.name, map_button_2.map.name)
	end)
	self.CBSortBy:AddChoice("Least played", function(map_button_1, map_button_2)
		if not map_button_1 or not map_button_2 then
			return true
		end
		return map_button_1.map.playcount < map_button_2.map.playcount
	end)
	self.CBSortBy:AddChoice("Most played", function(map_button_1, map_button_2)
		if not map_button_1 or not map_button_2 then
			return true
		end
		return map_button_1.map.playcount > map_button_2.map.playcount
	end)
	// on selected
	self.CBSortBy.OnSelect = function(panel, index, value)
		local _, comparator = self.CBSortBy:GetSelected()
		self:SortMapList(comparator)
	end

	// favorites
	self.BTNToggleFavorites = vgui.Create("DButton", self.VoteSettings)
	self.BTNToggleFavorites:SetText("favorites")
	self.BTNToggleFavorites:SetSize((width - 10) * 0.5, 30)
	self.BTNToggleFavorites:SetPos((width - 10) * 0.5, 60)
	self.BTNToggleFavorites.DoClick = function()
		self.showFavorites = not self.showFavorites
		self:RefreshMapList()
	end

	// vote settings
	self.VoteSettings:SetZPos(-100)
	self.VoteSettings:SetSize(width - 10, 90)
	self.VoteSettings:Dock(TOP)

	// map list
	self.MapList = vgui.Create("DPanelList", self)
	self.MapList:Dock(FILL)
	self.MapList:EnableVerticalScrollbar(true)
	self.MapList:EnableHorizontal(true)
	self.MapList:SetZPos(-100)

	// TODO this is bad
	width = width - 10

	self.Voters = {}
	self.MapListButtons = {}
	self.timeLeft = 0
	self.isLocked = false

	self:MakePopup()
	self:SetKeyboardInputEnabled(false)
end

function PANEL:OnClose()
	self:SetVisible(false)
end

function PANEL:AddVoter(voter)
	for _, v in pairs(self.Voters) do
		if v.Player and v.Player == voter then
			return false
		end
	end

	local icon_container = vgui.Create("Panel", self.MapList)

	local icon = vgui.Create("AvatarImage", icon_container)
	icon:SetSize(16, 16)
	icon:SetZPos(-100)
	icon:SetTooltip(voter:Name())

	icon_container.Player = voter
	icon_container:SetTooltip(voter:Name())

	icon:SetPlayer(voter, 16)
	icon_container:SetSize(20, 20)
	icon:SetPos(2, 2)

	icon_container.Paint = function(s, w, h)
		draw.RoundedBox(4, 0, 0, w, h, Color(255, 0, 0, 80))

		if icon_container.img then
			surface.SetMaterial(icon_container.img)
			surface.SetDrawColor(Color(255, 255, 255))
			surface.DrawTexturedRect(2, 2, 16, 16)
		end
	end

	table.insert(self.Voters, icon_container)
end

function PANEL:RemoveVoter(voter)
	for _, v in pairs(self.Voters) do
		if(v.Player.SteamID() == voter.SteamID()) then
			table.RemoveByValue(self.Voters, v)
			return
		end
	end
end

// TODO voters should only be added and removed when needed
// Players disconnecting should result in votes to be revoked
// Players voting should result in voters to be created/moved
function PANEL:Think()
	for _, map_button in pairs(self.MapListButtons) do
		map_button.NumVotes = 0
	end

	for _, voter in pairs(self.Voters) do
		if not IsValid(voter.Player) then
			voter:Remove()
		else
			if not PAM.Votes[voter.Player:SteamID()] then
				voter:Remove()
			else
				local map_button = self:GetMapButton(PAM.Votes[voter.Player:SteamID()])

				if IsValid(map_button) then
					local newX = 5 + (20 * (map_button.NumVotes % 8))
					local newY = 35 + (20 * (math.floor(map_button.NumVotes / 8)))
					voter:SetPos(newX, newY)
					voter:SetParent(map_button)

					map_button.NumVotes = map_button.NumVotes + 1
				end
			end
		end
	end

	local timeLeft = math.Round(math.max(PAM.EndsAt - CurTime(), 0))

	self.LBLCountDown:SetText(timeLeft .. " seconds left!")
end

function PANEL:FitsSearchTerm(button)
	local searchTerm = self.SearchTerm

	if not searchTerm or searchTerm == "" then
		return true
	end

	if #searchTerm > #button.MAPNAME then
		return false
	end

	local i = 1
	for j = 1, #button.MAPNAME do
		if button.MAPNAME:sub(j, j):lower() == searchTerm:sub(i, i):lower() then
			if i >= #searchTerm then
				return true
			end
			i = i + 1
		end
	end

	return false
end

function PANEL:SortMapList(comparator)
	if comparator then
		table.sort(self.MapListButtons, comparator)

		self:RefreshMapList()
	end
end

function PANEL:RefreshMapList()
	self.MapList:Clear()

	for _, v in pairs(self.MapListButtons) do
		if self.isLocked or self:FitsSearchTerm(v) and not self.showFavorites or (self.showFavorites and v.ISFAVORITE) then
			self.MapList:AddItem(v)
		end
	end
end

function PANEL:ShowMapButton(MapButton)
	if IsValid(MapButton) then
		self.isLocked = true
		self.MapListButtons = {MapButton}
		self.MapList:Clear()
		self.MapList:AddItem(MapButton)
	end
end

function PANEL:InitMapListButtons(maps)
	self.MapListButtons = {}

	local map_missing_material = Material("vgui/ttt/pam_ic_missing.png")
	local button_material = Material("vgui/ttt/pam_map_button.png")
	local size = 200

	for k, mapinfo in pairs(maps) do
		local button = vgui.Create("DButton")
		button.voterCount = 0
		button.map = mapinfo
		button:SetSize(size, size)
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
		mapImage:SetSize(size, size)

		// button texture
		local buttonImage = vgui.Create("DImage", button)
		buttonImage:SetMaterial(button_material)
		buttonImage:SetSize(size, size)

		// mapname label
		local lblMapName = vgui.Create("DLabel", button)
		lblMapName:SetPos(5, 0)
		lblMapName:SetSize(190, 31)
		lblMapName:SetContentAlignment(4)
		lblMapName:SetText(mapinfo.name)
		lblMapName:SetFont("PAM_MapNameFont")

		// playcount label
		local lblPlayCount = vgui.Create("DLabel", button)
		lblPlayCount:SetPos(5, 169)
		lblPlayCount:SetSize(190, 31)
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
		if table.HasValue(PAM.FavoriteMaps, button.MAPNAME) then
			ibtnFavorite:SetImage("vgui/ttt/pam_ic_fav.vmt")
			button.isFavorite = true
		else
			ibtnFavorite:SetImage("vgui/ttt/pam_ic_nofav.vmt")
			button.isFavorite = false
		end
		ibtnFavorite:SetSize(31, 31)
		ibtnFavorite:SetPos(size - 31, size - 31)
		ibtnFavorite.DoClick = function()
			if button.isFavorite then
				if PAM.Panel:RemoveFromFavorites(button.MAPNAME) then
					button.isFavorite = false

					ibtnFavorite:SetImage("vgui/ttt/pam_ic_nofav.vmt")
					PAM.Panel:RefreshMapList()
				end
			else
				if PAM.Panel:AddToFavorites(button.MAPNAME) then
					button.isFavorite = true

					ibtnFavorite:SetImage("vgui/ttt/pam_ic_fav.vmt")
					PAM.Panel:RefreshMapList()
				end
			end
		end

		// override default texture
		button.Paint = function(s, w, h) end
		button:SetPaintBackground(false)

		table.insert(self.MapListButtons, button)
	end
end

function PANEL:GetMapButton(id)
	for _, button in pairs(self.MapListButtons) do
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

derma.DefineControl("VoteScreen", "", PANEL, "DFrame")
