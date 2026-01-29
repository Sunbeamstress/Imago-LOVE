-- How far to cycle through the toolbar before we hit things like clear/export/etc
local real_tool_max = 4

local TEXT_PEN = 2
local PEN = 3
local TYPE_PEN = 1
local EYEDROPPER = 4



function update_mouse(dt)
    app.mouse.x, app.mouse.y = love.mouse.getPosition()

    app.scrolling = "none"

    -- Below this section are things that need to be run only when the mouse is INSIDE the window!
    if not love.window.hasMouseFocus() then
        return
    end

    -- Scrolling detection.
    local x, y, w, h

    -- Scrolling down
    x = 0
    y = app.size.height - (10 + toolbar.height)
    w = app.size.width
    h = 10 + toolbar.height

    local speed = 32
    if app.shift_mod then speed = speed * 4 end
    if mouse_is_over(0, app.size.height - (10 + toolbar.height), app.size.width, 10 + toolbar.height) then
        app.scrolling = "up"
        local new_y = app.camera.y - (speed * dt)
        local thresh = -1200 + (app.size.height / text_map.cell_height) - (toolbar.height / text_map.cell_height) - 2
        if new_y < thresh then new_y = thresh end
        app.camera.y = new_y
    elseif mouse_is_over(0, 0, app.size.width, 10 + status_bar.height) then
        app.scrolling = "down"
        local new_y = app.camera.y + (speed * dt)
        if new_y > 0 then new_y = 0 end
        app.camera.y = new_y
    end
end



function mouse_is_over(x, y, w, h)
    -- local mx, my = love.mouse.getPosition()
    local mx, my = app.mouse.x, app.mouse.y
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

key_map.q = function ()
    if app.ctrl_mod then
        print("X: %s Y: %s" % {tostring(app.window_x), tostring(app.window_y)})
        love.event.quit()
    end
end

key_map.r = function ()
    if app.ctrl_mod then
        love.event.push("quit", "restart")
    end
end

key_map.e = function ()
    if app.ctrl_mod and app.shift_mod then
        map_dump()
    elseif app.ctrl_mod then
        transfer_text_map_to_clipboard()
    end
end

key_map.i = function ()
    if app.ctrl_mod then
        get_text_map_from_clipboard()
    end
end

key_map.c = function ()
    if app.ctrl_mod then
        clear_text_map()
    end
end

key_map.s = function ()
    if app.ctrl_mod then
        save_file()
    end
end

key_map.l = function ()
    if app.ctrl_mod then
        load_file()
    end
end

key_map.o = function ()
    if app.ctrl_mod then
        open_files()
    end
end

key_map.escape = function ()
    app.palette_active = false
end

key_map.tab = function ()
    app.palette_active = not app.palette_active
end

key_map.backspace = function ()
    if app.palette_active then
        return
    end


    if toolbar.active_tool == TYPE_PEN then
        backspace_cell_char()
    else
        set_cell_char()
    end
end

key_map.space = function ()
    if app.palette_active then
        app.palette_active = false
        return
    end

    if toolbar.active_tool == PEN then
        set_cell_color()
    elseif toolbar.active_tool == TEXT_PEN then
        set_cell_char()
    elseif toolbar.active_tool == EYEDROPPER then
        sample_cell_color()
    end
end

key_map["return"] = function ()
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
    elseif toolbar.active_tool == TYPE_PEN then
        goto_newline()
    end
end

local function process_move_key(x, y)
    if app.palette_active then
        move_swatch(x, y)
    else
        move_cell(x, y)
    end
end

key_map.up = function ()
    local x = 0
    local y = (app.shift_mod and -5) or -1
    process_move_key(x, y)
end

key_map.down = function ()
    local x = 0
    local y = (app.shift_mod and 5) or 1
    process_move_key(x, y)
end

key_map.left = function ()
    local x = (app.shift_mod and -5) or -1
    local y = 0
    process_move_key(x, y)
end

key_map.right = function ()
    local x = (app.shift_mod and 5) or 1
    local y = 0
    process_move_key(x, y)
end

key_map["f4"] = function ()
    app.chosen_tagline = false
    app.instructions_cleared = false
end

key_map["f2"] = function ()
    local at = toolbar.active_tool

    at = at + 1
    if at > real_tool_max then
        at = 1
    end

    toolbar.active_tool = at
end

key_map["f1"] = function ()
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

    app.ctrl_mod = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")
    app.alt_mod = love.keyboard.isDown("lalt") or love.keyboard.isDown("rshift")
    app.shift_mod = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")

    -- Process 'any' key
    key_map.any()

    if key_map[key] and (not app.override_keys or (app.ctrl_mod and key == "q")) then
        key_map[key]()
    end
end



function imago_keyrelease(key, code)
    app.ctrl_mod = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")
    app.alt_mod = love.keyboard.isDown("lalt") or love.keyboard.isDown("rshift")
    app.shift_mod = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
end



function imago_text_input(t)
    if app.override_keys then
        return
    end

    app.last_control = "key"

    if toolbar.active_tool == TYPE_PEN then
        type_cell_char(t)
    elseif toolbar.active_tool == TEXT_PEN then
        set_cell_color()
        set_cell_char(t)
    end
end