local extension = {}
extension.name = "map_provider"
extension.enabled = true

local prefixes = ""
local blacklist = ""
local whitelist = ""
local limit = 20
local cooldown = 0

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
	if(cooldown <= 0) then
		sql.Query("DELETE FROM pam_map_cooldowns WHERE id IS " .. sql.SQLStr(mapname))
	else
		sql.Query("INSERT OR REPLACE INTO pam_map_cooldowns VALUES( " .. sql.SQLStr(mapname) .. ", " .. cooldown .. ")")
	end
end

function extension.RegisterOptions()
	if PAM.vote_type ~= "map" then return end

	local all_maps = file.Find("maps/*.bsp", "GAME")
	local starting_option_count = PAM.option_count

	local prefixes = string.Split(prefixes, ",")

	for _, map in RandomPairs(all_maps) do
		map = map:sub(1, -5)

		-- don't add too many maps
		if limit != 0 && limit <= PAM.option_count - starting_option_count then
			break
		end

		-- don't add maps which were played recently
		if GetMapCooldown(map) > 0 then
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
			SetMapCooldown(mapname, GetMapCooldown(mapname) - 1)
		end
	end

	-- set/reset the cooldown of the winning map
	SetMapCooldown(winning_map, cooldown)
end

PAM.extension_handler.RegisterExtension(extension)

-- Settings
local setting_namespace = PAM.setting_namespace:AddChild(extension.name)

prefixes_setting = setting_namespace:AddSetting("prefixes", pacoman.P_TYPE_STRING, prefixes)
blacklist_setting = setting_namespace:AddSetting("blacklist", pacoman.P_TYPE_STRING, blacklist)
whitelist_setting = setting_namespace:AddSetting("whitelist", pacoman.P_TYPE_STRING, whitelist)
limit_setting = setting_namespace:AddSetting("limit", pacoman.P_TYPE_INTEGER, limit)
cooldown_setting = setting_namespace:AddSetting("cooldown", pacoman.P_TYPE_INTEGER, cooldown)

prefixes = prefixes_setting:GetActiveValue()
blacklist = blacklist_setting:GetActiveValue()
whitelist = whitelist_setting:GetActiveValue()
limit = limit_setting:GetActiveValue()
cooldown = cooldown_setting:GetActiveValue()

prefixes_setting:AddCallback("default", function(new_value)
	prefixes = new_value
end)
blacklist_setting:AddCallback("default", function(new_value)
	blacklist = new_value
end)
whitelist_setting:AddCallback("default", function(new_value)
	whitelist = new_value
end)
limit_setting:AddCallback("default", function(new_value)
	limit = new_value
end)
cooldown_setting:AddCallback("default", function(new_value)
	cooldown = new_value
end)
