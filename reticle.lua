-- make use of the module of MHR_Overlay
local quest_status = require("MHR_Overlay.Game_Handler.quest_status");
quest_status.init_module();

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

d2d.register(
    function()
    end,
    function()
        if cfg.enabled then
            local draw = false
            quest_status.update_is_online();
            quest_status.update_is_result_screen();
            
            if quest_status.index < 2 then
                quest_status.update_is_training_area();
        
                if quest_status.is_training_area then
                    draw = true
                end
            elseif quest_status.is_result_screen then
                draw = true
            elseif quest_status.index == 2 then
                draw = true
            end

            if draw then
                local screen_w, screen_h = d2d.surface_size()
                d2d.fill_rect(screen_w/2-cfg.size, screen_h/2-cfg.size, cfg.size*2, cfg.size*2, 0xFF00FFFF)
            end
        end
    end
)
