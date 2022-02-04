--[[
Old style chat
by JPiolho

Description: Adds the talking sound whenever someone talks and can also print the chat to the top-left.
Cvars: oldstylechat_enabled, oldstylechat_playsound, oldstylechat_print
--]]

local cvar_oldstylechat_enabled = Cvars.Register("oldstylechat_enabled","1","Enable or disable the old style chat plugin",0x11,0,1)
local cvar_oldstylechat_playsound = Cvars.Register("oldstylechat_playsound","1","If enabled, sound will be played when a player talks",0x11,0,1)
local cvar_oldstylechat_print = Cvars.Register("oldstylechat_print","0","If enabled, the message will appear in the top-left of the screen",0x11,0,1)

local SOUND_TALK = "misc/talk.wav"


function ForEachClient(active,func)
    local clients = Server.GetClients()
    
    for i = 0, clients.Length - 1 do
        local c = clients[i]
        
        if not active or c.Active then
            if func(c) then
                return
            end
        end
    end
end

function FindClient(active,func)
    local foundClient = nil
    
    -- Loop through each client until we find the one that matches the func() result
    ForEachClient(active,function (c)
        if func(c) then
            foundClient = c
            return true
        end
        return false
    end)
        
    return foundClient
end

function OnChat(name,message,team)
    
    if not cvar_oldstylechat_enabled:GetBool() then
        return
    end
    
    local clients = Server.GetClients();
    
    Debug.Break("Point 1")
    
    -- Is it a client saying this?
    local sayer = FindClient(true, function(c) return c.Name == name end)
    
    Debug.Break("Point 2. Sayer: " .. tostring(sayer))
    
    if sayer ~= nil then
        if team then
            local sayerTeam = sayer.Edict:GetFieldFloat("team")
            
            Debug.Break("Point 3. SayerTeam: " .. tostring(sayerTeam))
            
            -- Only print message and play sound to teammates
            ForEachClient(true, function(c)
                if c.Edict:GetFieldFloat("team") == sayerTeam then
                    -- Print message
                    if cvar_oldstylechat_print:GetBool() then
                        Builtins.SPrint(c.Edict,name .. ": " .. message .. "\n")
                    end
                    
                    -- Play sound
                    if cvar_oldstylechat_playsound:GetBool() then
                        Builtins.LocalSound(c.Edict,SOUND_TALK)
                    end
                end
            end)
        else
            -- Broadcast the message to all
            if cvar_oldstylechat_print:GetBool() then
                Builtins.BPrint(name .. ": " .. message .. "\n")
            end
            
            -- Send a sound for all players
            if cvar_oldstylechat_playsound:GetBool() then
                ForEachClient(true,function(c) Debug.Break("Sound loop - nonteam",c); Builtins.LocalSound(c.Edict,SOUND_TALK) end)
            end
        end
    end
end

function Worldspawn()
    Builtins.PrecacheSound(SOUND_TALK)
end

Hooks.RegisterQC("worldspawn",Worldspawn)
Hooks.Register("OnChat",OnChat)