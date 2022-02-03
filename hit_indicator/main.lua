--[[
Hit Indicator
by JPiolho

Description: Adds feedback to the player whenever they hit another player or a monster. It can be in both flashing screen or sound.
Cvars: hitindicator_enabled, hitindicator_soundName, hitindicator_soundEnabled, hitindicator_flashingEnabled
--]]

local cvar_hitindicator_enabled = Cvars.Register("hitindicator_enabled","1","Enable or disable the hit indicator plugin",0x11,0,1)
local cvar_hitindicator_soundName = Cvars.Register("hitindicator_soundName","fish/bite.wav","Which sound to play when the player is hit",0x0)
local cvar_hitindicator_soundEnabled = Cvars.Register("hitindicator_soundEnabled","1","Should a sound be played when the player hits something?",0x11)
local cvar_hitindicator_flashingEnabled = Cvars.Register("hitindicator_flashingEnabled","1","Should the screen flash if the player is hit?",0x11)


function QC_T_Damage()
    if not cvar_hitindicator_enabled:GetBool() then
        return
    end

    local target = QC.GetEdict(QC.Value.Parameter0)
    local inflictor = QC.GetEdict(QC.Value.Parameter1)
    local attacker = QC.GetEdict(QC.Value.Parameter2)
    local damage = QC.GetFloat(QC.Value.Parameter3)
    
    -- We only care about players that are attacking
    if attacker.Classname == "player" then
    
        -- Check if target is a player or a monster
        if target.Classname == "player" or string.sub(target.Classname,1,8) == "monster_" then
            if cvar_hitindicator_flashingEnabled:GetBool() then
                Builtins.Stuffcmd(attacker,"bf\n")
            end
            
            if cvar_hitindicator_soundEnabled:GetBool() then
                Builtins.LocalSound(attacker,cvar_hitindicator_soundName:GetString());
            end
        end
    end
end

Hooks.RegisterQC("T_Damage",QC_T_Damage);

function QC_Worldspawn()
    if cvar_hitindicator_enabled:GetBool() and cvar_hitindicator_soundEnabled:GetBool() then
        Builtins.PrecacheSound(cvar_hitindicator_soundName:GetString());
    end
end

Hooks.RegisterQCPost("worldspawn",QC_Worldspawn);