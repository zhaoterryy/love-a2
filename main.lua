require "maze"

local ctx = {
    maze
}

function love.load()
    local width = 750
    local height = 750
    love.graphics.setBackgroundColor({21, 21, 21})
    love.window.setMode(width, height, {resizable=false})
    love.window.setTitle("GAME3011_A2_ZhaoTerry")
    ctx.maze = Maze.new(width, height)
end

function love.update(dt)
    ctx.maze:update(dt)
end

function love.draw()
    love.graphics.draw(ctx.maze:get_canvas())
end

function love.mousepressed(x, y, button, istouch)

end

function love.mousereleased(x, y, button, istouch)

end

function love.mousemoved(x, y, dx, dy, istouch)
    
end

function love.keypressed(key)

end

function love.quit()

end