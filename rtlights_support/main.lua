--[[
RTLights support
by JPiolho

Description: Adds some support for external .rtlight files.
--]]

CSFile = luanet.import_type('System.IO.File')
CSPath = luanet.import_type('System.IO.Path')

function ParseNumber(str)
    str = str:gsub(",",".")
    return tonumber(str)
end


function LoadRTLights()
    local mapsFolder = CSPath.Combine(Game.ModFolder,"maps")
    
    local file = CSPath.Combine(mapsFolder,Server.Map .. ".rtlights")
    if not CSFile.Exists(file) then
        return
    end
    
    local data = Client.WorldEntitiesData
    
    
    data = data:gsub("_shadowlight","")
    
    local lightLines = CSFile.ReadAllLines(file)
    
    local i
    for i = 0, lightLines.Length - 1 do
        local light = ParseRTLight(lightLines[i])
        
        
        data = data .. "{\n"
        data = data .. "\"classname\" \"info_null\"\n"
        data = data .. "\"_shadowlight\" \"1\"\n"
        data = data .. "\"_shadowlightradius\" \"" .. tostring(light.radius) .. "\"\n"
        data = data .. "\"_color\" \"" .. tostring(light.r) .. " " .. tostring(light.g) .. " " .. tostring(light.b) .. "\"\n"
        data = data .. "\"origin\" \"" .. tostring(light.x) .. " " .. tostring(light.y) .. " " .. tostring(light.z) .. "\"\n"
        data = data .. "\"angles\" \"" .. tostring(light.pitch) .. " " .. tostring(light.yaw) .. " " .. tostring(light.roll) .. "\"\n"
        data = data .. "\"_shadowlightstyle\" \"" .. tostring(light.style) .. "\"\n"
        data = data .. "\"_shadowlightintensity\" \"" .. tostring(light.diffuseScale) .. "\"\n"
        data = data .. "}\n"
    end
    
    Client.WorldEntitiesData = data
end

function ParseRTLight(str)
    local matchString = "[%d-.,+]+"
    local matchString2 = "\".*\""
    
    local light = {
        x = 0,
        y = 0,
        z = 0,
        radius = 0,
        r = 1,
        g = 1,
        b = 1,
        style = 0,
        cubemap = "",
        corona = 0,
        pitch = 0,
        yaw = 0,
        roll = 0,
        coronaScale = 1,
        ambientScale = 1,
        diffuseScale = 1,
        specularScale = 1,
        flags = 0
    }
    
    
    local strBegin,strEnd = string.find(str,matchString)
    if strBegin == nil then return light end
    light.x = ParseNumber(string.sub(str,strBegin,strEnd))
    
    strBegin,strEnd = string.find(str,matchString,strEnd+1)
    if strBegin == nil then return light end
    light.y = ParseNumber(string.sub(str,strBegin,strEnd))
    
    strBegin,strEnd = string.find(str,matchString,strEnd+1)
    if strBegin == nil then return light end
    light.z = ParseNumber(string.sub(str,strBegin,strEnd))
    
    strBegin,strEnd = string.find(str,matchString,strEnd+1)
    if strBegin == nil then return light end
    light.radius = ParseNumber(string.sub(str,strBegin,strEnd))
    
    strBegin,strEnd = string.find(str,matchString,strEnd+1)
    if strBegin == nil then return light end
    light.r = ParseNumber(string.sub(str,strBegin,strEnd))
    
    strBegin,strEnd = string.find(str,matchString,strEnd+1)
    if strBegin == nil then return light end
    light.g = ParseNumber(string.sub(str,strBegin,strEnd))
    
    strBegin,strEnd = string.find(str,matchString,strEnd+1)
    if strBegin == nil then return light end
    light.b = ParseNumber(string.sub(str,strBegin,strEnd))
    
    strBegin,strEnd = string.find(str,matchString,strEnd+1)
    if strBegin == nil then return light end
    light.style = ParseNumber(string.sub(str,strBegin,strEnd))
    
    strBegin,strEnd = string.find(str,matchString2,strEnd+1)
    if strBegin == nil then return light end
    light.cubemap = string.sub(str,strBegin,strEnd)
    
    strBegin,strEnd = string.find(str,matchString,strEnd+1)
    if strBegin == nil then return light end
    light.corona = ParseNumber(string.sub(str,strBegin,strEnd))
    
    strBegin,strEnd = string.find(str,matchString,strEnd+1)
    if strBegin == nil then return light end
    light.pitch = ParseNumber(string.sub(str,strBegin,strEnd))
    
    strBegin,strEnd = string.find(str,matchString,strEnd+1)
    if strBegin == nil then return light end
    light.yaw = ParseNumber(string.sub(str,strBegin,strEnd))
    
    strBegin,strEnd = string.find(str,matchString,strEnd+1)
    if strBegin == nil then return light end
    light.roll = ParseNumber(string.sub(str,strBegin,strEnd))
    
    strBegin,strEnd = string.find(str,matchString,strEnd+1)
    if strBegin == nil then return light end
    light.coronaScale = ParseNumber(string.sub(str,strBegin,strEnd))
    
    strBegin,strEnd = string.find(str,matchString,strEnd+1)
    if strBegin == nil then return light end
    light.ambientScale = ParseNumber(string.sub(str,strBegin,strEnd))
    
    strBegin,strEnd = string.find(str,matchString,strEnd+1)
    if strBegin == nil then return light end
    light.diffuseScale = ParseNumber(string.sub(str,strBegin,strEnd))
    
    strBegin,strEnd = string.find(str,matchString,strEnd+1)
    if strBegin == nil then return light end
    light.specularScale = ParseNumber(string.sub(str,strBegin,strEnd))
    
    strBegin,strEnd = string.find(str,matchString,strEnd+1)
    if strBegin == nil then return light end
    light.flags = ParseNumber(string.sub(str,strBegin,strEnd))
    
    
    return light
end

Hooks.Register("OnClientNewMap",LoadRTLights)