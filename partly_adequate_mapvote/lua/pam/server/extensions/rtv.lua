local name = "rtv"
PAM_EXTENSION.name = name
PAM_EXTENSION.enabled = false

-- client->server
-- server->all
util.AddNetworkString("PAM_VoteRTV")
-- client->server
-- server->all
util.AddNetworkString("PAM_UnVoteRTV")
-- server->all
util.AddNetworkString("PAM_ResetRTV")

local setting_namespace = PAM.setting_namespace:AddChild(name)
local delayed_setting = setting_namespace:AddSetting("delayed", pacoman.TYPE_BOOLEAN, false)
local percentage_setting = setting_namespace:AddSetting("percentage", pacoman.TYPE_PERCENTAGE, 0.6)
local enabled_setting

-- stores the players wanting to rock the vote
local rtv_voters = {}
local rtv_voter_count = 0

-- Check if there are enough people to win the vote
local function IsEnoughVoters()
	return rtv_voter_count >= math.ceil(percentage_setting:GetActiveValue() * player.GetCount())
end

-- checks if a player wants to rock the vote
local function WantsRTV(ply)
	return rtv_voters[ply:SteamID()]
end

-- make a player rock the vote
local function AddRTVVoter(ply)
	if not enabled_setting:GetActiveValue() or PAM.state ~= PAM.STATE_DISABLED or not IsValid(ply) or WantsRTV(ply) then return end

	rtv_voters[ply:SteamID()] = true
	rtv_voter_count = rtv_voter_count + 1


	net.Start("PAM_VoteRTV")
	net.WriteEntity(ply)
	net.Broadcast()

	if IsEnoughVoters() and not delayed_setting:GetActiveValue() then
		PAM.Start()
	end

	PAM.extension_handler.RunEvent("OnRTVVoterAdded", ply)
end

-- make a player not rock the vote
local function RemoveRTVVoter(ply)
	if not enabled_setting:GetActiveValue() or PAM.state ~= PAM.STATE_DISABLED or not IsValid(ply) or not WantsRTV(ply) then return end

	rtv_voters[ply:SteamID()] = nil
	rtv_voter_count = rtv_voter_count - 1

	net.Start("PAM_UnVoteRTV")
	net.WriteEntity(ply)
	net.Broadcast()

	PAM.extension_handler.RunEvent("OnRTVVoterRemoved", ply)
end

-- reset players that want to rock the vote
local function ResetRTVVoters()
	rtv_voters = {_setting}
	rtv_voter_count = 0

	net.Start("PAM_ResetRTV")
	net.Broadcast()

	PAM.extension_handler.RunEvent("OnRTVVotersReset")
end

-- reset voters when rtv is disabled
function PAM_EXTENSION:OnDisabled()
	ResetRTVVoters()
end

-- reset voters when pam starts
function PAM_EXTENSION:OnVoteStarted()
	ResetRTVVoters()
end

-- Check for delayed rtv when a round ends
function PAM_EXTENSION:OnRoundEnded()
	if delayed_setting:GetActiveValue() and IsEnoughVoters() then
		PAM.Start()
	end
end

function PAM_EXTENSION:StateRequest(ply)
	if rtv_voter_count == 0 then return end

	for steam_id, _ in pairs(rtv_voters) do
		net.Start("PAM_VoteRTV")
		net.WriteEntity(player.GetBySteamID(steam_id))
		net.Send(ply)
	end
end

function PAM_EXTENSION:Initialize()
	enabled_setting = setting_namespace:GetSetting("enabled")

	net.Receive("PAM_VoteRTV", function(len, ply)
		AddRTVVoter(ply)
	end)

	net.Receive("PAM_UnVoteRTV", function(len, ply)
		RemoveRTVVoter(ply)
	end)

	hook.Add("PlayerDisconnected", "PAM_RTVPlayerDisconnected", function(ply, steam_id, unique_id)
		if not enabled_setting:GetActiveValue() then return end

		RemoveRTVVoter(ply)

		if IsEnoughVoters() and not delayed_setting:GetActiveValue() then
			PAM.Start()
		end
	end)
end
