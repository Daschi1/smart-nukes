local enable_smart_nuke = settings.startup["smart-nukes-setting-enable-smart-nuke"].value
local enable_environmental_nuke = settings.startup["smart-nukes-setting-enable-environmental-nuke"].value

if enable_smart_nuke or enable_environmental_nuke then
    --- @param entity data.EntityPrototype
    local function set_trigger_target_mask(entity)
        entity.trigger_target_mask = entity.trigger_target_mask or {}
        table.insert(entity.trigger_target_mask, "smart-nukes-trigger-target-type-environmental")
    end

    -- all trees
    for _, tree in pairs(data.raw["tree"]) do
        set_trigger_target_mask(tree)
    end

    -- simple-entities, ingame used for rocks
    for _, mineable_rock in pairs(data.raw["simple-entity"]) do
        set_trigger_target_mask(mineable_rock)
    end
end
