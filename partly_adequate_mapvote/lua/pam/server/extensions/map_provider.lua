local extension = {}
extension.name = "map"
extension.enabled = true
extension.gamemode_dependent = true
extension.settings = {
	prefixes = "",
	blacklist = "",
	whitelist = "",
	limit = 20,
	cooldown = 3
}

function extension.RegisterOptions()
	if PAM.vote_type ~= "map" then return end

	local all_maps = file.Find("maps/*.bsp", "GAME")
	local starting_option_count = PAM.option_count

	local prefixes = string.Split(extension.settings.prefixes, ",")
	local limit = extension.settings.limit
	local blacklist = extension.settings.blacklist
	local whitelist = extension.settings.whitelist

	for _, map in RandomPairs(all_maps) do
		map = map:sub(1, -5)

		-- don't add too many maps
		if limit != 0 && limit <= PAM.option_count - starting_option_count then
			break
		end

		-- don't add maps which were played recently
		if PAM.GetMapCooldown(map) > 0 then
			continue
		end

		-- don't add blacklisted maps
		if string.find(blacklist, map) then
			continue
		end

		-- add whitelisted maps
		if string.find(whitelist, map) then
			PAM.RegisterOption(map)
			continue
		end

		-- add all maps when no prefix is selected
		if #prefixes == 0 then
			PAM.RegisterOption(map)
			continue;
		end

		-- add maps where at least one prefix fits
		for i = 1, #prefixes do
			if string.find(map, prefixes[i]) then
				PAM.RegisterOption(map)
				break
			end
		end
	end
end

function extension.OnWinnerAnnounced(vote_type, option)
	if vote_type ~= "map" then return end
	if option.is_special then return end

	-- update the maps which are currently on cooldown
	local data = sql.Query("SELECT * FROM pam_map_cooldowns")
	if data then
		for _, heat_info in ipairs(data) do
			local mapname = heat_info["id"]
			PAM.SetMapCooldown(mapname, PAM.GetMapCooldown(mapname) - 1)
		end
	end

	-- set/reset the cooldown of the winning map
	PAM.SetMapCooldown(winning_map, GetConVar("pam_map_cooldown"):GetInt())
end

PAM.extension_handler.RegisterExtension(extension)

-- cooldown stuff
if not sql.TableExists("pam_map_cooldowns") then
	sql.Query("CREATE TABLE pam_map_cooldowns(id TEXT NOT NULL PRIMARY KEY, heat INTEGER NOT NULL)")
end

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
