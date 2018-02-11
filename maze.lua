require "cell"
require "room"
local mutil = require "maze_util"
Maze = {}
Maze.__index = Maze

-- constant globals
ROOM_SIZE = 100
SQRT_OF_NUM_CELLS = 30

Maze.new = function(width, height)
    local self = setmetatable({}, Maze)

    self.width = width
    self.height = height
    self.canvas = love.graphics.newCanvas(width, height)
    self.get_canvas = function() return self.canvas end

    self.cells = {}
    self.cells_nx = SQRT_OF_NUM_CELLS
    self.cells_ny = NUM_CELLS_Y
    self.cell_size = width / self.cells_nx
    mutil.fill(self.cells, self.cells_nx, self.cells_nx, self.cell_size)

    self.rooms = mutil.generate_rooms(math.min(width/2 - ROOM_SIZE/2, height/2 - ROOM_SIZE/2), width/2, height/2, self.cell_size, self.cells)

    return self
end

function Maze:update(dt)
    love.graphics.setCanvas(self.canvas)
        local lw = 1
        love.graphics.setLineWidth(lw)
        local ts = self.width / SQRT_OF_NUM_CELLS

        for _, v in pairs(self.rooms) do
            love.graphics.setColor(v.type.color)
            love.graphics.rectangle("fill", v.x, v.y, v.width, v.height)
        end

        for _, w in pairs(self.cells) do
            for _, v in pairs(w) do
                love.graphics.setColor({0, 0, 0})
               -- top left -> top right
                love.graphics.line((v.x-1) * ts, (v.y-1) * ts, v.x * ts, (v.y-1) * ts)
                -- top right -> bottom right
                love.graphics.line(v.x * ts, (v.y-1) * ts, v.x * ts, v.y * ts)
                -- bottom right -> bottom left
                love.graphics.line(v.x * ts, v.y * ts, (v.x-1) * ts, v.y * ts)
                -- bottom left -> top left
                love.graphics.line((v.x-1) * ts, v.y * ts, (v.x-1) * ts, (v.y-1) * ts)
                -- fill
                love.graphics.setColor(self.cells[v.x][v.y].state.color)
                love.graphics.rectangle("fill", (v.x-1) * ts + lw, (v.y-1) * ts + lw, ts - (lw*2), ts - (lw*2))
            end
        end
    love.graphics.setCanvas()
end 