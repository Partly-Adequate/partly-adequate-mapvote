-- server->all
util.AddNetworkString("PAM_Start")
-- client->server->all
util.AddNetworkString("PAM_Cancel")
-- client->server->all
util.AddNetworkString("PAM_Vote")
-- server->all
util.AddNetworkString("PAM_Announce_Winner")

resource.AddFile("materials/vgui/ttt/pam_ic_missing.vmt")
resource.AddFile("materials/vgui/ttt/pam_ic_menu.vmt")
resource.AddFile("materials/vgui/ttt/pam_map_button.vmt")
resource.AddFile("materials/vgui/ttt/pam_ic_fav.vmt")
resource.AddFile("materials/vgui/ttt/pam_ic_nofav.vmt")

if file.Exists("pam/config.txt", "DATA") then
	PAM.Config = util.JSONToTable(file.Read("pam/config.txt", "DATA"))
end

if file.Exists("pam/recentmaps.txt", "DATA") then
	PAM.RecentMaps = util.JSONToTable(file.Read("pam/recentmaps.txt", "DATA"))
end

if file.Exists("pam/playcounts.txt", "DATA") then
	PAM.Playcounts = util.JSONToTable(file.Read("pam/playcounts.txt", "DATA"))
end

function PAM.Start(vote_length)
	vote_length = vote_length or PAM.Config.VoteLength
	
	local all_maps = file.Find("maps/*.bsp", "GAME")
	
	PAM.Maps = {}
	PAM.Votes = {}

	local amount = 0
	
	for k, map in RandomPairs(all_maps) do
		--don't add too many maps
		if amount == PAM.Config.MaxMapAmount then
			break
		end

		--don't add maps which were played recently
		if table.HasValue(PAM.RecentMaps, map) then
			continue
		end

		--add maps where at least one prefix fits
		for _, prefix in pairs(PAM.Config.MapPrefixes) do
			if string.find(map, prefix) then
				amount = amount + 1
				PAM.Maps[amount] = map:sub(1, -5)
				
				break
			end
		end
	end

	if amount <= 0 then
		amount = 1
		PAM.Maps[amount] = game.GetMap():lower()
	end

	--send start info to all clients
	net.Start("PAM_Start")
	--transmit amount
	net.WriteUInt(amount, 32)
	--transmit mapnames
	
	for i = 1, amount do
		net.WriteString(PAM.Maps[i])
		
		local pc = PAM.Playcounts[PAM.Maps[i]] or 0
		
		net.WriteUInt(pc, 32)
	end
	
	--transmit the length of the vote
	net.WriteUInt(vote_length, 32)
	net.Broadcast()

	PAM.State = PAM.STATE_STARTED

	--timer for ending it after the vote time is over
	timer.Create("PAM_Vote_Timer", vote_length, 1, function()
		PAM.State = PAM.STATE_FINISHED
		
		local vote_results = {}

		for steam_id, map in pairs(PAM.Votes) do
			if not vote_results[map] then
				vote_results[map] = 0
			end

			for _, player in ipairs(player.GetAll()) do
				if player:SteamID() == steam_id then
					vote_results[map] = vote_results[map] + 1
					
					break
				end
			end
		end

		local winning_map_index = table.GetWinningKey(vote_results) or 1

		net.Start("PAM_Announce_Winner")
		net.WriteUInt(winning_map_index, 32)
		net.Broadcast()

		local current_map = game.GetMap():lower()
		
		if not PAM.Playcounts[current_map] then
			PAM.Playcounts[current_map] = 1
		else
			PAM.Playcounts[current_map] = PAM.Playcounts[current_map] + 1
		end
		
		file.Write("pam/playcounts.txt", util.TableToJSON(PAM.Playcounts))

		timer.Simple(4, function()
			RunConsoleCommand("changelevel", PAM.Maps[winning_map_index])
		end)
	end)
end

function PAM.UpdateRecentMaps()
	table.insert(PAM.RecentMaps, game.GetMap():lower() .. ".bsp")
	
	while #PAM.RecentMaps > PAM.Config.MapsBeforeRevote do
		table.remove(PAM.RecentMaps, 1)
	end
	
	file.Write("pam/recentmaps.txt", util.TableToJSON(PAM.RecentMaps))
end

function PAM.Cancel()
	if PAM.State == PAM.STATE_STARTED then
		PAM.State = PAM.STATE_DISABLED
		
		net.Start("PAM_Cancel")
		net.Broadcast()
		
		timer.Remove("PAM_Vote_Timer")
	end
end

net.Receive("PAM_Vote", function(len, ply)
	if PAM.State == PAM.STATE_STARTED and IsValid(ply) then
		local map_id = net.ReadUInt(32)

		if PAM.Maps[map_id] then
			PAM.Votes[ply:SteamID()] = map_id

			net.Start("PAM_Vote")
			net.WriteEntity(ply)
			net.WriteUInt(map_id, 32)
			net.Broadcast()
		end
	end
end)
