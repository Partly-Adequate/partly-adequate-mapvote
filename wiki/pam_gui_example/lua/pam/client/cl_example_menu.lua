local menu = {}
-- locally stores the panel for easier access
local panel = nil

-- unique identifier for this menu
menu.id = "Example"
-- default state
menu.is_enabled = false

-- called after the client has received all important information
function menu.OnVoteStarted()
	panel = vgui.Create("pam_votescreen_example")
end

-- called after the vote was canceled
function menu.OnVoteCanceled()
	panel:Remove()
end

-- called when a player votes
-- ply - the voting player
-- map_id - the id of the map the player voted for
function menu.OnVoterAdded(ply, map_id)
	panel:AddVoter(ply, map_id)
end

-- called when a player removes their vote
-- ply - the player who removes their vote
function menu.OnVoterRemoved(ply)
	panel:RemoveVoter(ply)
end

-- called after the vote finished
-- map_id - the id of the map that won the vote
function menu.OnWinnerAnnounced(map_id)
	panel:AnnounceWinner(map_id)
end

-- called when the client uses the pam_toggle_menu command
function menu.ToggleVisibility()
	panel:SetVisible(not panel:IsVisible())
end

-- called when the player enables this menu via the menu manager
function menu.OnEnable()
	if PAM.state == PAM.STATE_STARTED then
		-- create panel
		menu.OnVoteStarted()
		-- add all existing voters
		for steam_id, map_id in pairs(PAM.votes) do
			menu.OnVoterAdded(player.GetBySteamID(steam_id), map_id)
		end
	end
end

-- called when the player disables this menu via the menu manager
function menu.OnDisable()
	if PAM.state == PAM.STATE_STARTED then
		panel:Remove()
	end
end

-- PAM_Register_Menus hook is used for registering this menu
hook.Add("PAM_Register_Client_Extensions", "PAM_Register_Menus_Example", function()
	PAM.RegisterExtension(menu)
end)
