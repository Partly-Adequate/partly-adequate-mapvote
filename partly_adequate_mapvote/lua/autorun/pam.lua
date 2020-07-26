if SERVER then
	AddCSLuaFile()
	AddCSLuaFile("pam/sh_init.lua")

	AddCSLuaFile("pam/client/cl_init.lua")
	AddCSLuaFile("pam/client/cl_pam.lua")
	AddCSLuaFile("pam/sh_extension_handler.lua")
	AddCSLuaFile("pam/client/cl_extension_handler.lua")
	AddCSLuaFile("pam/client/cl_networking.lua")
	AddCSLuaFile("pam/client/cl_commands.lua")

	AddCSLuaFile("pam/client/extensions/cl_default_votescreen.lua")
	AddCSLuaFile("pam/client/extensions/cl_default_votescreen_panel.lua")
	AddCSLuaFile("pam/client/extensions/cl_rtv_chat_notifications.lua")
	AddCSLuaFile("pam/client/extensions/cl_default_map_icons.lua")
	AddCSLuaFile("pam/client/extensions/cl_rtv_chat_commands.lua")

	include("pam/sh_init.lua")
	include("pam/server/sv_init.lua")
	include("pam/server/sv_pam.lua")
	include("pam/sh_extension_handler.lua")
	include("pam/server/sv_extension_handler.lua")
	include("pam/server/sv_networking.lua")
	include("pam/server/sv_autovote.lua")
else
	include("pam/sh_init.lua")

	include("pam/client/cl_init.lua")
	include("pam/client/cl_pam.lua")
	include("pam/sh_extension_handler.lua")
	include("pam/client/cl_extension_handler.lua")
	include("pam/client/cl_networking.lua")
	include("pam/client/cl_commands.lua")

	include("pam/client/extensions/cl_default_votescreen.lua")
	include("pam/client/extensions/cl_default_votescreen_panel.lua")
	include("pam/client/extensions/cl_rtv_chat_notifications.lua")
	include("pam/client/extensions/cl_default_map_icons.lua")
	include("pam/client/extensions/cl_rtv_chat_commands.lua")
end
