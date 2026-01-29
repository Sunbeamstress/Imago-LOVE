require("utility/library_extensions")

require("data/app_init")
require("data/palette")

require("utility/text")
require("utility/display")
require("utility/controls")
require("utility/file_control")
require("utility/drawing_ui")
require("utility/instructions")

-- Debugging stuff.
last_text_input = " "



function love.load()
    app_init()
    init_text_map()
end



function love.keypressed(key, code, rep)
    imago_keypress(key, code, rep)
end



function love.keyreleased(key, code)
    imago_keyrelease(key, code)
end



function love.textinput(t)
    imago_text_input(t)
end



function love.mousemoved(x, y, dx, dy)
    imago_mouse_movement(x, y, dx, dy)
end



function love.mousepressed(x, y, btn)
end



function love.mousereleased(x, y, btn)
end



function love.update(dt)
    update_mouse(dt)
    update_text_map()
end



function love.draw()
    imago_draw_interface()
end



function love.resize(w, h)
    app.size.width, app.size.height = w, h
end