if SERVER then
	AddCSLuaFile()

	AddCSLuaFile("pam/sh_init.lua")
	AddCSLuaFile("pam/client/cl_init.lua")
	AddCSLuaFile("pam/client/cl_pam.lua")
	AddCSLuaFile("pam/sh_extension_handler.lua")
	AddCSLuaFile("pam/client/cl_networking.lua")
	AddCSLuaFile("pam/client/cl_commands.lua")

	include("pam/sh_init.lua")
	include("pam/server/sv_init.lua")
	include("pam/server/sv_pam.lua")
	include("pam/sh_extension_handler.lua")
	include("pam/server/sv_networking.lua")

	-- add resources
	resource.AddFile("materials/vgui/pam/img_missing.vmt")
	resource.AddFile("materials/vgui/pam/ic_favorite.vmt")
	resource.AddFile("materials/vgui/pam/ic_not_favorite.vmt")
	resource.AddFile("materials/vgui/pam/ic_selected.vmt")
	resource.AddFile("materials/vgui/pam/ic_not_selected.vmt")

	-- add special option resources
	local special_icons = file.Find("materials/vgui/pam/special_options/*.vmt", "GAME")
	for i = 1, #special_icons do
		resource.AddFile("materials/vgui/pam/special_options/" .. special_icons[i])
	end
else
	include("pam/sh_init.lua")
	include("pam/client/cl_init.lua")
	include("pam/client/cl_pam.lua")
	include("pam/sh_extension_handler.lua")
	include("pam/client/cl_networking.lua")
	include("pam/client/cl_commands.lua")
end
