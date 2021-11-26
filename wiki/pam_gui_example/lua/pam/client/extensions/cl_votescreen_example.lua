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

	-- stores all optionbuttons for easier access
	self.option_buttons = {}

	-- the countdown label
	local lbl_countdown = vgui.Create("DLabel", self)
	lbl_countdown:SetSize(width, 25)
	lbl_countdown:Dock(TOP)
	lbl_countdown:SetContentAlignment(5)
	lbl_countdown:SetFont("PAM_ExampleFont")
	-- The Countdown updates itself every frame this way
	lbl_countdown.Think = function()
		-- PAM.ends_at stores the time the vote will end at
		-- This calculates the remaining time
		local time_remaining = math.Round(math.max(PAM.ends_at - CurTime(), 0))
		lbl_countdown:SetText(time_remaining .. " seconds left!")
	end

	-- container for the option list
	local sp_container = vgui.Create("DScrollPanel", self)
	sp_container:SetSize(width, height - 25)
	sp_container:Dock(FILL)
	-- the option list
	local dil_option_list = vgui.Create("DIconLayout", sp_container)
	dil_option_list:Dock(FILL)

	-- this creates one button for each otion and adds them to self.option_buttons and the option list
	-- option_info is a table containing the following values:
	--	- id -> unique identifier
	--	- name -> the option name
	--	- pickcount -> the amount of times this option has been picked
	for i = 1, #PAM.options do
		local option_info = PAM.options[i]
		-- creates a new button inside the option list
		local option_button = dil_option_list:Add("DButton")

		-- caches the amount of voters on the assigned option
		option_button.voter_count = 0
		-- the option_info
		option_button.option_info = option_info

		-- basic settings
		option_button:SetSize(475, 25)
		option_button:SetContentAlignment(4)
		option_button:SetFont("PAM_ExampleFont")
		option_button:SetTextColor(example_text_color)
		option_button.Paint = function(s, w, h) end

		-- updates the button name every frame to show the current amount of voters
		option_button.Think = function()
			option_button:SetText(option_info.name .. " (picked " .. option_info.pick_count .. " times) [" .. tostring(option_button.voter_count) .. "]")
		end

		option_button.DoClick = function()
			-- This makes the local player vote for the assigned option
			PAM.Vote(option_info.id)
		end

		-- Adds this button to the option buttons for better access
		self.option_buttons[#self.option_buttons + 1] = option_button
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
	for i = 1, #self.option_buttons do
		self.option_buttons[i].voter_count = 0
	end

	-- add votercounts to the correct option buttons for each voter
	for steamid, option_id in pairs(PAM.votes) do
		for i = 1, #self.option_buttons do
			local option_button = self.option_buttons[i]
			if option_button.option_info.id == option_id then
				option_button.voter_count = option_button.voter_count + 1
			end
		end
	end
end

-- announces the winner
function PANEL:AnnounceWinner()
	-- shows the panel
	self:SetVisible(true)

	-- deletes all buttons but the winner
	for i = 1, #self.option_buttons do
		local option_button = self.option_buttons[i]
		if option_button.option_info.id ~= PAM.winning_option_id then
			option_button:Remove()
		end
	end
end

derma.DefineControl("pam_votescreen_example", "", PANEL, "DFrame")
