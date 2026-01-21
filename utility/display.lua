function set_rgb(r, g, b, a)
    a = a or 255
    love.graphics.setColor(love.math.colorFromBytes(r, g, b, a))
end



function set_color(col)
    love.graphics.setColor(love.math.colorFromBytes(color_table[col]))
end



function cecho(str, col, x, y, large, wrap)
    if large ~= nil then large = true end

    wrap = wrap or app.size.width

    set_color(col)

    if large then
        love.graphics.printf(str, app.font_large, x, y, wrap)
    else
        love.graphics.printf(str, app.font, x, y, wrap)
    end
end



function echo(str, x, y, large, wrap)
    wrap = wrap or app.size.width
    cecho(str, "007", x, y, size, wrap)
end