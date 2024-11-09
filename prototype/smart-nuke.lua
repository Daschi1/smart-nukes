local create_nuke = require("prototype.create-nuke")

local smart_nuke_prototypes = create_nuke("smart-nuke", { r = .4, g = .4, b = 1, a = 1 }, "a", "enemy", false, false)
local smart_nuke_recipe = smart_nuke_prototypes["nuke_recipe"]
smart_nuke_recipe.ingredients = {
    { type = "item", name = "poison-capsule",  amount = 8 },
    { type = "item", name = "processing-unit", amount = 10 },
    { type = "item", name = "atomic-bomb",     amount = 1 }
}

for _, value in pairs(smart_nuke_prototypes) do
    data:extend({ value })
end
