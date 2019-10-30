local menu = {}
local panel = nil

function menu.OnVoteStarted()
	panel = vgui.Create("pam_votescreen_default")
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

end

function menu.OnDisable()

end

PAM.RegisterMenu("Default", menu)
