--[[
Horde Wave
by JPiolho

Description: Adds a few notifications about what gets unlocked and keeps track of which wave. Announces unlocks with keys and wave.
Cvars: horde_announcesound_regular, horde_showwaves, horde_announce_unlocks, horde_announce_secret_unlocks
--]]

local cvar_horde_announcesound_regular = Cvars.Register("horde_announcesound_regular","ogre/ogwake.wav","Which sound to play when a regular wave begins. Set to empty to disable");
local cvar_horde_showwaves = Cvars.Register("horde_showwaves","1","If enabled, the wave count will appear after each wave begins",0x11,0,1)
local cvar_horde_announce_unlocks = Cvars.Register("horde_announce_unlocks","1","If enabled, whenever something is unlocked with a key, it'll be announced",0x11,0,1)
local cvar_horde_announce_secret_unlocks = Cvars.Register("horde_announce_secret_unlocks","0","If enabled, whenever a secret is unlocked with a key, it'll be announced",0x11,0,1)

-- Disable mod code if it's not mg1 since this is a horde mod after all
if Game.Mod ~= "mg1" then
    return
end

local sounds = nil
local wave = 0

local sentAnnouncements = {}

function PrintWave()

    CenterPrintAll("Wave " .. tostring(wave))
    Console.PrintLine("Wave: " .. tostring(wave));
    ForEachActivePlayer(function(c) Builtins.SPrint(c.Edict,"Wave " .. tostring(wave) .. "\n") end)
end

function QC_Countdown4()
    wave = wave + 1
    
    
    -- Play wave sound
    if sound ~= nil then
        ForEachActivePlayer(function(c) Builtins.LocalSound(c.Edict,sound) end)
    end
    
    if cvar_horde_showwaves:GetBool() then
        Timers.In(1,PrintWave)
    end
end


function ForEachActivePlayer(func)
    local clients = Server.GetClients()
    
    local i
    for i = 0, clients.Length - 1 do
        if clients[i].Active then
            func(clients[i])
        end
    end
end

function CenterPrintAll(text)
    ForEachActivePlayer(function(c) Builtins.CenterPrint(c.Edict,text) end)
end


function Worldspawn()
   
    if sound ~= nil then
        Builtins.PrecacheSound(sound)
    end
end

function DoorFire()
    local model = QC.Self:GetFieldString("model")
    local targetname = QC.Self:GetFieldString("targetname")
    
    if Server.Map == "horde1" then
        if cvar_horde_announce_unlocks:GetBool() then
            if model == "*4" then SendAnnouncement(model,"The lightning gun has been unlocked")
            elseif model == "*24" then SendAnnouncement(model,"The super nailgun has been unlocked")
            elseif model == "*19" then SendAnnouncement(model,"The rocket launcher has been unlocked")
            elseif model == "*20" then SendAnnouncement(model,"The exit portal has been opened")
            end
        end
            
        if cvar_horde_announce_secret_unlocks:GetBool() then
            if targetname == "secret3" then SendAnnouncement(targetname,"The megahealth has been opened")
            elseif targetname == "secret2" then SendAnnouncement(targetname,"The flying portal has been opened")
            elseif targetname == "c1_relay" then SendAnnouncement(targetname,"The towers have been opened")
            elseif targetname == "secret1" then SendAnnouncement(targetname,"The yellow armor has been opened")
            end
        end
    elseif Server.Map == "horde2" then
        if cvar_horde_announce_unlocks:GetBool() then
            if targetname == "door2" then SendAnnouncement(targetname,"The lightning gun has been unlocked")
            elseif targetname == "escdoor" then SendAnnouncement(targetname,"The exit portal has been opened")
            elseif targetname == "door1" then SendAnnouncement(targetname,"The super nailgun has been unlocked")
            end
        end
            
        if cvar_horde_announce_secret_unlocks:GetBool() then
            if targetname == "secret" then SendAnnouncement(targetname,"The megahealth has been opened")
            end
        end
    elseif Server.Map == "horde3" then
        if cvar_horde_announce_unlocks:GetBool() then
            if model == "*9" then SendAnnouncement(model,"The rocket launcher has been unlocked")
            elseif model == "*10" then SendAnnouncement(model,"The grenade launcher has been unlocked")
            elseif model == "*11" or model == "*4" then SendAnnouncement(model,"A red armor has been unlocked")
            elseif model == "*7" then SendAnnouncement(model,"The super nailgun has been unlocked")
            elseif model == "*5" then SendAnnouncement(model,"The lightning gun has been unlocked")
            elseif model == "*6" or model == "*8" then SendAnnouncement(model,"A megahealth has been unlocked")
            elseif model == "*2" then SendAnnouncement(model,"The exit portal has been opened")
            end
        end
        
        if cvar_horde_announce_secret_unlocks:GetBool() then
            if model == "*27" then SendAnnouncement(model,"The secret area has been unlocked")
            end
        end
    elseif Server.Map == "horde4" then
        if cvar_horde_announce_unlocks:GetBool() then
            if targetname == "end_door" then SendAnnouncement(targetname,"The exit portal has been opened")
            elseif targetname == "keydoor_1" then SendAnnouncement(targetname,"The rocket launcher has been unlocked")
            elseif targetname == "keydoor_2" then SendAnnouncement(targetname,"The lightning gun has been unlocked")
            end
        end
        
        if cvar_horde_announce_secret_unlocks:GetBool() then
            if targetname == "secret_door1" then SendAnnouncement(targetname,"The megahealth has been opened")
            end
        end
    elseif Server.Map == "e1m7" then
        if cvar_horde_announce_unlocks:GetBool() then
            if targetname == "door_grenadelauncher" then SendAnnouncement(targetname,"The grenade launcher has been unlocked")
            elseif targetname == "door_redarmor" then SendAnnouncement(targetname,"The red armor has been unlocked")
            elseif targetname == "door_downstairsaccess" then SendAnnouncement(targetname,"The lower area has been unlocked")
            elseif targetname == "door_endportal" then SendAnnouncement(targetname,"The exit portal has been opened")
            elseif targetname == "drawbridge" then SendAnnouncement(targetname,"The drawbridge has been opened")
            elseif targetname == "door_lightning" then SendAnnouncement(targetname,"The lightning gun has been unlocked")
            elseif targetname == "door_rocketlauncher" then SendAnnouncement(targetname,"The rocket launcher has been unlocked")
            end
        end
    end
end

function SendAnnouncement(id,text)
    -- Do not send the announcement if it has been sent before.
    -- This prevents it being sent multiple times if the door keeps being opened
    if sentAnnouncements[id] ~= nil then
        return
    end
    
    CenterPrintAll(text)
    ForEachActivePlayer(function(c) Builtins.SPrint(c.Edict,text .. "\n") end)
    
    sentAnnouncements[id] = true
end

function DoorTouch()
    if QC.Other.Classname ~= "player" then
        return
    end
    
    Console.PrintLine("Door: " .. tostring(QC.Self:GetFieldString("model")) .. " | " .. tostring(QC.Self:GetFieldString("targetname")) .. "\n");
end

Hooks.RegisterQC("door_touch",DoorTouch)
Hooks.RegisterQC("door_fire",DoorFire)
Hooks.RegisterQC("fd_secret_use",DoorFire)
Hooks.RegisterQCPost("worldspawn",Worldspawn)
Hooks.RegisterQCPost("Countdown4",QC_Countdown4)

-- Load sound
sound = cvar_horde_announcesound_regular:GetString()
if sound ~= nil and string.len(sound) == 0 then sound = nil end