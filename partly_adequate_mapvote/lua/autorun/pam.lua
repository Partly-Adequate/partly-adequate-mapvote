PAM = {}

--the possible states
--for when it hasn't started yet
PAM.STATE_DISABLED = 0
--for when voting is possible
PAM.STATE_STARTED = 1
--for when the winner is announced
PAM.STATE_FINISHED = 2

--the current state
PAM.state = PAM.STATE_DISABLED

--the voteable maps
PAM.maps = {}

--the votes
PAM.votes = {}

if not file.Exists("pam", "DATA") then
	file.CreateDir("pam")
end

if SERVER then
	AddCSLuaFile()

	AddCSLuaFile("pam/client/cl_init.lua")
	AddCSLuaFile("pam/client/cl_pam.lua")
	AddCSLuaFile("pam/client/gui/cl_default_votescreen.lua")
	AddCSLuaFile("pam/client/gui/cl_default_menu.lua")
	AddCSLuaFile("pam/client/gui/cl_menu_manager.lua")
	AddCSLuaFile("pam/client/cl_networking.lua")
	AddCSLuaFile("pam/client/cl_commands.lua")

	include("pam/server/sv_init.lua")
	include("pam/server/sv_pam.lua")
	include("pam/server/sv_networking.lua")
	include("pam/server/sv_autovote")
else
	include("pam/client/cl_init.lua")
	include("pam/client/cl_pam.lua")
	include("pam/client/gui/cl_default_votescreen.lua")
	include("pam/client/gui/cl_default_menu.lua")
	include("pam/client/gui/cl_menu_manager.lua")
	include("pam/client/cl_networking.lua")
	include("pam/client/cl_commands.lua")
end
