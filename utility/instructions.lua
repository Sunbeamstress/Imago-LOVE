local tag_lines = {
    "unforgotten.",
    "you're never truly gone.",
    "through artistry do we worship.",
    "the ghost in orange gears",
    "violet skies and violent sighs",
    "behold! the nightmare",
    "a secret king of my tower am i",
    "a queen of vast lands, made real by belief",
    "my dancer in the midnight dark.",
    "the eyes of the nightmare",
    "offer the beast queen diamonds.",
    "she sings through the colors",
    "she screams in the walls",
}

local controls = {
    {"Arrow Keys", "Move the cursor."},
    {"F1", "Cycle to the previous tool."},
    {"F2", "Cycle to the next tool."},
    {"Tab", "Open or close the palette."},
    {"Escape", "Close the palette."},
    {"", ""},
    {"CTRL+Q, F8", "Quit the application."},
    {"CTRL+R", "Restart the application."},
    {"CTRL+C", "Clear the canvas."},
    {"F4", "See these instructions again!"},
}

local tools = {
    {
        name = "Text Pen", desc = "Set a character to the canvas.",
        controls = {
            {"Alphanumeric keys", "Write the character to the selected cell."},
            {"Enter", "Apply the last character entered (does not change color)."},
        }
    },
    {
        name = "Pen", desc = "Color your canvas.",
        controls = {
            {"Left Mouse Button", "Alter the color of the highlighted cell."},
            {"Space", "Alter the color of the highlighted cell."},
        }
    },
    {
        name = "Type", desc = "Text-editor typing controls (not implemented).",
    },
    {
        name = "Eyedropper", desc = "Sample colors from other cells.",
        controls = {
            {"Left Mouse Button", "Use the current cell's color as your active color."},
            {"Space Bar", "Use the current cell's color as your active color."},
            {"Enter", "Use the current cell's color as your active color."},
        }
    },
    {
        name = "Clear", desc = "Erases the canvas.",
        controls = {
            {"CTRL+C", "Clear by hotkey."},
        },
    },
    {
        name = "Export", desc = "Save your creation to the clipboard for use in Aetolia.",
        controls = {
            {"CTRL+E", "Export by hotkey."},
        },
    },
    {
        name = "Import", desc = "Import a piece of color writing from Aetolia (not implemented).",
    },
    {
        name = "Mudlet HTML Import", desc = "Import a segment of HTML text from Mudlet (not implemented).",
    },
}

function draw_instructions()
    if not app.chosen_tagline then
        app.tagline = tag_lines[math.random(#tag_lines)]
        app.chosen_tagline = true
    end

    -- Darken the app itself
    set_rgb(0, 0, 0, 192)
    love.graphics.rectangle("fill", 0, 0, app.size.width, app.size.height)

    local left = 24
    local ind = left * 1.5
    cecho("The Imago v%s.%s." % {app.version.major, app.version.minor}, "033", left, 48, true)
    cecho(app.tagline, "236", left, 70)

    cecho("Controls:", "242", left, 104, true)

    local last_i = 0
    for i, _ in ipairs(controls) do
        local label = controls[i][1]
        local desc = controls[i][2]

        last_i = 130 + ((i - 1) * 24)
        if label ~= "" then
            cecho({{0.3, 0.32, 0.59}, "%s: " % label, {0.75, 0.75, 0.75}, desc}, "255", ind, last_i)
        end
    end

    -- How far do we need to push down tools?
    local top_margin = last_i + 64
    last_i = top_margin + 26

    cecho("Tools:", "242", left, top_margin, true)
    for i, _ in ipairs(tools) do
        local label = tools[i].name
        local desc = tools[i].desc

        last_i = last_i + 32

        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(toolbar.tools[i].image, left, last_i)
        cecho({{0.59, 0.4, 0.59}, "%s: " % label, {0.75, 0.75, 0.75}, desc}, "255", ind + 24, last_i + 3)

        if tools[i].controls then
            for x, _ in ipairs(tools[i].controls) do
                local label = tools[i].controls[x][1]
                local desc = tools[i].controls[x][2]

                last_i = last_i + 20
                cecho({{0.3, 0.32, 0.59}, "%s: " % label, {0.75, 0.75, 0.75}, desc}, "255", ind + 34, last_i + 4)
            end
        end
    end
end