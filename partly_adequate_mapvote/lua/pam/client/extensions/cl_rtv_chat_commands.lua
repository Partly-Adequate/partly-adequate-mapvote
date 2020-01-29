local extension = {}
extension.name = "RTV Chat Commands"
extension.is_enabled = true

-- TODO config for commands
local rtv_commands = {["rtv"] = true, ["!rtv"] = true}

hook.Add( "OnPlayerChat", "PAM_RTV_Chat_Commands", function( ply, text, bTeam, bDead )
    if ply != LocalPlayer() then return end
    if !extension.is_enabled then return end
	if PAM.state != PAM.STATE_DISABLED then return end
	-- TODO Check if RTV is enabled

	if rtv_commands[string.lower(text)] then 
		PAM.VoteRTV();
		return true;
	end
end)

hook.Add("PAM_Register_Client_Extensions", "PAM_Register_RTV_Chat_Commands", function()
	PAM.RegisterExtension(extension)
end)
