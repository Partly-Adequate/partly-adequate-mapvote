if SERVER then
	AddCSLuaFile("pam/client/cl_example_votescreen.lua")
	AddCSLuaFile("pam/client/cl_example_menu.lua")
else
	include("pam/client/cl_example_votescreen.lua")
	include("pam/client/cl_example_menu.lua")
end
