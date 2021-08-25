-- unique name for this extension
local name = "example_votescreen"
PAM_EXTENSION.name = name
PAM_EXTENSION.enabled = false

-- locally stores the panel for easier access
local panel = nil

-- called after the client has received all important information
function PAM_EXTENSION:OnVoteStarted()
	panel = vgui.Create("pam_votescreen_example")
end

-- called after the vote was canceled
function PAM_EXTENSION:OnVoteCanceled()
	panel:Remove()
end

-- called when a player votes
-- ply - the voting player
-- option_id - the id of the option the player voted for
function PAM_EXTENSION:OnVoterAdded(ply, option_id)
	panel:AddVoter(ply, option_id)
end

-- called when a player removes their vote
-- ply - the player who removes their vote
function PAM_EXTENSION:OnVoterRemoved(ply)
	panel:RemoveVoter(ply)
end

-- called after the vote finished
-- option_id - the id of the option that won the vote
function PAM_EXTENSION:OnWinnerAnnounced()
	panel:AnnounceWinner()
end

-- called when the client uses the pam_toggle_menu command
function PAM_EXTENSION:ToggleVisibility()
	panel:SetVisible(not panel:IsVisible())
end

-- called when the player enables this extension via the extension manager
function PAM_EXTENSION:OnEnable()
	if PAM.state != PAM.STATE_DISABLED then
		-- create panel
		self:OnVoteStarted()
		-- add all existing voters
		for steam_id, option_id in pairs(PAM.votes) do
			self:OnVoterAdded(player.GetBySteamID(steam_id), option_id)
		end
	end
	-- announce winner when needed
	if PAM.state == PAM.STATE_FINISHED then
		self:OnWinnerAnnounced()
	end
end

-- called when the player disables this extension via the extension manager
function PAM_EXTENSION:OnDisable()
	if PAM.state != PAM.STATE_DISABLED then
		panel:Remove()
	end
end
