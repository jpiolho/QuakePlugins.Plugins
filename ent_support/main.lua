--[[
Ent Support
by JPiolho

Description: Adds support for external .ent files. Also includes .aent which addictively adds entities instead of replacing them.
--]]

CSFile = luanet.import_type('System.IO.File')
CSPath = luanet.import_type('System.IO.Path')


function Worldspawn()
    local mapsFolder = CSPath.Combine(Game.ModFolder,"maps")
    
    local file = CSPath.Combine(mapsFolder,Server.Map .. ".aent")
    if not CSFile.Exists(file) then
        return
    end
    
    
    local contents = ParseEntFile(CSFile.ReadAllText(file))
    
    for _,edict in ipairs(contents) do
        
        local ent = Builtins.Spawn()
        local classname = nil
        
        for k,v in pairs(edict) do
        
            -- Set the classname
            if string.upper(k) == "CLASSNAME" then
                classname = v
            end
            
            local fieldType = QC.GetFieldType(k)
            
            if fieldType == QC.FieldType.String then
                ent:SetField(k,v)
            elseif fieldType == QC.FieldType.Float then
                ent:SetField(k,tonumber(v))
            elseif fieldType == QC.FieldType.Vector then
                ent:SetField(k,ParseVector3(v))
            elseif fieldType == QC.FieldType.Function then
                local f = QC.FindFunction(v)
                if f ~= nil then ent:SetField(k,f) end
            end
        end
        
        
        if classname == nil then
            Builtins.Remove(ent)
        else
            local spawnFunction = QC.FindFunction(classname)
            
            if spawnFunction == nil then
                Console.PrintLine("Failed to find spawn function for: " .. classname)
            else
                local oself = QC.Self
                QC.Self = ent
                spawnFunction:Call()
                
                QC.Self = oself
            end
        end
    end
    
end



function AfterEntitiesLoaded()
    local mapsFolder = CSPath.Combine(Game.ModFolder,"maps")
    
    local file = CSPath.Combine(mapsFolder,Server.Map .. ".ent")
    if not CSFile.Exists(file) then
        return
    end
    
    local e = QC.World
    
    repeat
        e = Builtins.NextEnt(e)
        
        local idx = e.Index
        if idx >= Server.MaxClients*2 then            
            if e.Classname ~= "worldspawn" then
                Builtins.Remove(e)
            end
        end
    until e.Classname == "worldspawn"
    
    local contents = ParseEntFile(CSFile.ReadAllText(file))
    
    -- TODO: Apply deathmatch, coop and skill filtering to ents
    
    for _,edict in ipairs(contents) do
        
        local classname = nil
        
        -- Get classname first
        for k,v in pairs(edict) do
            if string.upper(k) == "CLASSNAME" then
                classname = v
            end
        end
        
        if classname ~= nil then
        
            local ent
            if classname == "worldspawn" then
                ent = QC.World
            else
                ent = Builtins.Spawn()
            end
            
            
            for k,v in pairs(edict) do              
                -- Field hacks!
                if k == "angle" then
                    k = "angles"
                    v = "0 " .. v .. " 0"
                end
            
                local fieldType = QC.GetFieldType(k)
                
                if fieldType == QC.FieldType.String then
                    ent:SetField(k,v)
                elseif fieldType == QC.FieldType.Float then
                    ent:SetField(k,tonumber(v))
                elseif fieldType == QC.FieldType.Vector then
                    ent:SetField(k,ParseVector3(v))
                elseif fieldType == QC.FieldType.Function then
                    local f = QC.FindFunction(v)
                    if f ~= nil then ent:SetField(k,f) end
                end
            end
            
            if classname ~= "worldspawn" then
                local spawnFunction = QC.FindFunction(classname)
                
                if spawnFunction == nil then
                    Console.PrintLine("Failed to find spawn function for: " .. classname)
                else
                    local oself = QC.Self
                    QC.Self = ent
                    spawnFunction:Call()
                    QC.Self = oself
                end
            end
        end
    end
    
end

function ParseNumber(str)
    str = str:gsub(",",".")
    return tonumber(str)
end

function ParseVector3(str)
    local matchString = "[%d-.,+]+"
    local strBegin,strEnd = string.find(str,matchString)
    local x = ParseNumber(string.sub(str,strBegin,strEnd))
    strBegin,strEnd = string.find(str,matchString,strEnd+1)
    local y = ParseNumber(string.sub(str,strBegin,strEnd))
    strBegin,strEnd = string.find(str,matchString,strEnd+1)
    local z = ParseNumber(string.sub(str,strBegin,strEnd))
    
    return Vector3(x,y,z)
end



function ParseEntFile(contents)
    local MODE_NOTHING = 0
    local MODE_EDICT = 1;
    local MODE_TOKEN = 2;
    
    local cIndex = 1
    local cEnd = string.len(contents)
    local mode = MODE_NOTHING
    
    local edicts = {}
    local edict = nil
    local buffer = ""
    local escape = false
    
    local key = nil;
    
    repeat
        local c = string.sub(contents,cIndex,cIndex)
        
        if mode == MODE_NOTHING then
            if c == "{" then 
                mode = MODE_EDICT 
                edict = {}
            end
        elseif mode == MODE_EDICT then
            if c == "}" then 
                mode = MODE_NOTHING 
                table.insert(edicts,edict) -- Add to edicts table
                edict = nil
            elseif c == "\"" then
                mode = MODE_TOKEN 
            end
        elseif mode == MODE_TOKEN then
            if c == "\"" and not escape then
                mode = MODE_EDICT 
                
                if key == nil then
                    key = buffer
                else
                    -- Add key value
                    edict[key] = buffer
                    key = nil
                end
                
                buffer = ""
            else
                escape = false
                buffer = buffer .. c
            end
        end
        
        cIndex = cIndex + 1
    until cIndex > cEnd
    
    
    return edicts
end


Hooks.RegisterQCPost("worldspawn",Worldspawn)
Hooks.Register("OnAfterEntitiesLoaded",AfterEntitiesLoaded)