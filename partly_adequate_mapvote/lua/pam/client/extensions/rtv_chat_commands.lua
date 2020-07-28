local extension = {}
extension.name = "rtv_chat_commands"
extension.enabled = true
extension.settings = {
	rtv_commands = "!rtv,rtv"
}

hook.Add( "OnPlayerChat", "PAM_RTV_Chat_Commands", function( ply, text, bTeam, bDead )
    if !extension.enabled then return end
	if not GetGlobalBool("pam_rtv_enabled") then return end
	if PAM.state != PAM.STATE_DISABLED then return end
    if ply != LocalPlayer() then return end

	local commands = string.Split(extension.settings.rtv_commands, ",")

	for i = 1, #commands do
		if text == commands[i] then
			PAM.VoteRTV();
			return true;
		end
	end
end)

PAM.RegisterExtension(extension)
