local CATEGORY_NAME = "PAM"

------------------------------ partly adequate mapvote ------------------------------
function TogglePAM(calling_ply, votetime, should_cancel)
	if not should_cancel then
		PAM.Start(votetime)
		ulx.fancyLogAdmin(calling_ply, "#A called a mapvote!")
	else
		PAM.Cancel()
		ulx.fancyLogAdmin(calling_ply, "#A canceled the mapvote!")
	end
end

local pamcmd = ulx.command(CATEGORY_NAME, "mapvote", TogglePAM, "!mapvote")
pamcmd:addParam{ type = ULib.cmds.NumArg, min = 20, default = 30, hint = "time", ULib.cmds.optional, ULib.cmds.round }
pamcmd:addParam{ type = ULib.cmds.BoolArg, invisible = true }
pamcmd:defaultAccess(ULib.ACCESS_ADMIN)
pamcmd:help("Invokes the map vote logic")
pamcmd:setOpposite("unmapvote", {_, _, true}, "!unmapvote")
