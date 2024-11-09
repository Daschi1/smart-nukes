--- @param name string
--- @param color data.Color
--- @param order string
--- @param force data.ForceCondition
--- @param environmental boolean
--- @param decoratives boolean
return function(name, color, order, force, environmental, decoratives)
    -- explosions

    --- @param base_name string
    --- @param new_name string
    --- @return data.ExplosionPrototype
    local function create_explosion(base_name, new_name)
        local explosion = table.deepcopy(data.raw["explosion"][base_name])
        explosion.name = new_name
        if type(explosion.animations) == "table" and #explosion.animations > 0 then
            -- animations is an array
            for _, animation in pairs(explosion.animations) do
                animation.tint = color
            end
        else
            -- animations is a single object
            explosion.animations.tint = color
        end
        return explosion
    end
    local nuke_explosion = create_explosion("nuke-explosion", name .. "-explosion")
    local nuke_explosion_cluster = create_explosion("cluster-nuke-explosion", name .. "-explosion-cluster")
    local nuke_explosion_fire_smoke = create_explosion("atomic-fire-smoke", name .. "-explosion-fire-smoke")
    local nuke_explosion_shockwave = create_explosion("atomic-nuke-shockwave", name .. "-explosion-shockwave")

    -- smoke
    local nuke_smoke = table.deepcopy(data.raw["trivial-smoke"]["nuclear-smoke"])
    nuke_smoke.name = name .. "-smoke"
    nuke_smoke.color = color
    nuke_smoke.animation.tint = color

    -- projectiles

    --- @param base_name string
    --- @param new_name string
    --- @param target_entity_name string|nil
    --- @return data.ProjectilePrototype
    local function create_projectile(base_name, new_name, target_entity_name)
        local projectile = table.deepcopy(data.raw["projectile"][base_name])
        projectile.name = new_name

        if type(projectile.action) == "table" and #projectile.action > 0 then
            projectile.action[1].force = force
            if environmental then
                projectile.action[1].trigger_target_mask = { "smart-nukes-trigger-target-type-environmental" }
            end
        else
            projectile.action.force = force
            if environmental then
                projectile.action.trigger_target_mask = { "smart-nukes-trigger-target-type-environmental" }
            end
        end
        if target_entity_name then
            projectile.action[1].action_delivery.target_effects[1].entity_name = target_entity_name
        end
        return projectile
    end
    local nuke_projectile_ground_zero_projectile =
        create_projectile("atomic-bomb-ground-zero-projectile", name .. "-projectile-ground-zero-projectile")
    local nuke_projectile_wave = create_projectile("atomic-bomb-wave", name .. "-projectile-wave")
    if environmental then
        table.insert(nuke_projectile_wave.action, {
            type = "direct",
            action_delivery = {
                type = "instant",
                target_effects = {
                    type = "destroy-cliffs",
                    radius = 2
                }
            }
        })
    end
    if decoratives then
        table.insert(nuke_projectile_wave.action, {
            type = "direct",
            action_delivery = {
                type = "instant",
                target_effects = {
                    type = "destroy-decoratives",
                    radius = 3,
                    include_soft_decoratives = true, -- soft decoratives are decoratives with grows_through_rail_path = true
                    include_decals = true,
                    invoke_decorative_trigger = true,
                    decoratives_with_trigger_only = false, -- if true, destroys only decoratives that have trigger_effect set
                }
            }
        })
    end
    local nuke_projectile_wave_spawns_cluster_nuke_explosion =
        create_projectile(
            "atomic-bomb-wave-spawns-cluster-nuke-explosion",
            name .. "-projectile-wave-spawns-cluster-nuke-explosion",
            nuke_explosion_cluster.name
        )
    local nuke_projectile_wave_spawns_fire_smoke_explosion =
        create_projectile(
            "atomic-bomb-wave-spawns-fire-smoke-explosion",
            name .. "-projectile-wave-spawns-fire-smoke-explosion",
            nuke_explosion_fire_smoke.name
        )
    local nuke_projectile_wave_spawns_nuke_shockwave_explosion =
        create_projectile(
            "atomic-bomb-wave-spawns-nuke-shockwave-explosion",
            name .. "-projectile-wave-spawns-nuke-shockwave-explosion",
            nuke_explosion_shockwave.name
        )
    local nuke_projectile_wave_spawns_nuclear_smoke =
        create_projectile(
            "atomic-bomb-wave-spawns-nuclear-smoke",
            name .. "-projectile-wave-spawns-nuclear-smoke",
            nuke_smoke.name
        )
    local nuke_projectile = create_projectile("atomic-rocket", name .. "-projectile")

    local range_modifier = settings.startup["smart-nukes-setting-nuke-range-radius-modifier"].value
    --- Applies a nonlinear scaling function to the input `m`.
    -- This function scales values in a way that:
    -- - For `m >= 1`, it gradually increases up to 2.5 when `m = 10`.
    -- - For `m < 1`, it inversely scales down, reaching 0.25 when `m = 0.1`.
    -- @param m number The input multiplier value (expected range: 0.1 to 10).
    -- @return number The scaled multiplier value.
    local function scaled_multiplier(m)
        if m >= 1 then
            -- For m >= 1, scale using logarithmic increase to max out at 2.5 for m = 10
            return 1 + (math.log(m) / math.log(10)) * (2.5 - 1)
        else
            -- For m < 1, scale inversely to reach a minimum of 0.25 at m = 0.1
            return 1 - (math.log(1 / m) / math.log(10)) * (1 - 0.25)
        end
    end
    --- Clamps a number to be within a specified range.
    --- If the value is below the minimum, it returns the minimum; if it's above the maximum, it returns the maximum.
    ---@param value number The value to clamp.
    ---@param min number The lower bound.
    ---@param max number The upper bound.
    ---@return number The clamped value, constrained between `min` and `max`.
    function clamp(value, min, max)
        if value < min then
            return min
        elseif value > max then
            return max
        else
            return value
        end
    end

    -- Iterate over target_effects in reverse to safely remove multiple elements
    for i = #nuke_projectile.action.action_delivery.target_effects, 1, -1 do
        local effect = nuke_projectile.action.action_delivery.target_effects[i]
        if effect.type == "set-tile" and effect.tile_name == "nuclear-ground" then
            table.remove(nuke_projectile.action.action_delivery.target_effects, i)
        elseif effect.type == "destroy-cliffs" then
            if not environmental then
                table.remove(nuke_projectile.action.action_delivery.target_effects, i)
            end
        elseif effect.type == "create-entity" and effect.entity_name == "nuke-explosion" then
            effect.entity_name = nuke_explosion.name
        elseif effect.type == "camera-effect" then -- camera
            if not settings.startup["smart-nukes-setting-enable-nuke-flash"].value then
                table.remove(nuke_projectile.action.action_delivery.target_effects, i)
            else
                effect.duration = clamp(effect.duration * range_modifier, effect.duration, 255)
                effect.ease_in_duration = clamp(effect.ease_in_duration * range_modifier, effect.ease_in_duration, 255)
                effect.ease_out_duration = clamp(effect.ease_out_duration * range_modifier, effect.ease_out_duration, 255)
                effect.strength = math.max(effect.strength * range_modifier, effect.strength)
                effect.full_strength_max_distance = math.max(effect.full_strength_max_distance * range_modifier,
                    effect.full_strength_max_distance)
                effect.max_distance = math.max(effect.max_distance * range_modifier, effect.max_distance)
            end
        elseif effect.type == "create-entity" and effect.entity_name == "huge-scorchmark" then
            table.remove(nuke_projectile.action.action_delivery.target_effects, i)
        elseif effect.type == "destroy-decoratives" then
            if not decoratives then
                table.remove(nuke_projectile.action.action_delivery.target_effects, i)
            end
        elseif effect.type == "create-decorative" and effect.decorative == "nuclear-ground-patch" then
            table.remove(nuke_projectile.action.action_delivery.target_effects, i)
        elseif effect.type == "nested-result" and effect.action.type == "area" and effect.action.action_delivery.type == "projectile" and effect.action.action_delivery.projectile == "atomic-bomb-ground-zero-projectile" then
            effect.action.action_delivery.projectile = nuke_projectile_ground_zero_projectile.name
        elseif effect.type == "nested-result" and effect.action.type == "area" and effect.action.action_delivery.type == "projectile" and effect.action.action_delivery.projectile == "atomic-bomb-wave" then
            effect.action.action_delivery.projectile = nuke_projectile_wave.name
            effect.action.repeat_count = effect.action.repeat_count * range_modifier
            effect.action.radius = effect.action.radius * scaled_multiplier(range_modifier)
        elseif effect.type == "nested-result" and effect.action.type == "area" and effect.action.action_delivery.type == "projectile" and effect.action.action_delivery.projectile == "atomic-bomb-wave-spawns-cluster-nuke-explosion" then
            effect.action.action_delivery.projectile = nuke_projectile_wave_spawns_cluster_nuke_explosion.name
        elseif effect.type == "nested-result" and effect.action.type == "area" and effect.action.action_delivery.type == "projectile" and effect.action.action_delivery.projectile == "atomic-bomb-wave-spawns-fire-smoke-explosion" then
            effect.action.action_delivery.projectile = nuke_projectile_wave_spawns_fire_smoke_explosion.name
            effect.action.repeat_count = effect.action.repeat_count * range_modifier
            effect.action.radius = effect.action.radius * range_modifier
        elseif effect.type == "nested-result" and effect.action.type == "area" and effect.action.action_delivery.type == "projectile" and effect.action.action_delivery.projectile == "atomic-bomb-wave-spawns-nuke-shockwave-explosion" then
            effect.action.action_delivery.projectile = nuke_projectile_wave_spawns_nuke_shockwave_explosion.name
            effect.action.repeat_count = effect.action.repeat_count * range_modifier
            effect.action.radius = effect.action.radius * range_modifier
        elseif effect.type == "nested-result" and effect.action.type == "area" and effect.action.action_delivery.type == "projectile" and effect.action.action_delivery.projectile == "atomic-bomb-wave-spawns-nuclear-smoke" then
            effect.action.action_delivery.projectile = nuke_projectile_wave_spawns_nuclear_smoke.name
            effect.action.repeat_count = effect.action.repeat_count * range_modifier
            effect.action.radius = effect.action.radius * scaled_multiplier(range_modifier)
        elseif effect.type == "nested-result" and effect.action.type == "area" and effect.action.action_delivery.type == "instant" and effect.action.action_delivery.target_effects[1].type == "create-entity" and effect.action.action_delivery.target_effects[1].entity_name == "nuclear-smouldering-smoke-source" then
            table.remove(nuke_projectile.action.action_delivery.target_effects, i) -- smoldering
        end
    end

    -- ammo
    local nuke_ammo = table.deepcopy(data.raw["ammo"]["atomic-bomb"])
    nuke_ammo.name = name
    nuke_ammo.ammo_type.action.action_delivery.projectile = nuke_projectile.name
    nuke_ammo.icon = nil
    nuke_ammo.icons = { { icon = "__base__/graphics/icons/atomic-bomb.png", tint = color } }
    -- this is for conveyor belt images of the ammo
    for _, sprite in pairs(nuke_ammo.pictures.layers) do
        sprite.tint = color
    end
    nuke_ammo.stack_size = tonumber(settings.startup["smart-nukes-setting-nuke-stack-size"].value) or 20
    nuke_ammo.order = nuke_ammo.order .. "-" .. order .. "[smart-nukes]"


    -- recipe
    local nuke_recipe = table.deepcopy(data.raw["recipe"]["atomic-bomb"])
    nuke_recipe.name = name
    nuke_recipe.results[1].name = nuke_ammo.name

    return {
        nuke_explosion = nuke_explosion,
        nuke_explosion_cluster = nuke_explosion_cluster,
        nuke_explosion_fire_smoke = nuke_explosion_fire_smoke,
        nuke_explosion_shockwave = nuke_explosion_shockwave,
        nuke_smoke = nuke_smoke,
        nuke_projectile_ground_zero_projectile = nuke_projectile_ground_zero_projectile,
        nuke_projectile_wave = nuke_projectile_wave,
        nuke_projectile_wave_spawns_cluster_nuke_explosion = nuke_projectile_wave_spawns_cluster_nuke_explosion,
        nuke_projectile_wave_spawns_fire_smoke_explosion = nuke_projectile_wave_spawns_fire_smoke_explosion,
        nuke_projectile_wave_spawns_nuke_shockwave_explosion = nuke_projectile_wave_spawns_nuke_shockwave_explosion,
        nuke_projectile_wave_spawns_nuclear_smoke = nuke_projectile_wave_spawns_nuclear_smoke,
        nuke_projectile = nuke_projectile,
        nuke_ammo = nuke_ammo,
        nuke_recipe = nuke_recipe
    }
end
