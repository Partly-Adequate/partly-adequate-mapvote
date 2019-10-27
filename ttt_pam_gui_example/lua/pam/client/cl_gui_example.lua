PANEL = {}

surface.CreateFont("PAM_ExampleFont", {
	font = "Trebuchet MS",
	size = 20
})

local exampleTextColor = {r = 255, g = 255, b = 255, a = 200}

function PANEL:Init()
	// basic frame settings
	local width = 500
	local height = ScrH() * 0.75
	self:SetSize(width, height)
	self:SetPos((ScrW() - width) * 0.5, (ScrH() - height) * 0.5)
	self:SetZPos(-100)
	self:SetTitle("Partly Adequate Mapvote GUI Example")
	// This is required for the ttt_pam_toggle_menu command to work
	self:SetDeleteOnClose(false)

	// a list where all mapbuttons will be inserted into later
	self.MapButtons = {}

	// the countdown label
	local LBLCountDown = vgui.Create("DLabel", self)
	LBLCountDown:SetSize(width, 25)
	LBLCountDown:Dock(TOP)
	LBLCountDown:SetContentAlignment(5)
	LBLCountDown:SetFont("PAM_ExampleFont")
	// make this label recalculate the remaining time every frame
	LBLCountDown.Think = function()
		// PAM.EndsAt is the time at wich the voting will end
		local timeLeft = math.Round(math.max(PAM.EndsAt - CurTime(), 0))
		LBLCountDown:SetText(timeLeft .. " seconds left!")
	end

	// the maplist
	local scrollPanel = vgui.Create("DScrollPanel", self)
	scrollPanel:SetSize(width, height - 25)
	scrollPanel:Dock(FILL)
	local mapList = vgui.Create("DIconLayout", scrollPanel)
	mapList:Dock(FILL)

	// fills the maplist with buttons
	for k, mapinfo in pairs(PAM.Maps) do
		local button = mapList:Add("DButton")
		button.voterCount = 0
		button.map = mapinfo
		button:SetSize(475, 25)
		button:SetContentAlignment(4)
		button:SetFont("PAM_ExampleFont")
		button:SetTextColor(exampleTextColor)
		button.Paint = function(s, w, h) end

		button.Think = function()
			button:SetText(button.map.name .. " (played " .. button.map.playcount .. " times) [" .. tostring(button.voterCount) .. "]")
		end

		button.DoClick = function()
			net.Start("PAM_Vote")
			net.WriteUInt(mapinfo.id, 32)
			net.SendToServer()
		end

		table.insert(self.MapButtons, button)
	end

	// show this menu and enable mouse input
	self:MakePopup()
	self:SetKeyboardInputEnabled(false)
end

// AddVoter gets called every time a player votes.
function PANEL:AddVoter(ply)
	self:UpdateVoters()
end

// AddVoter gets called every time a player stops voting.
function PANEL:RemoveVoter(ply)
	self:UpdateVoters()
end

// helper function to update the votercounts of each mapbutton
function PANEL:UpdateVoters()
	for _, mapButton in pairs(self.MapButtons) do
		mapButton.voterCount = 0
	end

	for steamid, mapid in pairs(PAM.Votes) do
		for _, mapButton in pairs(self.MapButtons) do
			if(mapButton.map.id == mapid) then
				mapButton.voterCount = mapButton.voterCount + 1
			end
		end
	end
end

//helper function
function PANEL:GetMapButton(id)
	for _, button in pairs(self.MapButtons) do
		if button.map.id == id then
			return button
		end
	end
	return false
end

//gets called to announce the winning map
function PANEL:Flash(id)
	self:SetVisible(true)

	//removes all, but the winning button
	for _, button in pairs(self.MapButtons) do
		if(button.map.id != id) then
			button:Remove()
		end
	end

	timer.Create("ttt_pam_notification", 0.4, 3, function()
		surface.PlaySound("hl1/fvox/blip.wav")
	end)
end

derma.DefineControl("ttt_pam_votescreen_example", "", PANEL, "DFrame")
