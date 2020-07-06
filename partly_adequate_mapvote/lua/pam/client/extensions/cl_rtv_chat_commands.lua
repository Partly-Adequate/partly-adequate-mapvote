local extension = {}
extension.name = "RTV Chat Commands"
extension.settings = {
	is_enabled = true,
	commands = "rtv,!rtv"
}

hook.Add( "OnPlayerChat", "PAM_RTV_Chat_Commands", function( ply, text, bTeam, bDead )
    if !extension.settings.is_enabled then return end
	if not GetGlobalBool("pam_rtv_enabled") then return end
	if PAM.state != PAM.STATE_DISABLED then return end
    if ply != LocalPlayer() then return end

	local commands = string.Split(extension.settings.commands, ",")

	for i = 1, #commands do
		if text == commands[i] then
			PAM.VoteRTV();
			return true;
		end
	end
end)

hook.Add("PAM_Register_Extensions", "PAM_Register_RTV_Chat_Commands", function()
	PAM.RegisterExtension(extension)
end)
