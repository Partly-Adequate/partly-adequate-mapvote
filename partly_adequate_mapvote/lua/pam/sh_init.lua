PAM = {}

--the possible states
--for when it hasn't started yet
PAM.STATE_DISABLED = 0
--for when voting is possible
PAM.STATE_STARTED = 1
--for when the winner is announced
PAM.STATE_FINISHED = 2

--the current state
PAM.state = PAM.STATE_DISABLED

--the voteable maps
PAM.options = {}

--the votes
PAM.votes = {}

-- stores the players wanting to rock the vote
PAM.players_wanting_rtv = {}

-- convars
CreateConVar("pam_vote_length", 30, {FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Set the length of the voting time in seconds.", 0)
CreateConVar("pam_rtv_enabled", 0, {FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Set this to 1 to enable rtv or to 0 to disable rtv.")
CreateConVar("pam_rtv_percentage", 0.6, {FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX, FCVAR_NOTIFY, FCVAR_REPLICATED}, "The percentage of players needed for rtv to start.", 0, 1)
CreateConVar("pam_rtv_delayed", 0, {FCVAR_ARCHIVE, FCVAR_ARCHIVE_XBOX, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Set this to 1 to delay the votescreen to a more fitting moment. This is not supported by most gamemodes.")
