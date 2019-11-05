function PAM.AddToFavorites(mapname)
	if PAM.IsFavorite(mapname) then return end

	table.insert(PAM.favorite_maps, mapname)
	file.Write("pam/favoritemaps.txt", util.TableToJSON(PAM.favorite_maps))
end

function PAM.IsFavorite(mapname)
	return table.HasValue(PAM.favorite_maps, mapname)
end

function PAM.RemoveFromFavorites(mapname)
	if not PAM.IsFavorite(mapname) then return end

	table.RemoveByValue(PAM.favorite_maps, mapname)
	file.Write("pam/favoritemaps.txt", util.TableToJSON(PAM.favorite_maps))
end

function PAM.Vote(map_id)
	net.Start("PAM_Vote")
	net.WriteUInt(map_id, 32)
	net.SendToServer()
end

function PAM.UnVote()
	net.Start("PAM_UnVote")
	net.SendToServer()
end
