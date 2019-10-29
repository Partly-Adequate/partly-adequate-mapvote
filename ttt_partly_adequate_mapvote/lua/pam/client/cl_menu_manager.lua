local menus = {}
local gui_count = 0

function PAM.RegisterMenu(name, gui)
	print('[PAM] Registering votescreen "' .. name .. '"')
	gui_count = gui_count + 1
	menus[gui_count] = {name = name, menu = gui}
end

function PAM.EnableMenu(id)
	for _, menu in pairs(menus) do
		if menu.name == id then
			if IsValid(PAM.menu) then
				PAM.menu.OnDisable()
			end
			PAM.menu = menu
			PAM.menu.OnEnable()
			break
		end
	end
end

hook.Add("Initialize", "PAM_GuiManager", function()
	hook.Run("PAM_Register_Menus")
end)
