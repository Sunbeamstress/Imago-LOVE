-- Lop the leading zeroes off color codes for Aetolia-friendly equivalents
local function tokenize(col_str)
    return col_str:gsub("^[0]+", "")
end



function compile_text_map()
    local map_str_tbl = {}

    for row = 1, text_map.num_rows do
        map_str_tbl[row] = ""

        local row_str = ""
        local last_color = "000"
        local last_char = " "
        local last_control_code = ""

        for col = 1, text_map.num_cols do
            local char = text_map.map[row][col].char
            local color = text_map.map[row][col].color

            -- Treat any black cells as space characters, to keep the file clean
            if color == "000" then
                char = " "
            end

            local neutral = color == "000" or color == "007"
            local last_neutral = last_color == "000" or last_color == "007"

            if char ~= " " and color ~= last_color then
                if color == "007" and not last_neutral then
                    row_str = "%s|%s}" % {row_str, last_color}
                    last_control_code = "}"
                elseif last_neutral and not neutral then
                    row_str = "%s{" % row_str
                    last_control_code = "{"
                elseif not last_neutral then
                    row_str = "%s|%s}{" % {row_str, last_color}
                    last_control_code = "{"
                end
            end

            -- Add the character to the row string.
            row_str = "%s%s" % {row_str, char}

            if char ~= " " then
                -- Spaces are ultimately ignored - we only change the color
                -- if it was a non-space character
                last_color = color
            end

            last_char = char
        end

        -- The row ends with a colorized string, lop off any remaining space
        if last_control_code ~= "}" and last_control_code ~= "" then
            row_str = row_str:gsub("%s*$", "")
            row_str = "%s|%s}" % {row_str, last_color}
        end

        map_str_tbl[row] = row_str
    end

    -- Trim each row
    local last_nonblank_row = 1
    for r, str in ipairs(map_str_tbl) do
        -- Chop off any trailing space
        map_str_tbl[r] = str:gsub("(%s+)$", "")

        -- This row isn't blank right?
        if map_str_tbl[r] ~= "" then
            last_nonblank_row = r
        end
    end

    -- Cut off all of our trailing blank rows
    for i = last_nonblank_row + 1, #map_str_tbl do
        map_str_tbl[i] = nil
    end

    -- Slap it all together and send it to the clipboard
    return table.concat(map_str_tbl, "\n")
end



function decompile_text_map(s)
    local s_tbl = s:split("\n")
    local l_tbl = {}

    for ln, line_str in ipairs(s_tbl) do
        l_tbl[ln] = {}

        local row_str = ""
        local col_str = ""
        local reading_color = false
        local col_tbl = {col = "007", str = ""}

        _ = line_str:gsub("(.)", function (c)
            if not legal_character(c) then
                -- newline or similar detected; skip
            else
                -- We hit a control character, dump what we have into the table
                if c == "{" or c == "}" then
                    if row_str ~= "" then
                        col_tbl.str = row_str
                        if col_str ~= "" then col_tbl.col = col_str end    
                        col_tbl.col = col_tbl.col:zeropad(3)    
                        l_tbl[ln][#l_tbl[ln] + 1] = table.deepcopy(col_tbl)
                    end

                    row_str = ""
                    col_str = ""
                    reading_color = false
                elseif c == "|" then
                    col_str = ""
                    reading_color = true
                else
                    -- This isn't a special character - what are we doing with it?
                    if reading_color then
                        col_str = "%s%s" % {col_str, c}
                    else
                        row_str = "%s%s" % {row_str, c}
                    end
                end
            end
        end)

        -- Do we still have a remaining string? Dump it into the table, too
        if row_str ~= "" then
            col_tbl.str = row_str
            if col_str ~= "" then col_tbl.col = col_str end
            col_tbl.col = col_tbl.col:zeropad(3)         
            l_tbl[ln][#l_tbl[ln] + 1] = table.deepcopy(col_tbl)
        end
    end

    clear_text_map()

    for ln, _ in ipairs(l_tbl) do
        local column = 1

        for _, c_data in ipairs(l_tbl[ln]) do
            local col = c_data.col
            local str = c_data.str

            _ = str:gsub("(.)", function (c)
                -- cecho("<%s>%s" % {color, c})
                text_map.map[ln][column] = {
                    char = c,
                    color = col
                }

                column = column + 1
            end)
        end
    end
end



function map_dump()
    local dump_str = ""

    for row = 1, text_map.num_rows do
        for col = 1, text_map.num_cols do
            local char = text_map.map[row][col].char
            local color = text_map.map[row][col].color

            if char == " " or color == "000" then
                char = " "
                color = "000"
            end

            if char ~= " " and color ~= "000" then
                dump_str = "%s\ntext_map.map[%s][%s].char = \"%s\"\ntext_map.map[%s][%s].color = \"%s\"" % {
                    dump_str, row, col, char,
                    row, col, color
                }
            end
        end
    end

    love.system.setClipboardText(dump_str)
end



function transfer_text_map_to_clipboard()
    local map = compile_text_map()
    toolbar.desc = "Saved to clipboard!"
    love.system.setClipboardText(map)
end



function get_text_map_from_clipboard()
    local clip = love.system.getClipboardText()
    decompile_text_map(clip)
end



function save_file()
    local map = compile_text_map()

    -- local f = love.window.showFileDialog("savefile", function () end, {
        -- title = "butt!"
    -- })
end



function load_file()
end



function open_files()
end