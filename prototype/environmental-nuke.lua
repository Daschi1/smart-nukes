local create_nuke = require("prototype.create-nuke")

local remove_decorations_environmental_nuke = settings.startup
    ["smart-nukes-setting-remove-decorations-environmental-nuke"].value
local function toboolean(value)
    return value ~= nil and value ~= false
end
local environmental_nuke_prototypes = create_nuke("environmental-nuke", { r = .4, g = 1, b = .4, a = 1 }, "b", "all",
    true, toboolean(remove_decorations_environmental_nuke))
local environmental_nuke_recipe = environmental_nuke_prototypes["nuke_recipe"]
environmental_nuke_recipe.ingredients = {
    { type = "item", name = "poison-capsule",   amount = 8 },
    { type = "item", name = "cliff-explosives", amount = 4 },
    { type = "item", name = "atomic-bomb",      amount = 1 }
}

for _, value in pairs(environmental_nuke_prototypes) do
    data:extend({ value })
end
