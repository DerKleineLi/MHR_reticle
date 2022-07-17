-- make use of the module of MHR_Overlay
local quest_status = require("MHR_Overlay.Game_Handler.quest_status");
quest_status.init_module();

-- make use of the module of mhrise-coavins-dps
local STATE  = require 'mhrise-coavins-dps.state'
STATE.SCENE_MANAGER_VIEW = sdk.call_native_func(sdk.get_native_singleton("via.SceneManager"), sdk.find_type_definition("via.SceneManager"), "get_MainView")
local CORE   = require 'mhrise-coavins-dps.core'

log.info("[reticle.lua] loaded")

local cfg = json.load_file("reticle_settings.json")

if not cfg then
    cfg = {
        enabled = true,
        size = 1,
    }
end

re.on_config_save(
    function()
        json.dump_file("reticle_settings.json", cfg)
    end
)

function draw_reticle()
    local should_draw = false
    quest_status.update_is_online();
    quest_status.update_is_result_screen();
    
    if quest_status.index < 2 then
        quest_status.update_is_training_area();

        if quest_status.is_training_area then
            should_draw = true
        end
    elseif quest_status.is_result_screen then
        should_draw = true
    elseif quest_status.index == 2 then
        should_draw = true
    end

    if should_draw then
        CORE.readScreenDimensions()
        local screen_w = STATE.SCREEN_W
        local screen_h = STATE.SCREEN_H
        draw.filled_rect(screen_w/2-cfg.size, screen_h/2-cfg.size, cfg.size*2, cfg.size*2, 0xFFFFFF00)
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
        imgui.tree_pop()
    end
)



