hook.Add("PAM_OnVoteStarted", "PAM_OnVoteStarted_Example", function()
	PAM.Panel = vgui.Create("ttt_pam_votescreen_example")

	// cancel default action
	return true
end)

hook.Add("PAM_OnPlayerVoted", "PAM_OnPlayerVoted_Example", function(ply, mapID)
	PAM.Panel:AddVoter(ply, mapID)

	// cancel default action
	return true
end)

hook.Add("PAM_OnPlayerUnVoted", "PAM_OnPlayerUnVoted_Example", function(ply)
	PAM.Panel:RemoveVoter(ply)

	// cancel default action
	return true
end)

hook.Add("PAM_OnWinnerAnnounced", "PAM_OnWinnerAnnounced_Example", function(mapID)
	PAM.Panel:AnnounceWinner(mapID)

	// cancel default action
	return true
end)

hook.Add("PAM_Cancel", "PAM_Cancel_Example", function()
	PAM.Panel:Remove()

	// cancel default action
	return true
end)

hook.Add("PAM_OnMenuToggled", "PAM_OnMenuToggled_Example", function()
	PAM.Panel:SetVisible(not PAM.Panel:IsVisible())
	// cancel default action
	return true
end)
