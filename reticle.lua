-- make use of the module of MHR_Overlay
local quest_status = require("reticle.quest_status");
quest_status.init_module();
main_view = sdk.call_native_func(sdk.get_native_singleton("via.SceneManager"), sdk.find_type_definition("via.SceneManager"), "get_MainView")

log.info("[reticle.lua] loaded")

local cfg = json.load_file("reticle_settings.json")

cfg = cfg or {}
cfg.enabled = cfg.enabled or true
cfg.size = cfg.size or 1
cfg.color_weapon_off = cfg.color_weapon_off or 0x80FFFF00
cfg.color_weapon_on = cfg.color_weapon_on or 0xFFFFFF00

re.on_config_save(
    function()
        json.dump_file("reticle_settings.json", cfg)
    end
)

function draw_reticle()
    if quest_status.should_draw() then
        local size = main_view:call("get_Size")
        if not size then return end
        local screen_w = size:get_field("w")
        local screen_h = size:get_field("h")
        local player_manager = sdk.get_managed_singleton("snow.player.PlayerManager");
        local master_player = player_manager:call("findMasterPlayer");
        local weapon_drawn = master_player:call("isWeaponOn")
        if weapon_drawn then 
            draw.filled_circle((screen_w+1)/2, (screen_h+1)/2, cfg.size, cfg.color_weapon_on, 30)
        else
            draw.filled_circle((screen_w+1)/2, (screen_h+1)/2, cfg.size, cfg.color_weapon_off, 30)
        end
        
    end
end

re.on_frame(function()
	if cfg.enabled then
		draw_reticle()
    end
end)

re.on_draw_ui(
    function() 
        if not imgui.tree_node("Reticle") then return end

        local changed, value = imgui.checkbox("Enabled", cfg.enabled)
        if changed then cfg.enabled = value end

        changed, value = imgui.slider_int("Size", cfg.size, 1, 20)
        if changed then cfg.size = value end

        if imgui.tree_node("Color when weapon is off") then
            changed, value = imgui.color_picker("Color", cfg.color_weapon_off, "color for reticle")
            if changed then cfg.color_weapon_off = value end
            imgui.tree_pop()
        end

        if imgui.tree_node("Color when weapon is on") then
            changed, value = imgui.color_picker("Color", cfg.color_weapon_on, "color for reticle")
            if changed then cfg.color_weapon_on = value end
            imgui.tree_pop()
        end

        imgui.tree_pop()
    end
)



