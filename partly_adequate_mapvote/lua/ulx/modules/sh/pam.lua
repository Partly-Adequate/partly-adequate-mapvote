local CATEGORY_NAME = "PAM"

local function StartPAM(calling_ply, vote_length, allow_all_maps)
	if(PAM.state == PAM.STATE_DISABLED) then
		PAM.Start(vote_length, allow_all_maps)
		ulx.fancyLogAdmin(calling_ply, "#A started a mapvote!")
	end
end

local function CancelPAM(calling_ply)
	if(PAM.state == PAM.STATE_STARTED) then
		PAM.Cancel()
		ulx.fancyLogAdmin(calling_ply, "#A canceled the mapvote!")
	end
end

local pamstartcmd = ulx.command(CATEGORY_NAME, "pam_start", StartPAM, "!pam_start")
pamstartcmd:addParam{ type = ULib.cmds.NumArg, default = 30, hint = "length", ULib.cmds.optional, ULib.cmds.round }
pamstartcmd:addParam{ type = ULib.cmds.BoolArg, default = false, hint = "allow all maps", ULib.cmds.optional, ULib.cmds.round }
pamstartcmd:defaultAccess(ULib.ACCESS_ADMIN)
pamstartcmd:help("starts a map vote")

local pamcancelcmd = ulx.command(CATEGORY_NAME, "pam_cancel", CancelPAM, "!pam_cancel")
pamcancelcmd:addParam{ type = ULib.cmds.BoolArg, invisible = true }
pamcancelcmd:defaultAccess(ULib.ACCESS_ADMIN)
pamcancelcmd:help("cancels the current map vote")
