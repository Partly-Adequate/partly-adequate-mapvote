require("pacoman")

PAM = {}

PAM.vote_type_enum = pacoman.RegisterEnumType("pam_vote_types", {})
PAM.vote_evaluators_enum = pacoman.RegisterEnumType("pam_vote_evaluators", {})

hook.Add("PACOMAN_RegisterEnumValues", "PAM_ENUM_VALUES",
    function()
        PAM.RegisterVoteType("map", PAM.ChangeMap)
        hook.Run("PAM_RegisterVoteTypes")

        PAM.RegisterVoteEvaluator("plurality", PAM.PluralityEvaluation)
        PAM.RegisterVoteEvaluator("lottery", PAM.LotteryEvaluation)
        hook.Run("PAM_RegisterVoteEvaluationTypes")
    end
)

hook.Add("PACOMAN_RegisterGameProperties", "PAM_GAME_PROPERTIES",
    function()
        -- the current gamemode
        PAM.gp_gamemode = pacoman.RegisterGameProperty("gamemode", pacoman.TYPE_STRING, "")
        -- the current map
        PAM.gp_map = pacoman.RegisterGameProperty("map", pacoman.TYPE_STRING, "")
        -- random value assigned at the start of each game
        PAM.gp_game_random = pacoman.RegisterGameProperty("game_random", pacoman.TYPE_PERCENTAGE, 0)
        -- PAM's current vote type. Set right at the start of each mapvote.
        PAM.gp_vote_type = pacoman.RegisterGameProperty("current_pam_vote_type", PAM.vote_type_enum, "map")
        -- random value assigned at the end of each round
        PAM.gp_round_random = pacoman.RegisterGameProperty("round_random", pacoman.TYPE_PERCENTAGE,0)
        -- the current number of players
        PAM.gp_player_count = pacoman.RegisterGameProperty("player_count", pacoman.TYPE_INTEGER, 0)
    end
)

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
PAM.option_count = 0
PAM.special_option_count = 0

-- stores the winner when there is one
PAM.winning_option = nil

--the votes
PAM.votes = {}
