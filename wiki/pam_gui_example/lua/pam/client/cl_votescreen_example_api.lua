local extension = {}
-- locally stores the panel for easier access
local panel = nil

-- unique name for this extension
extension.name = "Example Votescreen"
-- default state
extension.is_enabled = false

-- called after the client has received all important information
function extension.OnVoteStarted()
	panel = vgui.Create("pam_votescreen_example")
end

-- called after the vote was canceled
function extension.OnVoteCanceled()
	panel:Remove()
end

-- called when a player votes
-- ply - the voting player
-- map_id - the id of the map the player voted for
function extension.OnVoterAdded(ply, map_id)
	panel:AddVoter(ply, map_id)
end

-- called when a player removes their vote
-- ply - the player who removes their vote
function extension.OnVoterRemoved(ply)
	panel:RemoveVoter(ply)
end

-- called after the vote finished
-- map_id - the id of the map that won the vote
function extension.OnWinnerAnnounced(map_id)
	panel:AnnounceWinner(map_id)
end

-- called when the client uses the pam_toggle_menu command
function extension.ToggleVisibility()
	panel:SetVisible(not panel:IsVisible())
end

-- called when the player enables this extension via the extension manager
function extension.OnEnable()
	if PAM.state != PAM.STATE_DISABLED then
		-- create panel
		extension.OnVoteStarted()
		-- add all existing voters
		for steam_id, map_id in pairs(PAM.votes) do
			extension.OnVoterAdded(player.GetBySteamID(steam_id), map_id)
		end
	end
	-- announce winner when needed
	if PAM.state == PAM.STATE_FINISHED then
		extension.OnWinnerAnnounced()
	end
end

-- called when the player disables this extension via the extension manager
function extension.OnDisable()
	if PAM.state != PAM.STATE_DISABLED then
		panel:Remove()
	end
end

-- PAM_Register_extensions hook is used for registering this extension
hook.Add("PAM_Register_Client_Extensions", "PAM_Register_Example_Votescreen", function()
	PAM.RegisterExtension(extension)
end)
