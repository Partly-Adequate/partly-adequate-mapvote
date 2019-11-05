PANEL = {}

// Example Font
surface.CreateFont("PAM_ExampleFont", {
	font = "Trebuchet MS",
	size = 20
})

// Example Text Color
local exampleTextColor = {r = 255, g = 255, b = 255, a = 200}

function PANEL:Init()
	// Basic Settings
	local width = 500
	local height = ScrH() * 0.75
	self:SetSize(width, height)
	self:SetPos((ScrW() - width) * 0.5, (ScrH() - height) * 0.5)
	self:SetZPos(-100)
	self:SetTitle("Partly Adequate Mapvote GUI Example")
	self:SetDeleteOnClose(false)

	// stores all mapbuttons for easier access
	self.MapButtons = {}

	// the countdown label
	local LBLCountDown = vgui.Create("DLabel", self)
	LBLCountDown:SetSize(width, 25)
	LBLCountDown:Dock(TOP)
	LBLCountDown:SetContentAlignment(5)
	LBLCountDown:SetFont("PAM_ExampleFont")
	// The Countdown updates itself every frame this way
	LBLCountDown.Think = function()
		// PAM.EndsAt stores the time the mapvote will end at
		// This calculates the remaining time
		local timeLeft = math.Round(math.max(PAM.EndsAt - CurTime(), 0))
		LBLCountDown:SetText(timeLeft .. " seconds left!")
	end

	// container for the maplist
	local scrollPanel = vgui.Create("DScrollPanel", self)
	scrollPanel:SetSize(width, height - 25)
	scrollPanel:Dock(FILL)
	// the maplist
	local mapList = vgui.Create("DIconLayout", scrollPanel)
	mapList:Dock(FILL)

	// this creates one button for each map and adds them to self.MapButtons and the mapList
	// mapinfo is a table containing the following values:
	//   - id -> unique identifier
	//   - name -> the map name
	//   - playcount -> the amount of times this map has been played
	for k, mapinfo in pairs(PAM.Maps) do
		// creates a new button inside the maplist
		local button = mapList:Add("DButton")

		// caches the amount of voters on the assigned map
		button.voterCount = 0
		// the mapinfo
		button.map = mapinfo

		// basic settings
		button:SetSize(475, 25)
		button:SetContentAlignment(4)
		button:SetFont("PAM_ExampleFont")
		button:SetTextColor(exampleTextColor)
		button.Paint = function(s, w, h) end

		// updates the button name every frame to show the current amount of voters
		button.Think = function()
			button:SetText(button.map.name .. " (played " .. button.map.playcount .. " times) [" .. tostring(button.voterCount) .. "]")
		end

		button.DoClick = function()
			// This makes the local player vote for the assigned map
			net.Start("PAM_Vote")
			net.WriteUInt(mapinfo.id, 32)
			net.SendToServer()
		end

		// Adds this button to the MapButtons for better access
		table.insert(self.MapButtons, button)
	end

	// get mouse focus
	self:MakePopup()
	self:SetKeyboardInputEnabled(false)
end

// Updates all buttons votercounts when called
function PANEL:AddVoter(ply, id)
	self:UpdateVoters()
end

// Updates all buttons votercounts when called
function PANEL:RemoveVoter(ply)
	self:UpdateVoters()
end

// Updates all buttons votercounts when called
function PANEL:UpdateVoters()
	// reset all votercounts
	for _, mapButton in pairs(self.MapButtons) do
		mapButton.voterCount = 0
	end

	// add votercountsto the correct map buttons for each voter
	for steamid, mapid in pairs(PAM.Votes) do
		for _, mapButton in pairs(self.MapButtons) do
			if(mapButton.map.id == mapid) then
				mapButton.voterCount = mapButton.voterCount + 1
			end
		end
	end
end

// announces the winner
function PANEL:AnnounceWinner(id)
	// shows the panel
	self:SetVisible(true)

	// deletes all buttons but the winner
	for _, button in pairs(self.MapButtons) do
		if(button.map.id != id) then
			button:Remove()
		end
	end

	// plays a sound
	timer.Create("ttt_pam_notification", 0.4, 3, function()
		surface.PlaySound("hl1/fvox/blip.wav")
	end)
end

derma.DefineControl("pam_votescreen_example", "", PANEL, "DFrame")
