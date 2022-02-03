--[[
Aim Player name
by JPiolho

Description: Shows the name of the player you're looking at
Cvars: aimplayername_enabled, aimplayername_fastclear, aimplayername_offsetx, aimplayername_offsety
--]]

local cvar_aimplayername_enabled = Cvars.Register("aimplayername_enabled","1","Enable or disable aimplayername plugin",0x11,0,1)
local cvar_aimplayername_fastclear = Cvars.Register("aimplayername_fastclear","1","If enabled, the center text will clear immediately when not aiming at a player",0x11,0,1)
local cvar_aimplayername_offsetx = Cvars.Register("aimplayername_offsetx","0.0","How much to offset in width from the center of the screen. Min: -50, Max: 50",0x12,-50,50)
local cvar_aimplayername_offsety = Cvars.Register("aimplayername_offsety","0.0","How much to offset in height from the center of the screen. Min: 0, Max: 20",0x12,0,22)


local showLastFrame = {}

function QC_PlayerPreThink()

    -- Check if plugin is enabled
    if not cvar_aimplayername_enabled:GetBool() then
        return
    end

    local player = QC.Self
    
    -- Calculate global vectors
    Builtins.Makevectors(player:GetFieldVector("v_angle"))
    
    local eyesPosition = player.Origin + Vector3(0,0,16)
    local traceEnd = eyesPosition + QC.V_Forward * 1000
    
    -- Trace line to see what the player is hitting
    Builtins.TraceLine(eyesPosition,traceEnd,0,player)
    
    
    -- Is the target a player?
    if QC.TraceEnt.Classname == "player" then
        -- Center print the player name 
        Builtins.CenterPrint(player,GetAimText(QC.TraceEnt:GetFieldString("netname")))
        
        showLastFrame[player.Index] = true -- Register that we sent a centerprint on this frame
    else
    
        -- Clear the screen (if the cvar is enabled)
        if cvar_aimplayername_fastclear:GetBool() and showLastFrame[player.Index] then
            Builtins.CenterPrint(player,"")
        end
        
        showLastFrame[player.Index] = nil
    end
end


function GetAimText(name)
    local offsetx = cvar_aimplayername_offsetx:GetNumber()
    local offsety = cvar_aimplayername_offsety:GetNumber()
    
    local horizontalSpacesLeft = 50 - string.len(name)
    
    local text = "";
    local i
    if offsety < 0 then
        for i = 1, offsety, -1 do
            text = text .. "\n"
        end
    end
    
    if offsetx > 0 then
        for i = 1, offsetx do
            if i >= horizontalSpacesLeft then break end
            text = text .. " "
        end
    end
    
    text = text .. name
    
    if offsetx < 0 then
        for i = 1, offsetx, -1 do
            if i >= horizontalSpacesLeft then break end
            text = text .. " "
        end
    end
    
    if offsety > 0 then
        for i = 1, offsety do
            text = text .. "\n"
        end
    end
    
    return text
    
end


Hooks.RegisterQC("PlayerPreThink",QC_PlayerPreThink)