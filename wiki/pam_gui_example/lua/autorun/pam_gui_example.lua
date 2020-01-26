if SERVER then
	AddCSLuaFile("pam/client/cl_votescreen_example.lua")
	AddCSLuaFile("pam/client/cl_votescreen_example_api.lua")
else
	include("pam/client/cl_votescreen_example.lua")
	include("pam/client/cl_votescreen_example_api.lua")
end
