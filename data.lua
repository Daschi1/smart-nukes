local enable_smart_nuke = settings.startup["smart-nukes-setting-enable-smart-nuke"].value
local enable_environmental_nuke = settings.startup["smart-nukes-setting-enable-environmental-nuke"].value

if enable_smart_nuke then
    require("prototype.smart-nuke")
end
if enable_environmental_nuke then
    require("prototype.environmental-nuke")
end

if enable_smart_nuke or enable_environmental_nuke then
    -- trigger-target-type for enviroment targeting
    --- @type data.TriggerTargetType
    smart_nukes_trigger_target_type = {
        type = "trigger-target-type",
        name = "smart-nukes-trigger-target-type-environmental"
    }

    local smart_nukes_technology = {
        type = "technology",
        name = "smart-nukes-technology",
        icons = {
            {
                icon = "__base__/graphics/technology/atomic-bomb.png",
                icon_size = 256,
                tint = { r = .4, g = .4, b = 1, a = 1 }
            }
        },
        effects = {},
        prerequisites = { "atomic-bomb", "cliff-explosives" },
        unit = {
            count = 2000,
            ingredients = {
                { "automation-science-pack", 1 },
                { "logistic-science-pack",   1 },
                { "chemical-science-pack",   1 },
                { "military-science-pack",   1 },
                { "production-science-pack", 1 },
                { "utility-science-pack",    1 }
            },
            time = 60
        }
    }
    if enable_smart_nuke then
        table.insert(smart_nukes_technology.effects, { type = "unlock-recipe", recipe = "smart-nuke" })
    end
    if enable_environmental_nuke then
        table.insert(smart_nukes_technology.effects, { type = "unlock-recipe", recipe = "environmental-nuke" })
    end

    data:extend({
        smart_nukes_trigger_target_type,
        smart_nukes_technology
    })
end
