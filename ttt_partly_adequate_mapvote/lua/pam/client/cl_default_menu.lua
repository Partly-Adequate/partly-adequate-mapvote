local menu = {}
local panel = nil

function menu.OnVoteStarted()
	panel = vgui.Create("ttt_pam_votescreen_default")
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

function menu.Toggle()
	panel:SetVisible(not panel:IsVisible())
end

-- TODO make a hook for this after all lua files have been loaded
PAM.menu = menu
