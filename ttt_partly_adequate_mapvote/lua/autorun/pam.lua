PAM = {}

--the possible states
--for when it hasn't started yet
PAM.STATE_DISABLED = 0

--for when voting is possible
PAM.STATE_STARTED = 1

--for when the winner is announced
PAM.STATE_FINISHED = 2

--the current state
PAM.State = PAM.STATE_DISABLED

--the voteable maps
PAM.Maps = {}

--the votes
PAM.Votes = {}

if not file.Exists("pam", "DATA") then
	file.CreateDir("pam")
end

if not file.Exists("pam/config.txt", "DATA") then
	file.Write("pam/config.txt", util.TableToJSON(PAM.CONFIG_DEFAULT))
end

if not file.Exists("pam/rtv_config.txt", "DATA") then
	file.Write("pam/rtv_config.txt", util.TableToJSON(PAM.RTV_CONFIG_DEFAULT))
end

if SERVER then
	AddCSLuaFile()

	AddCSLuaFile("pam/client/cl_init.lua")
	AddCSLuaFile("pam/client/cl_gui.lua")
	AddCSLuaFile("pam/client/cl_networking.lua")
	AddCSLuaFile("pam/client/cl_commands.lua")

	include("pam/server/sv_init.lua")
	include("pam/server/sv_pam.lua")
	include("pam/server/sv_networking.lua")
else
	include("pam/client/cl_init.lua")
	include("pam/client/cl_gui.lua")
	include("pam/client/cl_networking.lua")
	include("pam/client/cl_commands.lua")
end
