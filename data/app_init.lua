function app_init()
    app = {}
    app.size = {}
    app.palette_active = false
    app.active_color = "007"
    app.last_char = " "

    app.version = {
        major = 0,
        minor = 4,
    }

    app.instructions_cleared = false

    app.font = love.graphics.newFont("fonts/VeraMono.ttf", 15)
    app.font_large = love.graphics.newFont("fonts/VeraMono-Bold.ttf", 19)

    app.size.width = 1920
    app.size.height = 1080

    -- Load graphics
    app.icon = {}

    app.icon.cell_pos = love.graphics.newImage("img/label_cell_pos.png")
    app.icon.color = love.graphics.newImage("img/label_color.png")
    app.icon.framerate = love.graphics.newImage("img/label_framerate.png")

    print(love.filesystem.getSaveDirectory())
end