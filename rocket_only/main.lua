local cvar_rocketdm_rogue_multirocket = Cvars.Register("rocketdm_rogue_multirocket","1","Allow multi-rockets in Rogue (Dissolution of Eternity)",0x11,0,1)
local cvar_rocketdm_rogue_multirocket_randomLocation = Cvars.Register("rocketdm_rogue_multirocket_randomLocation","1","If set to 1, multi-rocket ammo will spawn in random places",0x11,0,1)

Server.GamemodeName = "RocketsDM"



function RemoveItem()
    Builtins.Remove(QC.Self)
    
    return Hooks.Handling.Superceded -- Superceded prevents the original QC function from running
end

function ConvertToRockets()
    QC.CallFunction("item_rockets")
    QC.Self.Classname = "item_rockets"
    
    return Hooks.Handling.Superceded -- Superceded prevents the original QC function from running
end

function PutClientInServer()
    local self = QC.Self
    
    local IT_ROCKET_LAUNCHER = 32
    
    local IT_AXE = 4096
    if Game.Mod == "rogue" then
        IT_AXE = 2048
    end
    
    self:SetField("items",IT_ROCKET_LAUNCHER | IT_AXE) -- Give Rocket launcher and Axe
    self:SetField("impulse",7) -- Set the weapon to rocket
    
    -- Grant some ammo
    if Game.Mod == "rogue" then
        self:SetField("ammo_rockets1",15)
    else
        self:SetField("ammo_rockets",15)
    end
end

function RegenItem()
    
    -- Only interested in rogue and 'random location multi rockets'
    if not Game.Mod == "rogue" then return
    elseif not cvar_rocketdm_rogue_multirocket_randomLocation:GetBool() then return end
    
    local otherClass
    if QC.Self.Classname == "item_rockets" then otherClass = "item_multi_rockets" else otherClass = "item_rockets" end
    
    
    local validLocations = {}
    
    local e = QC.World
    repeat
        e = Builtins.NextEnt(e)
        
        -- Check if it's a valid target for swapping
        if e.Classname == otherClass 
        and e:GetFieldFloat("solid") == 0 
        and e:GetFieldFloat("nextthink") > QC.Time + 5 then
            table.insert(validLocations,e)
        end
    until e.Classname == "worldspawn"
    
    -- Choose a random location to respawn at
    if #validLocations > 0 then
        e = validLocations[math.random(1,#validLocations)]
        
        local v = e.Origin
            
        -- Swap locations
        e.Origin = QC.Self.Origin
        QC.Self.Origin = v
    end
end

Hooks.RegisterQCPost("PutClientInServer",PutClientInServer)
Hooks.RegisterQC("SUB_regen",RegenItem)

-- ID1
Hooks.RegisterQC("item_weapon",RemoveItem)
Hooks.RegisterQC("weapon_supershotgun",RemoveItem)
Hooks.RegisterQC("weapon_nailgun",RemoveItem)
Hooks.RegisterQC("weapon_supernailgun",RemoveItem)
Hooks.RegisterQC("weapon_grenadelauncher",RemoveItem)
Hooks.RegisterQC("weapon_rocketlauncher",RemoveItem)
Hooks.RegisterQC("weapon_lightning",RemoveItem)
Hooks.RegisterQC("item_shells",ConvertToRockets)
Hooks.RegisterQC("item_spikes",ConvertToRockets)
Hooks.RegisterQC("item_cells",ConvertToRockets)

-- Hipnotic
Hooks.RegisterQC("weapon_laser_gun",RemoveItem)
Hooks.RegisterQC("weapon_mjolnir",RemoveItem)
Hooks.RegisterQC("weapon_proximity_gun",RemoveItem)

-- Rogue
Hooks.RegisterQC("item_lava_spikes",ConvertToRockets)
Hooks.RegisterQC("item_plasma",ConvertToRockets)

if not cvar_rocketdm_rogue_multirocket:GetBool() then
    Hooks.RegisterQC("item_multi_rockets",ConvertToRockets)
end

