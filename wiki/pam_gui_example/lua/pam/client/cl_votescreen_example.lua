PANEL = {}

-- Example Font
surface.CreateFont("PAM_ExampleFont", {
	font = "Trebuchet MS",
	size = 20
})

-- Example Text Color
local example_text_color = {r = 255, g = 255, b = 255, a = 200}

function PANEL:Init()
	-- Basic Settings
	local width = 500
	local height = ScrH() * 0.75
	self:SetSize(width, height)
	self:SetPos((ScrW() - width) * 0.5, (ScrH() - height) * 0.5)
	self:SetZPos(-100)
	self:SetTitle("Partly Adequate Mapvote GUI Example")
	self:SetDeleteOnClose(false)

	-- stores all mapbuttons for easier access
	self.map_buttons = {}

	-- the countdown label
	local lbl_countdown = vgui.Create("DLabel", self)
	lbl_countdown:SetSize(width, 25)
	lbl_countdown:Dock(TOP)
	lbl_countdown:SetContentAlignment(5)
	lbl_countdown:SetFont("PAM_ExampleFont")
	-- The Countdown updates itself every frame this way
	lbl_countdown.Think = function()
		-- PAM.ends_at stores the time the mapvote will end at
		-- This calculates the remaining time
		local time_remaining = math.Round(math.max(PAM.ends_at - CurTime(), 0))
		lbl_countdown:SetText(time_remaining .. " seconds left!")
	end

	-- container for the maplist
	local sp_container = vgui.Create("DScrollPanel", self)
	sp_container:SetSize(width, height - 25)
	sp_container:Dock(FILL)
	-- the maplist
	local dil_map_list = vgui.Create("DIconLayout", sp_container)
	dil_map_list:Dock(FILL)

	-- this creates one button for each map and adds them to self.MapButtons and the mapList
	-- mapinfo is a table containing the following values:
	--   - id -> unique identifier
	--   - name -> the map name
	--   - playcount -> the amount of times this map has been played
	for k, mapinfo in pairs(PAM.maps) do
		-- creates a new button inside the maplist
		local button = dil_map_list:Add("DButton")

		-- caches the amount of voters on the assigned map
		button.voter_count = 0
		-- the mapinfo
		button.map = mapinfo

		-- basic settings
		button:SetSize(475, 25)
		button:SetContentAlignment(4)
		button:SetFont("PAM_ExampleFont")
		button:SetTextColor(example_text_color)
		button.Paint = function(s, w, h) end

		-- updates the button name every frame to show the current amount of voters
		button.Think = function()
			button:SetText(button.map.name .. " (played " .. button.map.playcount .. " times) [" .. tostring(button.voter_count) .. "]")
		end

		button.DoClick = function()
			-- This makes the local player vote for the assigned map
			net.Start("PAM_Vote")
			net.WriteUInt(mapinfo.id, 32)
			net.SendToServer()
		end

		-- Adds this button to the MapButtons for better access
		table.insert(self.map_buttons, button)
	end

	-- get mouse focus
	self:MakePopup()
	self:SetKeyboardInputEnabled(false)
end

-- Updates all buttons votercounts when called
function PANEL:AddVoter(ply, id)
	self:UpdateVoters()
end

-- Updates all buttons votercounts when called
function PANEL:RemoveVoter(ply)
	self:UpdateVoters()
end

-- Updates all buttons votercounts when called
function PANEL:UpdateVoters()
	-- reset all votercounts
	for _, mapButton in pairs(self.map_buttons) do
		mapButton.voter_count = 0
	end

	-- add votercountsto the correct map buttons for each voter
	for steamid, mapid in pairs(PAM.votes) do
		for _, mapButton in pairs(self.map_buttons) do
			if(mapButton.map.id == mapid) then
				mapButton.voter_count = mapButton.voter_count + 1
			end
		end
	end
end

-- announces the winner
function PANEL:AnnounceWinner()
	-- shows the panel
	self:SetVisible(true)

	-- deletes all buttons but the winner
	for _, button in pairs(self.map_buttons) do
		if(button.map.id != PAM.winning_map_id) then
			button:Remove()
		end
	end
end

derma.DefineControl("pam_votescreen_example", "", PANEL, "DFrame")
