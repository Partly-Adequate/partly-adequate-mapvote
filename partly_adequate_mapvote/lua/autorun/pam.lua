if SERVER then
	AddCSLuaFile()

	AddCSLuaFile("includes/modules/pacoman.lua")
	AddCSLuaFile("pam/sh_init.lua")
	AddCSLuaFile("pam/client/cl_init.lua")
	AddCSLuaFile("pam/client/cl_pam.lua")
	AddCSLuaFile("pam/sh_extension_handler.lua")
	AddCSLuaFile("pam/client/cl_extension_handler.lua")
	AddCSLuaFile("pam/client/cl_networking.lua")
	AddCSLuaFile("pam/client/cl_commands.lua")
	AddCSLuaFile("pam/client/cl_pacoman_ui.lua")

	include("pam/sh_init.lua")
	include("pam/server/sv_init.lua")
	include("pam/server/sv_pam.lua")
	include("pam/sh_extension_handler.lua")
	include("pam/server/sv_extension_handler.lua")
	include("pam/server/sv_networking.lua")

	-- add resources
	resource.AddFile("materials/vgui/pam/img_missing.vmt")
	resource.AddFile("materials/vgui/pam/img_random_option.vmt")
	resource.AddFile("materials/vgui/pam/img_change_gamemode.vmt")
	resource.AddFile("materials/vgui/pam/ic_favorite.vmt")
	resource.AddFile("materials/vgui/pam/ic_not_favorite.vmt")
	resource.AddFile("materials/vgui/pam/ic_selected.vmt")
	resource.AddFile("materials/vgui/pam/ic_not_selected.vmt")
else
	include("pam/sh_init.lua")
	include("pam/client/cl_init.lua")
	include("pam/client/cl_pam.lua")
	include("pam/sh_extension_handler.lua")
	include("pam/client/cl_extension_handler.lua")
	include("pam/client/cl_networking.lua")
	include("pam/client/cl_commands.lua")
	include("pam/client/cl_pacoman_ui.lua")
end
