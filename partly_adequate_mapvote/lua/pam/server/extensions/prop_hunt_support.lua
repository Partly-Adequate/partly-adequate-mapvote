PAM_EXTENSION.name = "prop_hunt_support"
PAM_EXTENSION.enabled = true

function PAM_EXTENSION:OnInitialize()
	if GAMEMODE_NAME ~= "prop_hunt" then return end

	-- prop-hunt-enhanced/prop-hunt-enhanced
	-- Reconstructing MiRe's MapVote api since prop-hunt-enhanced shamelessly copied it's code.
	MapVote = MapVote or {}
	MapVote.Start = function()
		PAM.Start()
	end
	MapVote.Cancel = function()
		PAM.Cancel()
	end


	-- overriding the rtv system
	RTV = RTV or {}
	RTV.StartVote = function() return end
	RTV.AddVote = function() return end


	-- Notify PAM that the round has ended
	hook.Add("PH_RoundEnd", "PAM_RoundEnded", function()
		PAM.EndRound()
	end)


	-- convar deprecation information
	local function deprecation_warning()
		print("[PAM] This convar is no longer used")
	end

	cvars.AddChangeCallback("mv_maplimit", deprecation_warning)
	cvars.AddChangeCallback("mv_timelimit", deprecation_warning)
	cvars.AddChangeCallback("mv_change_when_no_player", deprecation_warning)
	cvars.AddChangeCallback("mv_allowcurmap", deprecation_warning)
	cvars.AddChangeCallback("mv_use_ulx_votemaps", deprecation_warning)
	cvars.AddChangeCallback("mv_cooldown", deprecation_warning)
	cvars.AddChangeCallback("mv_mapbeforerevote", deprecation_warning)
	cvars.AddChangeCallback("mv_rtvcount", deprecation_warning)
	cvars.AddChangeCallback("mv_mapprefix", deprecation_warning)
end
