local menu = {}
local panel = nil
menu.id = "Dark Votescreen"
menu.is_enabled = true

function menu.OnVoteStarted()
	panel = vgui.Create("pam_votescreen_dark")
end

function menu.OnVoteCanceled()
	panel:Remove()
end

function menu.OnVoterAdded(ply, map_id)
	panel:AddVoter(ply, map_id)
end

function menu.OnVoterRemoved(ply)
	panel:RemoveVoter(ply)
end

function menu.OnWinnerAnnounced(map_id)
	panel:AnnounceWinner(map_id)
end

function menu.ToggleVisibility()
	panel:SetVisible(not panel:IsVisible())
end

function menu.OnEnable()
	if PAM.state == PAM.STATE_STARTED then
		menu.OnVoteStarted()
		for steam_id, map_id in pairs(PAM.votes) do
			menu.OnVoterAdded(player.GetBySteamID(steam_id), map_id)
		end
	end
end

function menu.OnDisable()
	if PAM.state == PAM.STATE_STARTED then
		panel:Remove()
	end
end

hook.Add("PAM_Register_Client_Extensions", "PAM_Register_Votescreen_Dark", function()
	PAM.RegisterExtension(menu)
end)
