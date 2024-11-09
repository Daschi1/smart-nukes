--- @type data.ModBoolSettingPrototype
local enable_smart_nuke = {
    type = "bool-setting",
    name = "smart-nukes-setting-enable-smart-nuke",
    setting_type = "startup",
    default_value = true,
    order = "a[smart-nukes]-a[enable-smart-nuke]"
}

--- @type data.ModBoolSettingPrototype
local enable_environmental_nuke = {
    type = "bool-setting",
    name = "smart-nukes-setting-enable-environmental-nuke",
    setting_type = "startup",
    default_value = true,
    order = "a[smart-nukes]-b[enable-environmental-nuke]"
}

--- @type data.ModBoolSettingPrototype
local toggle_nuke_flash = {
    type = "bool-setting",
    name = "smart-nukes-setting-enable-nuke-flash",
    setting_type = "startup",
    default_value = true,
    order = "a[smart-nukes]-c[enable-nuke-flash]"
}

--- @type data.ModDoubleSettingPrototype
local nuke_range_radius = {
    type = "double-setting",
    name = "smart-nukes-setting-nuke-range-radius-modifier",
    setting_type = "startup",
    default_value = 1.0,
    minimum_value = 0.1,
    maximum_value = 10.0,
    order = "a[smart-nukes]-d[nuke-range-radius-modifier]"
}

--- @type data.ModIntSettingPrototype
local nuke_stack_size = {
    type = "int-setting",
    name = "smart-nukes-setting-nuke-stack-size",
    setting_type = "startup",
    default_value = 20,
    minimum_value = 1,
    maximum_value = 100,
    order = "a[smart-nukes]-e[nuke-stack-size]"
}

--- @type data.ModBoolSettingPrototype
local remove_decorations_environmental_nuke = {
    type = "bool-setting",
    name = "smart-nukes-setting-remove-decorations-environmental-nuke",
    setting_type = "startup",
    default_value = false,
    order = "a[smart-nukes]-f[remove-decorations-environmental-nuke]"
}

data:extend({
    enable_smart_nuke,
    enable_environmental_nuke,
    toggle_nuke_flash,
    nuke_range_radius,
    nuke_stack_size,
    remove_decorations_environmental_nuke
})
