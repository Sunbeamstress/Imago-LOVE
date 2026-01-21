-- How far to cycle through the toolbar before we hit things like clear/export/etc
local real_tool_max = 4

local TEXT_PEN = 1
local PEN = 2
local TYPE = 3
local EYEDROPPER = 4



function mouse_is_over(x, y, w, h)
    local mx, my = love.mouse.getPosition()
    return mx >= x and mx <= x + w and my >= y and my <= y + h
end



function imago_mouse_movement(x, y, dx, dy)
    app.last_control = "mouse"
end



local key_map = {}

-- Special catch-all key
key_map.any = function ()
    if not app.instructions_cleared then
        app.override_keys = true
        app.instructions_cleared = true
    end
end

key_map.q = function (ctrl, alt, shift)
    if ctrl then
        love.event.quit()
    end
end

key_map.r = function (ctrl, alt, shift)
    if ctrl then
        love.event.push("quit", "restart")
    end
end

key_map.e = function (ctrl, alt, shift)
    if ctrl and shift then
        map_dump()
    elseif ctrl then
        transfer_text_map_to_clipboard()
    end
end

key_map.i = function (ctrl, alt, shift)
    if ctrl then
        get_text_map_from_clipboard()
    end
end

key_map.c = function (ctrl, alt, shift)
    if ctrl then
        clear_text_map()
    end
end

key_map.s = function (ctrl, alt, shift)
    if ctrl then
        save_file()
    end
end

key_map.l = function (ctrl, alt, shift)
    if ctrl then
        load_file()
    end
end

key_map.o = function (ctrl, alt, shift)
    if ctrl then
        open_files()
    end
end

key_map.escape = function (ctrl, alt, shift)
    app.palette_active = false
end

key_map.tab = function (ctrl, alt, shift)
    app.palette_active = not app.palette_active
end

key_map.backspace = function (ctrl, alt, shift)
    if not app.palette_active then
        set_cell_char()
    end
end

key_map.space = function (ctrl, alt, shift)
    if app.palette_active then
        app.palette_active = false
        return
    end

    print("Active tool: %s" % toolbar.active_tool)

    if toolbar.active_tool == PEN then
        set_cell_color()
    elseif toolbar.active_tool == TEXT_PEN then
        set_cell_char()
    elseif toolbar.active_tool == EYEDROPPER then
        sample_cell_color()
    end
end

key_map["return"] = function (ctrl, alt, shift)
    if app.palette_active then
        app.palette_active = false
        return
    end

    if toolbar.active_tool == PEN then
        set_cell_color()
    elseif toolbar.active_tool == TEXT_PEN then
        set_cell_char(app.last_char)
    elseif toolbar.active_tool == EYEDROPPER then
        sample_cell_color()
    end
end

local function process_move_key(x, y)
    if app.palette_active then
        move_swatch(x, y)
    else
        move_cell(x, y)
    end
end

key_map.up = function (ctrl, alt, shift)
    process_move_key(0, -1)
end

key_map.down = function (ctrl, alt, shift)
    process_move_key(0, 1)
end

key_map.left = function (ctrl, alt, shift)
    process_move_key(-1, 0)
end

key_map.right = function (ctrl, alt, shift)
    process_move_key(1, 0)
end

key_map["f4"] = function (ctrl, alt, shift)
    app.chosen_tagline = false
    app.instructions_cleared = false
end

key_map["f2"] = function (ctrl, alt, shift)
    local at = toolbar.active_tool

    at = at + 1
    if at > real_tool_max then
        at = 1
    end

    toolbar.active_tool = at
end

key_map["f1"] = function (ctrl, alt, shift)
    local at = toolbar.active_tool

    at = at - 1
    if at == 0 then
        at = real_tool_max
    end

    toolbar.active_tool = at
end




function imago_keypress(key, code, rep)
    app.last_control = "key"
    app.override_keys = false

    local ctrl_mod = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")
    local alt_mod = love.keyboard.isDown("lalt") or love.keyboard.isDown("rshift")
    local shift_mod = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")



    -- Process 'any' key
    key_map.any()

    if key_map[key] and
    (not app.override_keys or (ctrl_mod and key == "q")) then
        key_map[key](ctrl_mod, alt_mod, shift_mod)
    end

end



function imago_text_input(t)
    if app.override_keys then
        return
    end

    app.last_control = "key"

    if toolbar.active_tool == TEXT_PEN then
        set_cell_color()
        set_cell_char(t)
    end
end