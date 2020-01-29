local extension = {}
local panel = nil
extension.name = "Dark Votescreen"
extension.is_enabled = true

function extension.OnVoteStarted()
	panel = vgui.Create("pam_votescreen_dark")
end

function extension.OnVoteCanceled()
	panel:Remove()
end

function extension.OnVoterAdded(ply, map_id)
	panel:AddVoter(ply, map_id)
end

function extension.OnVoterRemoved(ply)
	panel:RemoveVoter(ply)
end

function extension.OnWinnerAnnounced()
	panel:AnnounceWinner()
end

function extension.ToggleVisibility()
	panel:SetVisible(not panel:IsVisible())
end

function extension.OnEnable()
	if PAM.state != PAM.STATE_DISABLED then
		extension.OnVoteStarted()
		for steam_id, map_id in pairs(PAM.votes) do
			extension.OnVoterAdded(player.GetBySteamID(steam_id), map_id)
		end
	end
	if PAM.state == PAM.STATE_FINISHED then
		extension.OnWinnerAnnounced()
	end
end

function extension.OnDisable()
	if PAM.state != PAM.STATE_DISABLED then
		panel:Remove()
	end
end

hook.Add("PAM_Register_Client_Extensions", "PAM_Register_Votescreen_Dark", function()
	PAM.RegisterExtension(extension)
end)
