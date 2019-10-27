if SERVER then
	AddCSLuaFile("pam/client/cl_gui_example.lua")
else
	include("pam/client/cl_gui_example.lua")

	hook.Add("PAM_LoadGUI", "PAM_LoadGUIExample", function()
		return vgui.Create("ttt_pam_votescreen_example")
	end)
end
