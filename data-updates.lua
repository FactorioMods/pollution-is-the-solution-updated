-- Nuclear glass prevents biter nests.
local collision_mask_util = require("collision-mask-util")
local util = require("util")

data:extend{
    {
        type = "collision-layer",
        name = "fallout"
    }
}
local glass = data.raw.tile["nuclear-ground"]
if glass then
    local new_mask = "fallout"
    local glass_mask = util.table.deepcopy(glass.collision_mask)
    glass_mask.layers[new_mask] = true
    glass.collision_mask = glass_mask
    for _, prototype_group in pairs({"turret", "unit-spawner"}) do
        for __, prototype in pairs(data.raw[prototype_group]) do -- <- data.raw[prototype_group] is nil!
            if prototype.flags and not prototype.flags["player-creation"] then  
                local collision_mask = collision_mask_util.get_mask(prototype)
                collision_mask.layers[new_mask] = true
                prototype.collision_mask = collision_mask
            end
        end
    end
end