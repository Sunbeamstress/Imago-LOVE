local MAX_WIDTH = 120
local MAX_HEIGHT = 1200

local greeting = [[

  Welcome to {The Imago v0.4!|201}

  Enter CTRL+C to clear this message.

]]



function sample_cell_color(x, y)
    if app.palette_active then
        return
    end

    x = x or text_map.cell_x
    y = y or text_map.cell_y

    local col = text_map.map[y][x].color

    app.active_color = col
end



function select_cell(x, y)
    if app.palette_active then
        return
    end

    app.init_typing_column = x

    text_map.cell_x = x
    text_map.cell_y = y
end



function move_cell(x, y)
    local cx = math.clamp(text_map.cell_x + x, 1, text_map.num_cols)
    local cy = math.clamp(text_map.cell_y + y, 1, text_map.num_rows)

    select_cell(cx, cy)

    -- Nudge the camera if we're too far out of bounds
    local y1 = math.floor((app.camera.y * -1) + 1)
    local y2 = y1 + 58

    local new_y
    if cy > y2 then
        new_y = app.camera.y - y
        if new_y < 0 - MAX_HEIGHT then new_y = 0 end
        app.camera.y = new_y
    elseif cy < y1 then
        new_y = app.camera.y - y
        if new_y > 0 then new_y = 0 end
        app.camera.y = new_y
    end
end



function select_swatch(x, y)
    if not app.palette_active then
        return
    end

    palette.cell_x = x
    palette.cell_y = y

    local n = palette.map[palette.cell_y][palette.cell_x]
    local num = tostring(n):zeropad(3)

    if app.last_control ~= "mouse" then
        app.active_color = num
    end
end



function move_swatch(x, y)
    local cx = math.clamp(palette.cell_x + x, 1, palette.num_cols)
    local cy = math.clamp(palette.cell_y + y, 1, palette.num_rows)

    select_swatch(cx, cy)
end



function set_cell_char(char, x, y)
    if app.palette_active then
        return
    end

    char = char or " "

    if string.byte(char) < 32 or string.byte(char) > 122 then
        return
    end

    x = x or text_map.cell_x
    y = y or text_map.cell_y

    text_map.map[y][x].char = char

    app.last_char = char
end



function set_cell_color(x, y)
    if app.palette_active then
        return
    end

    local col = app.active_color

    x = x or text_map.cell_x
    y = y or text_map.cell_y

    text_map.map[y][x].color = col
end



function type_cell_char(char, x, y)
    if app.palette_active then
        return
    end

    local col = app.active_color

    x = x or text_map.cell_x
    y = y or text_map.cell_y

    text_map.map[y][x].char = char
    text_map.map[y][x].color = col

    local new_x = text_map.cell_x + 1
    if new_x > text_map.num_cols then
        new_x = text_map.num_cols
    end

    text_map.cell_x = new_x
end



function backspace_cell_char()
    if app.palette_active then
        return
    end

    local new_x = text_map.cell_x - 1
    if new_x < 1 then
        new_x = 1
    end

    text_map.cell_x = new_x

    local x = text_map.cell_x
    local y = text_map.cell_y
    text_map.map[y][x].char = " "
end



function goto_newline()
    if app.palette_active then
        return
    end

    local new_y = text_map.cell_y + 1
    if new_y < 1 then
        new_y = 1
    end

    local new_x = (app.init_typing_column > -1 and app.init_typing_column) or text_map.cell_x

    text_map.cell_x = new_x
    text_map.cell_y = new_y
end



function set_mouse_visibility()
    if not app.instructions_cleared then
        love.mouse.setVisible(false)
        return
    end

    if app.last_control ~= "mouse" and app.scrolling == "none" then
        love.mouse.setVisible(false)
    else
        love.mouse.setVisible(true)
    end
end



function draw_mouse_hint()
    -- Handles scrolling border indicators and more.
    if not love.mouse.isVisible() then
        return
    end

    -- Scrolling indicators
    local x1 = 0
    local y1 = app.size.height - (4 + toolbar.height)
    local w1 = app.size.width
    local h1 = 2

    local x2 = 0
    local y2 = status_bar.height
    local w2 = app.size.width
    local h2 = 2

    local thresh = -1200 + (app.size.height / text_map.cell_height) - (toolbar.height / text_map.cell_height) - 2
    if app.scrolling == "up" and app.camera.y > thresh then
        set_rgb(255, 165, 230, 192)
        love.graphics.rectangle("fill", x1, y1, w1, h1)
        set_rgb(235, 135, 215, 128)
        love.graphics.rectangle("fill", x1, y1 - 2, w1, 1)
        set_rgb(215, 105, 200, 64)
        love.graphics.rectangle("fill", x1, y1 - 4, w1, 1)
    elseif app.scrolling == "down" and app.camera.y < 0 then
        set_rgb(255, 165, 230, 192)
        love.graphics.rectangle("fill", x2, y2, w2, h2)
        set_rgb(235, 135, 215, 128)
        love.graphics.rectangle("fill", x2, y2 + 2, w2, 1)
        set_rgb(215, 105, 200, 64)
        love.graphics.rectangle("fill", x2, y2, w2, 1)
    end
end



-- $$$$$$$$\                  $$\ $$\                           
-- \__$$  __|                 $$ |$$ |                          
--    $$ | $$$$$$\   $$$$$$\  $$ |$$$$$$$\   $$$$$$\   $$$$$$\  
--    $$ |$$  __$$\ $$  __$$\ $$ |$$  __$$\  \____$$\ $$  __$$\ 
--    $$ |$$ /  $$ |$$ /  $$ |$$ |$$ |  $$ | $$$$$$$ |$$ |  \__|
--    $$ |$$ |  $$ |$$ |  $$ |$$ |$$ |  $$ |$$  __$$ |$$ |      
--    $$ |\$$$$$$  |\$$$$$$  |$$ |$$$$$$$  |\$$$$$$$ |$$ |      
--    \__| \______/  \______/ \__|\_______/  \_______|\__|      



toolbar = {
    height = 32,
    width = 0,
    label = "",
    desc = "",
    active_tool = 1,

    tools = {
        [1] = {name = "Type", icon = "type_tool", desc = "Any key: Type naturally into the text map."},
        [2] = {name = "Text Pen", icon = "text_pen_tool", desc = "Any key: Change the cell's character. Enter: Use the last applied character without changing color."},
        [3] = {name = "Pen", icon = "pen_tool", desc = "Mouse Left, Space Bar: Alter a cell's color."},
        [4] = {name = "Eyedropper", icon = "eyedropper_tool", desc = "Mouse Left, Space Bar, Enter: Sample the current cell's color."},
        [5] = {name = "Clear", icon = "clear_tool", desc = "[Shortcut: CTRL+C] Clear the current text map.",
            on_use = function ()
                clear_text_map()
            end
        },
        [6] = {name = "Export", icon = "export_tool", desc = "[Shortcut: CTRL+E] Click to copy the current canvas to your clipboard.",
            on_use = function()
                transfer_text_map_to_clipboard()
            end
        },
        [7] = {name = "Import", icon = "import_tool", desc = "[Shortcut: CTRL+I] Import Aetolia-formatted text.",
            on_use = function()
                get_text_map_from_clipboard()
            end
        },
        [8] = {name = "Mudlet HTML Import", icon = "mudlet_import_tool", desc = "Import Mudlet HTML-formatted text.",
            on_use = function()

            end
        },
    },
}



-- Process the icon for each tool and create new images.
for t, t_tbl in pairs(toolbar.tools) do
    if t_tbl.icon then
        toolbar.tools[t].image = love.graphics.newImage("img/%s.png" % t_tbl.icon)
    end
end



function draw_toolbar()
    toolbar.width = app.size.width

    toolbar.label = ""
    toolbar.desc = ""

    -- Toolbar background.
    set_rgb(0, 0, 0)
    love.graphics.rectangle(
        "fill",
        0, app.size.height - toolbar.height,
        toolbar.width, toolbar.height
    )

    -- Toolbar buttons.
    for t, t_tbl in pairs(toolbar.tools) do
        local button_active = false

        local w, h = 24, 24

        local left_margin = 4
        local x = ((t - 1) * (w + 4)) + left_margin
        local y = app.size.height - (toolbar.height - 4)

        if mouse_is_over(x, y, w, h) then
            button_active = true
        end

        -- Draw the button.
        local color = {0, 0, 0, 0}

        if button_active then
            toolbar.label = t_tbl.name
            toolbar.desc = t_tbl.desc

            color = {255, 0, 0, 64}

            if love.mouse.isDown(1) then
                -- If it's a tool you use by clicking, just use it.
                if toolbar.tools[t].on_use then
                    toolbar.tools[t].on_use()
                else
                    -- otherwise, set it to the active tool.
                    toolbar.active_tool = t
                end
            end
        end

        -- Draw button icon.
        if t_tbl.image then
            if toolbar.active_tool == t then
                set_rgb(255, 255, 255)
            else
                set_rgb(128, 128, 128)
            end
            love.graphics.draw(t_tbl.image, x, y)
        else
            set_rgb(0, 0, 0)
            love.graphics.rectangle("fill", x, y, w, h)
        end

        -- Draw the tool's border if it's active.
        if toolbar.active_tool == t then
            set_rgb(64, 180, 255)
            love.graphics.rectangle("line", x, y, w, h)
        end
    end



    -- Toolbar label.
    local x = 16
    local y = app.size.height - toolbar.height - 24
    cecho(toolbar.label, "244", x, y)

    local x = 214
    local y = app.size.height - toolbar.height - 24
    cecho(toolbar.desc, "244", x, y)
end



-- $$$$$$$\           $$\            $$\     $$\               
-- $$  __$$\          $$ |           $$ |    $$ |              
-- $$ |  $$ |$$$$$$\  $$ | $$$$$$\ $$$$$$\ $$$$$$\    $$$$$$\  
-- $$$$$$$  |\____$$\ $$ |$$  __$$\\_$$  _|\_$$  _|  $$  __$$\ 
-- $$  ____/ $$$$$$$ |$$ |$$$$$$$$ | $$ |    $$ |    $$$$$$$$ |
-- $$ |     $$  __$$ |$$ |$$   ____| $$ |$$\ $$ |$$\ $$   ____|
-- $$ |     \$$$$$$$ |$$ |\$$$$$$$\  \$$$$  |\$$$$  |\$$$$$$$\ 
-- \__|      \_______|\__| \_______|  \____/  \____/  \_______|



palette = {
    width = 0,
    height = 0,
    num_cols = 12,
    num_rows = 22,
    cell_x = 0,
    cell_y = 0,
    map = {
         [1] = {16, 22, 28, 34, 40, 46, 82, 76, 70, 64, 58, 52},
         [2] = {17, 23, 29, 35, 41, 47, 83, 77, 71, 65, 59, 53},
         [3] = {18, 24, 30, 36, 42, 48, 84, 78, 72, 66, 60, 54},
         [4] = {19, 25, 31, 37, 43, 49, 85, 79, 73, 67, 61, 55},
         [5] = {20, 26, 32, 38, 44, 50, 86, 80, 74, 68, 62, 56},
         [6] = {21, 27, 33, 39, 45, 51, 87, 81, 75, 69, 63, 57},

         [7] = {93, 99, 105, 111, 117, 123, 159, 153, 147, 141, 135, 129},
         [8] = {92, 98, 104, 110, 116, 122, 158, 152, 146, 140, 134, 128},
         [9] = {91, 97, 103, 109, 115, 121, 157, 151, 145, 139, 133, 127},
        [10] = {90, 96, 102, 108, 114, 120, 156, 150, 144, 138, 132, 126},
        [11] = {89, 95, 101, 107, 113, 119, 155, 149, 143, 137, 131, 125},
        [12] = {88, 94, 100, 106, 112, 118, 154, 148, 142, 136, 130, 124},

        [13] = {160, 166, 172, 178, 184, 190, 226, 220, 214, 208, 202, 196},
        [14] = {161, 167, 173, 179, 185, 191, 227, 221, 215, 209, 203, 197},
        [15] = {162, 168, 174, 180, 186, 192, 228, 222, 216, 210, 204, 198},
        [16] = {163, 169, 175, 181, 187, 193, 229, 223, 217, 211, 205, 199},
        [17] = {164, 170, 176, 182, 188, 194, 230, 224, 218, 212, 206, 200},
        [18] = {165, 171, 177, 183, 189, 195, 231, 225, 219, 213, 207, 201},

        -- Grayscale
        [19] = {232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243},
        [20] = {255, 254, 253, 252, 251, 250, 249, 248, 247, 246, 245, 244},

        -- ANSI colors
        [21] = {0, 0, 0, 1, 2, 3, 4, 5, 6, 7, 0, 0},
        [22] = {0, 0, 8, 9, 10, 11, 12, 13, 14, 15, 0, 0},
    }
}



function draw_palette()
    if not app.palette_active then
        return
    end

    -- Transparent background to temporarily cover app
    set_rgb(0, 0, 0, 128)
    love.graphics.rectangle("fill", 0, 0, app.size.width, app.size.height)

    local top_margin = status_bar.height

    local x, y, w, h, inc
    local padding = 2
    local x_offset = app.size.width - ((24 + padding) * 12)

    for row, _ in pairs(palette.map) do
        for col, n in ipairs(palette.map[row]) do
            w, h = 24, 24

            x = (w + padding) * (col - 1) + x_offset
            y = (h + padding) * (row - 1) + top_margin

            local num = tostring(n):zeropad(3)

            set_color(num)
            love.graphics.rectangle("fill", x, y, w, h)

            if mouse_is_over(x, y, w, h) and app.last_control == "mouse" then
                select_swatch(col, row)

                if love.mouse.isDown(1) then
                    app.active_color = num
                end
            end
        end
    end

    -- Highlight the currently selected cell
    x = (w + padding) * (palette.cell_x - 1) + x_offset
    y = (h + padding) * (palette.cell_y - 1) + top_margin
    set_rgb(255, 255, 255)
    love.graphics.rectangle("line", x - 1, y - 1, w + 2, h + 2)
    set_rgb(255, 255, 255, 128)
    love.graphics.rectangle("line", x, y, w, h)
end



--  $$$$$$\    $$\                $$\                               $$$$$$$\                      
-- $$  __$$\   $$ |               $$ |                              $$  __$$\                     
-- $$ /  \__|$$$$$$\    $$$$$$\ $$$$$$\   $$\   $$\  $$$$$$$\       $$ |  $$ | $$$$$$\   $$$$$$\  
-- \$$$$$$\  \_$$  _|   \____$$\\_$$  _|  $$ |  $$ |$$  _____|      $$$$$$$\ | \____$$\ $$  __$$\ 
--  \____$$\   $$ |     $$$$$$$ | $$ |    $$ |  $$ |\$$$$$$\        $$  __$$\  $$$$$$$ |$$ |  \__|
-- $$\   $$ |  $$ |$$\ $$  __$$ | $$ |$$\ $$ |  $$ | \____$$\       $$ |  $$ |$$  __$$ |$$ |      
-- \$$$$$$  |  \$$$$  |\$$$$$$$ | \$$$$  |\$$$$$$  |$$$$$$$  |      $$$$$$$  |\$$$$$$$ |$$ |      
--  \______/    \____/  \_______|  \____/  \______/ \_______/       \_______/  \_______|\__|      



status_bar = {
    height = 32,
    width = 0,
}



function draw_status_bar()
    status_bar.width = app.size.width

    -- background
    set_rgb(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, app.size.width, status_bar.height)

    -- slight drop shadow
    set_rgb(0, 0, 0, 192)
    love.graphics.line(0, status_bar.height + 1, app.size.width, status_bar.height + 1)
    set_rgb(0, 0, 0, 128)
    love.graphics.line(0, status_bar.height + 2, app.size.width, status_bar.height + 2)

    local text_height = app.font:getHeight("X")

    local x = 8
    local y = (status_bar.height * 0.5) - (text_height * 0.5) + 4

    -- Cursor
    cecho("X:", "240", 8, y)
    cecho("Y:", "240", 74, y)

    cecho(text_map.cell_x, "032", 32, y)
    cecho(text_map.cell_y, "032", 98, y)

    set_rgb(255, 255, 255)
    love.graphics.draw(app.icon.cell_pos, 8, 3)

    -- Active character
    local lc = app.last_char
    set_rgb(0, 0, 20)
    love.graphics.rectangle("fill", 128, 3, 28, 28)
    if app.active_color == "000" then
        set_rgb(unpack(color_table["007"]))
    else
        set_rgb(unpack(color_table[app.active_color]))
    end

    cecho(lc, app.active_color, 138, y)

    -- Active swatch
    set_rgb(unpack(color_table[app.active_color]))
    love.graphics.rectangle("fill", 160, 3, 28, 28)

    local r = color_table[app.active_color][1]
    local g = color_table[app.active_color][2]
    local b = color_table[app.active_color][3]

    -- brighten the color so we can see it!
    r = math.clamp(math.round(r * 1.5), 1, 255)
    g = math.clamp(math.round(g * 1.5), 1, 255)
    b = math.clamp(math.round(b * 1.5), 1, 255)
    set_rgb(r, g, b)
    love.graphics.print("%s" % app.active_color, 192, y)

    set_rgb(255, 255, 255)
    love.graphics.draw(app.icon.color, 192, 3)

    -- Last 10 swatches

    -- echo("Mouse: %s %s" % {tostring(mx):jleft(4), tostring(my):jleft(4)}, x, y)

    -- x = 360
    -- echo("Active cell: %s %s" % {tostring(text_map.cell_x):jleft(3), tostring(text_map.cell_y):jleft(3)}, x, y)

    -- Active color
    -- x = 580
    -- cecho("Active color:", "242", x, y)

    -- x = 700
    -- cecho(tostring(app.active_color), app.active_color, x, y)

    -- x = 940
    -- echo("Active swatch: %s %s" % {tostring(palette.cell_x), tostring(palette.cell_y)}, x, y)

    -- Camera
    local c_str = "Camera Y: %s" % tostring(app.camera.y)
    echo(c_str, app.size.width - 214, y)

    -- FPS
    local f_str = "FPS: %s" % tostring(love.timer.getFPS())
    echo(f_str, app.size.width - 84, y)

    set_rgb(255, 255, 255)
    love.graphics.draw(app.icon.framerate, app.size.width - 84, 3)
end



-- $$$$$$$$\                  $$\   $$\     $$\           
-- \__$$  __|                 $$ |  $$ |    \__|          
--    $$ | $$$$$$\   $$$$$$\  $$ |$$$$$$\   $$\  $$$$$$\  
--    $$ |$$  __$$\ $$  __$$\ $$ |\_$$  _|  $$ |$$  __$$\ 
--    $$ |$$ /  $$ |$$ /  $$ |$$ |  $$ |    $$ |$$ /  $$ |
--    $$ |$$ |  $$ |$$ |  $$ |$$ |  $$ |$$\ $$ |$$ |  $$ |
--    $$ |\$$$$$$  |\$$$$$$  |$$ |  \$$$$  |$$ |$$$$$$$  |
--    \__| \______/  \______/ \__|   \____/ \__|$$  ____/ 
--                                              $$ |      
--                                              $$ |      
--                                              \__|      



function draw_tooltip()
end



-- $$$$$$$$\                    $$\           $$\      $$\                     
-- \__$$  __|                   $$ |          $$$\    $$$ |                    
--    $$ | $$$$$$\  $$\   $$\ $$$$$$\         $$$$\  $$$$ | $$$$$$\   $$$$$$\  
--    $$ |$$  __$$\ \$$\ $$  |\_$$  _|        $$\$$\$$ $$ | \____$$\ $$  __$$\ 
--    $$ |$$$$$$$$ | \$$$$  /   $$ |          $$ \$$$  $$ | $$$$$$$ |$$ /  $$ |
--    $$ |$$   ____| $$  $$<    $$ |$$\       $$ |\$  /$$ |$$  __$$ |$$ |  $$ |
--    $$ |\$$$$$$$\ $$  /\$$\   \$$$$  |      $$ | \_/ $$ |\$$$$$$$ |$$$$$$$  |
--    \__| \_______|\__/  \__|   \____/       \__|     \__| \_______|$$  ____/ 
--                                                                   $$ |      
--                                                                   $$ |      
--                                                                   \__|      



text_map = {
    x = 0, y = 0,
    width = 0, height = 0,
    cell_width = 0, cell_height = 0,

    cell_x = 1,
    cell_y = 1,

    num_rows = 0,
    num_cols = 0,

    map = {},

    canvas = nil,
}

text_map.y = status_bar.height



function init_text_map()
    text_map.cell_width = app.font:getWidth("X")
    text_map.cell_height = app.font:getHeight("X")

    text_map.width = text_map.cell_width * MAX_WIDTH
    text_map.height = text_map.cell_height * MAX_HEIGHT

    -- First time window resize
    app.size.width = text_map.width
    love.window.setMode(app.size.width, app.size.height, {
        resizable = true,
        centered = true,
    })

    app.window_x, app.window_y = love.window.getPosition()

    text_map.num_rows = math.floor(text_map.height / text_map.cell_height)
    text_map.num_cols = math.floor(text_map.width / text_map.cell_width)

    for row = 1, text_map.num_rows do
        text_map.map[row] = text_map.map[row] or {}
        for col = 1, text_map.num_cols do
            text_map.map[col] = text_map.map[col] or {}

            text_map.map[row][col] = {
                char = " ",
                color = "000"
            }
        end
    end
end



function clear_text_map()
    for row = 1, text_map.num_rows do
        text_map.map[row] = text_map.map[row] or {}
        for col = 1, text_map.num_cols do
            local cell = text_map.map[row][col]
            cell.char = " "
            cell.color = "000"
        end
    end
end



function update_text_map()

end



function get_cell_under_mouse()
    local mx, my = app.mouse.x, app.mouse.y
    local y_offset = text_map.cell_height * app.camera.y

    local y = (my - y_offset) - status_bar.height
    if y < 0 then return end

    local col = math.floor(mx / text_map.cell_width) + 1
    local row = math.floor(y / text_map.cell_height) + 1

    if row < 1 or row > text_map.num_rows then return end
    if col < 1 or col > text_map.num_cols then return end

    return col, row
end



function draw_text_map()
    -- Quantize camera
    local y_offset = text_map.cell_height * app.camera.y

    local tm_x = text_map.x + app.camera.x
    local tm_y = text_map.y + y_offset

    -- background
    set_rgb(4, 5, 6)
    love.graphics.rectangle("fill", tm_x, tm_y, text_map.width, text_map.height)

    -- Draw each character cell.
    -- local top_margin = status_bar.height

    for row = 1, text_map.num_rows do
        for col = 1, text_map.num_cols do
            local s = text_map.map[row][col].char
            if s == " " then
                -- do nothing
            else
                local c = text_map.map[row][col].color

                local x = (col - 1) * text_map.cell_width
                local y = tm_y + ((row - 1) * text_map.cell_height)
                local w = text_map.cell_width
                local h = text_map.cell_height

                cecho(s, c, x, y)
            end
        end
    end

    local hover_col, hover_row = get_cell_under_mouse()

    if hover_col and app.last_control == "mouse" then
        select_cell(hover_col, hover_row)

        if love.mouse.isDown(1) then
            set_cell_color(hover_col, hover_row)
        end
    end

    if app.instructions_cleared then
        -- Draw the cursor!
        -- local top_margin = status_bar.height

        local x = (text_map.cell_x - 1) * text_map.cell_width
        local y = ((text_map.cell_y - 1) * text_map.cell_height) + tm_y
        local w = text_map.cell_width
        local h = text_map.cell_height

        x = x - 2
        y = y - 2
        w = w + 4
        h = h + 4

        -- dark outline beneath
        set_rgb(0, 0, 192)
        love.graphics.rectangle("line", x, y + 1, w, h)
        love.graphics.rectangle("line", x + 1, y + 1, w, h)
        love.graphics.rectangle("line", x, y + 2, w, h)
        love.graphics.rectangle("line", x + 1, y + 2, w, h)

        -- primary cursor rectangle
        set_rgb(212, 154, 234)
        love.graphics.rectangle("line", x, y, w, h)
    end
end



function draw_guideline()
    local x = text_map.cell_width * 80
    local sx = text_map.cell_width * 120

    local dots = math.floor(text_map.height / 8)

    set_rgb(42, 50, 58)
    -- love.graphics.line(x, status_bar.height, x, status_bar.height + text_map.height)
    for i = 1, dots do
        local y = status_bar.height + (i * 8)
        love.graphics.points(x, y)
    end

    set_rgb(27, 36, 45)
    for i = 1, dots do
        local y = status_bar.height + (i * 8)
        love.graphics.points(sx, y)
    end
end



--  $$$$$$\                       $$\                         $$\ $$\                     
-- $$  __$$\                      $$ |                        $$ |$$ |                    
-- $$ /  \__| $$$$$$\  $$$$$$$\ $$$$$$\    $$$$$$\   $$$$$$\  $$ |$$ | $$$$$$\   $$$$$$\  
-- $$ |      $$  __$$\ $$  __$$\\_$$  _|  $$  __$$\ $$  __$$\ $$ |$$ |$$  __$$\ $$  __$$\ 
-- $$ |      $$ /  $$ |$$ |  $$ | $$ |    $$ |  \__|$$ /  $$ |$$ |$$ |$$$$$$$$ |$$ |  \__|
-- $$ |  $$\ $$ |  $$ |$$ |  $$ | $$ |$$\ $$ |      $$ |  $$ |$$ |$$ |$$   ____|$$ |      
-- \$$$$$$  |\$$$$$$  |$$ |  $$ | \$$$$  |$$ |      \$$$$$$  |$$ |$$ |\$$$$$$$\ $$ |      
--  \______/  \______/ \__|  \__|  \____/ \__|       \______/ \__|\__| \_______|\__|      



function imago_draw_interface()
    draw_text_map()
    draw_guideline()

    draw_palette()

    draw_toolbar()
    draw_status_bar()

    -- draw_tooltip()
    set_mouse_visibility()
    draw_mouse_hint()

    if not app.instructions_cleared then
        draw_instructions()
    end
end