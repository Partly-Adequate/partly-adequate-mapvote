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
	AddCSLuaFile("pam/client/cl_extension_handler.lua")
	AddCSLuaFile("pam/client/cl_extension_manager.lua")
	AddCSLuaFile("pam/client/cl_networking.lua")
	AddCSLuaFile("pam/client/cl_commands.lua")

	AddCSLuaFile("pam/client/extensions/cl_votescreen_dark.lua")
	AddCSLuaFile("pam/client/extensions/cl_votescreen_dark_api.lua")
	AddCSLuaFile("pam/client/extensions/cl_rtv_chat_notifications.lua")
	AddCSLuaFile("pam/client/extensions/cl_default_map_icons.lua")
	AddCSLuaFile("pam/client/extensions/cl_rtv_chat_commands.lua")

	include("pam/server/sv_init.lua")
	include("pam/server/sv_pam.lua")
	include("pam/server/sv_networking.lua")
	include("pam/server/sv_autovote.lua")
else
	include("pam/client/cl_init.lua")
	include("pam/client/cl_pam.lua")
	include("pam/client/cl_extension_handler.lua")
	include("pam/client/cl_extension_manager.lua")
	include("pam/client/cl_networking.lua")
	include("pam/client/cl_commands.lua")

	include("pam/client/extensions/cl_votescreen_dark.lua")
	include("pam/client/extensions/cl_votescreen_dark_api.lua")
	include("pam/client/extensions/cl_rtv_chat_notifications.lua")
	include("pam/client/extensions/cl_default_map_icons.lua")
	include("pam/client/extensions/cl_rtv_chat_commands.lua")
end
