function PAM.Start(vote_length, allow_all_maps)
	print("pam started")
	vote_length = vote_length or PAM.config.vote_length
	local all_maps = file.Find("maps/*.bsp", "GAME")

	table.Empty(PAM.maps)
	table.Empty(PAM.votes)
	table.Empty(PAM.players_wanting_rtv)

	local map_amount = 0

	local function AddMap(map)
		map_amount = map_amount + 1
		PAM.maps[map_amount] = map:sub(1, -5)
	end

	for _, map in RandomPairs(all_maps) do
		-- don't add too many maps
		if (not allow_all_maps) and map_amount >= PAM.config.max_map_amount then
			break
		end

		-- don't add maps which were played recently
		if (not allow_all_maps) and table.HasValue(PAM.recent_maps, map) then
			continue
		end

		-- don't add blacklisted maps
		-- if table.HasValue(PAM.map_blacklist, map) then
		-- 	continue
		-- end

		-- add whitelisted maps
		-- if table.HasValue(PAM.map_whitelist, map) then
		-- 	AddMap(map)
		-- 	continue
		-- end

		--add maps where at least one prefix fits
		for _, prefix in pairs(PAM.config.map_prefixes) do
			if string.find(map, prefix) then
				AddMap(map)
				break
			end
		end
	end

	if map_amount <= 0 then
		AddMap(game.GetMap():lower())
	end

	-- send start info to all clients
	net.Start("PAM_Start")
	-- transmit amount of maps
	net.WriteUInt(map_amount, 32)
	-- transmit map information
	for i = 1, map_amount do
		net.WriteString(PAM.maps[i])
		local times_played = PAM.playcounts[PAM.maps[i]] or 0
		net.WriteUInt(times_played, 32)
	end

	-- transmit the length of the vote
	net.WriteUInt(vote_length, 32)
	net.Broadcast()

	PAM.state = PAM.STATE_STARTED

	--timer for ending it after the vote time is over
	timer.Create("PAM_Vote_Timer", vote_length, 1, function()
		PAM.state = PAM.STATE_FINISHED

		local vote_results = {}

		for steam_id, map in pairs(PAM.votes) do
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

		PAM.UpdateRecentMaps(PAM.maps[winning_map_index])

		timer.Simple(4, function()
			RunConsoleCommand("changelevel", PAM.maps[winning_map_index])
		end)
	end)
end

function PAM.UpdateRecentMaps(new_map)
	if not PAM.playcounts[new_map] then
		PAM.playcounts[new_map] = 1
	else
		PAM.playcounts[new_map] = PAM.playcounts[new_map] + 1
	end
	file.Write("pam/playcounts.txt", util.TableToJSON(PAM.playcounts))

	table.insert(PAM.recent_maps, new_map .. ".bsp")

	while #PAM.recent_maps > PAM.config.maps_before_revote do
		table.remove(PAM.recent_maps, 1)
	end

	file.Write("pam/recentmaps.txt", util.TableToJSON(PAM.recent_maps))
end

function PAM.Cancel()
	if PAM.state == PAM.STATE_STARTED then
		PAM.state = PAM.STATE_DISABLED

		net.Start("PAM_Cancel")
		net.Broadcast()

		timer.Remove("PAM_Vote_Timer")
	end
end

function PAM.CheckForRTV()
	-- check if there are enough players
	local current_count = #PAM.players_wanting_rtv
	local needed_count = math.ceil(PAM.rtv_config.needed_player_percentage * player.GetCount())

	if (current_count >= needed_count) then
		-- start pam
		PAM.Start(PAM.rtv_config.vote_length, PAM.rtv_config.allow_all_maps)
	end
end
