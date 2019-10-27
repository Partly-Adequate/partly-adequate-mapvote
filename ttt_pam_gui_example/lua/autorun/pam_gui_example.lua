if SERVER then
	AddCSLuaFile("pam/client/cl_gui_example.lua")
	AddCSLuaFile("pam/client/cl_gui_example_api.lua")
else
	include("pam/client/cl_gui_example.lua")
	include("pam/client/cl_gui_example_api.lua")
end
