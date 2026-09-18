local name = "map_provider"
PAM_EXTENSION.name = name
PAM_EXTENSION.enabled = true

local setting_namespace = PAM.setting_namespace:AddChild(name)

PAM_EXTENSION.prefixes_setting = setting_namespace:AddSetting("prefixes", pacoman.TYPE_STRING, "", "Maps where at least one of the prefixes fits, will be available for voting.")
PAM_EXTENSION.blacklist_setting = setting_namespace:AddSetting("blacklist", pacoman.TYPE_STRING, "", "Maps that are listed here, won't be available, even when a prefix fits.")
PAM_EXTENSION.whitelist_setting = setting_namespace:AddSetting("whitelist", pacoman.TYPE_STRING, "", "Maps that are listed here, will be available for voting, even when no prefix fits.")
PAM_EXTENSION.limit_setting = setting_namespace:AddSetting("limit", pacoman.TYPE_INTEGER, 20, "Determines how many maps this extension will provide.")
PAM_EXTENSION.cooldown_setting = setting_namespace:AddSetting("cooldown", pacoman.TYPE_INTEGER, 3, "Determines how many maps need to be played for a map to be available again.")

-- cooldown stuff
if not sql.TableExists("pam_map_cooldowns") then
	sql.Query("CREATE TABLE pam_map_cooldowns(id TEXT NOT NULL PRIMARY KEY, heat INTEGER NOT NULL)")
end

local function GetMapCooldown(mapname)
	local data = sql.Query("SELECT heat FROM pam_map_cooldowns WHERE id IS " .. sql.SQLStr(mapname))
	if data then
		return tonumber(data[1]["heat"])
	else
		return 0
	end
end

local function SetMapCooldown(mapname, cooldown)
	if cooldown <= 0 then
		sql.Query("DELETE FROM pam_map_cooldowns WHERE id IS " .. sql.SQLStr(mapname))
	else
		sql.Query("INSERT OR REPLACE INTO pam_map_cooldowns VALUES( " .. sql.SQLStr(mapname) .. ", " .. cooldown .. ")")
	end
end

function PAM_EXTENSION:RegisterOptions()
	if PAM.vote_type ~= "map" then return end

	local all_maps = file.Find("maps/*.bsp", "GAME")
	local starting_option_count = PAM.option_count

	local prefixes = string.Split(self.prefixes_setting:GetActiveValue(), ",")
	local blacklist = self.blacklist_setting:GetActiveValue()
	local whitelist = self.whitelist_setting:GetActiveValue()
	local limit = self.limit_setting:GetActiveValue()

	for _, map in RandomPairs(all_maps) do
		map = map:sub(1, -5)

		-- don't add too many maps
		if limit ~= 0 && limit <= PAM.option_count - starting_option_count then
			break
		end

		-- don't add maps which were played recently
		if self.cooldown_setting:GetActiveValue() > 0 and GetMapCooldown(map) > 0 then
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

function PAM_EXTENSION:OnOptionWon(option)
	if PAM.vote_type ~= "map" then return end
	if option.is_special then return end

	-- update the maps which are currently on cooldown
	local data = sql.Query("SELECT * FROM pam_map_cooldowns")
	if data then
		for _, heat_info in ipairs(data) do
			local mapname = heat_info["id"]
			SetMapCooldown(mapname, GetMapCooldown(mapname) - 1)
		end
	end

	-- set/reset the cooldown of the winning map
	SetMapCooldown(option.name, self.cooldown_setting:GetActiveValue())
end
