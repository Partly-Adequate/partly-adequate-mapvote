function PAM.Start()
	local all_maps = file.Find("maps/*.bsp", "GAME")

	table.Empty(PAM.maps)
	table.Empty(PAM.votes)
	table.Empty(PAM.players_wanting_rtv)

	local map_amount = 0

	local function AddMap(map)
		map_amount = map_amount + 1
		PAM.maps[map_amount] = map
	end

	-- store config locally
	local max_map_amount = GetConVar("pam_max_maps"):GetInt()
	local map_prefixes = string.Split(GetConVar("pam_map_prefixes"):GetString(), ",")
	local map_blacklist = string.Split(GetConVar("pam_map_blacklist"):GetString(), ",")
	local map_whitelist = string.Split(GetConVar("pam_map_whitelist"):GetString(), ",")

	for _, map in RandomPairs(all_maps) do
		map = map:sub(1, -5)

		-- don't add too many maps
		if max_map_amount != 0 && map_amount >= max_map_amount then
			break
		end

		-- don't add maps which were played recently
		if PAM.GetMapCooldown(map) > 0 then
			continue
		end

		-- don't add blacklisted maps
		if table.HasValue(map_blacklist, map) then
			continue
		end

		-- add whitelisted maps
		if table.HasValue(map_whitelist, map) then
			AddMap(map)
			continue
		end

		-- add all maps when no prefix is selected
		if table.IsEmpty(map_prefixes) then
			AddMap(map)
			continue;
		end

		-- add maps where at least one prefix fits
		for _, prefix in ipairs(map_prefixes) do
			if string.find(map, prefix) then
				AddMap(map)
				break
			end
		end
	end

	if map_amount <= 0 then
		AddMap(game.GetMap())
	end

	-- send start info to all clients
	net.Start("PAM_Start")
	-- transmit amount of maps
	net.WriteUInt(map_amount, 32)
	-- transmit map information
	for _, map in ipairs(PAM.maps) do
		net.WriteString(map)
		net.WriteUInt(PAM.GetMapPlaycount(map), 32)
	end
	net.Broadcast()

	-- update state
	PAM.state = PAM.STATE_STARTED

	--timer for ending it after the vote time is over
	timer.Create("PAM_Vote_Timer", GetConVar("pam_vote_length"):GetInt(), 1, function()
		PAM.state = PAM.STATE_FINISHED

		local vote_results = {}

		for steam_id, map in pairs(PAM.votes) do
			if IsValid(player.GetBySteamID(steam_id)) then
				vote_results[map] = (vote_results[map] or 0) + 1
			end
		end

		-- select winning map
		local winning_map_index = table.GetWinningKey(vote_results) or math.random(#PAM.maps)
		local winning_map = PAM.maps[winning_map_index]

		-- notify clients
		net.Start("PAM_Announce_Winner")
		net.WriteUInt(winning_map_index, 32)
		net.Broadcast()

		-- add 1 to the playcount of the winning map
		PAM.SetMapPlaycount(winning_map, PAM.GetMapPlaycount(winning_map) + 1)

		-- update the maps which are currently on cooldown
		local data = sql.Query("SELECT * FROM pam_map_cooldowns")
		PrintTable(data)
		for _, heat_info in ipairs(data) do
			local mapname = heat_info["id"]
			PAM.SetMapCooldown(mapname, PAM.GetMapCooldown(mapname) - 1)
		end

		-- set/reset the cooldown of the winning map
		PAM.SetMapCooldown(winning_map, GetConVar("pam_map_cooldown"):GetInt())

		-- change the map after 4 seconds
		timer.Simple(4, function()
			RunConsoleCommand("changelevel", winning_map)
		end)
	end)
end

function PAM.Cancel()
	if PAM.state == PAM.STATE_STARTED then
		PAM.state = PAM.STATE_DISABLED
		timer.Remove("PAM_Vote_Timer")

		net.Start("PAM_Cancel")
		net.Broadcast()
	end
end

function PAM.CheckForRTV()
	-- check if there are enough players
	local current_count = #PAM.players_wanting_rtv
	local needed_count = math.ceil(GetConVar("pam_rtv_percentage"):GetFloat() * player.GetCount())

	if (current_count >= needed_count) then
		-- start pam
		PAM.Start()
	end
end

-- cooldown utility functions
function PAM.GetMapCooldown(mapname)
	local data = sql.Query("SELECT heat FROM pam_map_cooldowns WHERE id IS " .. sql.SQLStr(mapname))
	if data then
		return tonumber(data[1]["heat"])
	else
		return 0
	end
end

function PAM.SetMapCooldown(mapname, cooldown)
	if(cooldown <= 0) then
		sql.Query("DELETE FROM pam_map_cooldowns WHERE id IS " .. sql.SQLStr(mapname))
	else
		sql.Query("INSERT OR REPLACE INTO pam_map_cooldowns VALUES( " .. sql.SQLStr(mapname) .. ", " .. cooldown .. ")")
	end
end

-- playcount utility functions
function PAM.GetMapPlaycount(mapname)
	local data = sql.Query("SELECT playcount FROM pam_maps WHERE id IS " .. sql.SQLStr(mapname))
	if data then
		return tonumber(data[1]["playcount"])
	else
		return 0;
	end
end

function PAM.SetMapPlaycount(mapname, playcount)
	local data = sql.Query("INSERT OR REPLACE INTO pam_maps VALUES( " .. sql.SQLStr(mapname) .. ", " .. playcount .. ")")
end
