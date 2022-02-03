--[[
MOTD (Message of the day)
by JPiolho

Description: Shows a chat message to the player shortly after they join
Cvars: motd, motd_title
--]]

local cvar_motd_title = Cvars.Register("motd_title","<MOTD>","The title of the motd (the name of the person who sents it)");
local cvar_motd = Cvars.Register("motd","Welcome to my server","What motd message should be sent");


local MSG_ONE = 1
local SVC_BOTCHAT = 38
local SVC_UPDATENAME = 13



local pendingMessages = {}


function FindPlayerByName(netname)

    local e = QC.World
    
    repeat
        e = Builtins.NextEnt(e)
        
        if e.Classname ~= nil and e.Classname == "player" and e:GetFieldString("netname") == netname then
            return e
        end
        
    until (e.Classname ~= nil and e.Classname == "worldspawn")

    return nil
end

function SendMotd(player)    
    QC.MsgEntity = player
    
    -- Change host name to trick the client
    Builtins.WriteByte(MSG_ONE,SVC_UPDATENAME)
    Builtins.WriteByte(MSG_ONE,0) -- Player 0 (Host)
    Builtins.WriteString(MSG_ONE,cvar_motd_title:GetString())
    
    -- Send the message
    Builtins.WriteByte(MSG_ONE,SVC_BOTCHAT)
    Builtins.WriteByte(MSG_ONE,0) -- Who's talking? (The host!)
    Builtins.WriteShort(MSG_ONE,1) -- How many strings
    Builtins.WriteString(MSG_ONE,cvar_motd:GetString())
    
    -- Restore host name
    local host = Server.GetClient(0).Edict
    
    Builtins.WriteByte(MSG_ONE,SVC_UPDATENAME)
    Builtins.WriteByte(MSG_ONE,0)
    Builtins.WriteString(MSG_ONE,host:GetFieldString("netname"))
    
end


function QC_ClientConnect()
    pendingMessages[QC.Self:GetFieldString("netname")] = QC.Time + 1.0
end


function QC_StartFrame()
    local currentTime = QC.Time
    
    for k,v in pairs(pendingMessages) do
        if currentTime >= v then
            SendMotd(FindPlayerByName(k))
            
            pendingMessages[k] = nil
        end
        
    end
end

Hooks.RegisterQC("ClientConnect",QC_ClientConnect)
Hooks.RegisterQC("StartFrame",QC_StartFrame)