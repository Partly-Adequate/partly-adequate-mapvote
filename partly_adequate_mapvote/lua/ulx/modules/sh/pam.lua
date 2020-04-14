local CATEGORY_NAME = "PAM"

local function StartPAM(calling_ply)
	if(PAM.state == PAM.STATE_DISABLED) then
		PAM.Start()
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
pamstartcmd:defaultAccess(ULib.ACCESS_ADMIN)
pamstartcmd:help("starts a map vote")

local pamcancelcmd = ulx.command(CATEGORY_NAME, "pam_cancel", CancelPAM, "!pam_cancel")
pamcancelcmd:defaultAccess(ULib.ACCESS_ADMIN)
pamcancelcmd:help("cancels the current map vote")
