local name = "default_votescreen"
PAM_EXTENSION.name = name
PAM_EXTENSION.enabled = true

local panel = nil

local scale_setting = PAM.setting_namespace:AddChild(name):AddSetting("scale", pacoman.TYPE_INTEGER, 100)

function PAM_EXTENSION:OnVoteStarted()
	panel = vgui.Create("pam_default_votescreen")
end

function PAM_EXTENSION:OnVoteCanceled()
	panel:Remove()
end

function PAM_EXTENSION:OnVoterAdded(ply, option_id)
	panel:AddVoter(ply, option_id)
end

function PAM_EXTENSION:OnVoterRemoved(ply)
	panel:RemoveVoter(ply)
end

function PAM_EXTENSION:OnWinnerAnnounced()
	panel:AnnounceWinner()
end

function PAM_EXTENSION:ToggleVisibility()
	panel:SetVisible(not panel:IsVisible())
end

function PAM_EXTENSION:OnEnable()
	if PAM.state ~= PAM.STATE_DISABLED then
		self:OnVoteStarted()
		for steam_id, option_id in pairs(PAM.votes) do
			self:OnVoterAdded(player.GetBySteamID(steam_id), option_id)
		end
	end
	if PAM.state == PAM.STATE_FINISHED then
		self:OnWinnerAnnounced()
	end
end

function PAM_EXTENSION:OnDisable()
	if PAM.state ~= PAM.STATE_DISABLED then
		panel:Remove()
	end
end


function PAM_EXTENSION:Initialize()
	local function ScaleChanged(new_scale)
		include("pam/client/extensions/default_votescreen_panel.lua")
		if not self.enabled then return end

		self:OnDisable()
		self:OnEnable()
	end

	scale_setting:AddCallback("default", ScaleChanged)

	include("pam/client/extensions/default_votescreen_panel.lua")
end
