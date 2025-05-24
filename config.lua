
Config = {
    MaxDistance = 50.0, -- Maximum range to find a target player (meters)
    Cooldown = 60000, -- Cooldown for voodoo doll use (milliseconds, 60 seconds)
    AnimationDuration = 10000, -- Duration of user animation cycle (milliseconds, 10 seconds)
    CurseDuration = 60000, -- Duration of curse animation on target (milliseconds, 20 seconds)
    Timeout = 60000, -- Total duration before auto-stop (milliseconds, 30 seconds)
    Curses = {
        { type = 'scenario', anim = 'WORLD_HUMAN_SIT_FALL_ASLEEP', desc = 'You feel oh so tired' },
        { type = 'scenario', anim = 'WORLD_HUMAN_WASH_FACE_BUCKET_GROUND_NO_BUCKET', desc = 'you feel  dirty!' },
		{ type = 'scenario', anim = 'WORLD_HUMAN_VOMIT', desc = 'you feel sick!' },
		{ type = 'scenario', anim = 'WORLD_PLAYER_DRINK_WITCHES_BREW', desc = 'have a drink on me !' },
		{ type = 'scenario', anim = 'WORLD_PLAYER_DYNAMIC_KNEEL', desc = 'bow down before me  !' },
		
        
    }
}


