require "cell"
require "room"

Maze = {}
Maze.__index = Maze

local generate_rooms, fill
local ROOM_SIZE = 100
local SQRT_OF_NUM_CELLS = 30

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
    fill(self.cells, self.cells_nx, self.cells_nx, self.cell_size)

    self.rooms = generate_rooms(math.min(width/2 - ROOM_SIZE/2, height/2 - ROOM_SIZE/2), width/2, height/2, self.cell_size, self.cells)

    return self
end

function Maze:update(dt)
    love.graphics.setCanvas(self.canvas)
        for _, v in pairs(self.rooms) do
            if v.type == Room.type.start then
                love.graphics.setColor({21, 128, 21})
            elseif v.type == Room.type.finish then
                love.graphics.setColor({128, 21, 21})
            end
            love.graphics.rectangle("line", v.x, v.y, v.width, v.height)
        end
        
        local lw = 3
        love.graphics.setLineWidth(lw)
        local ts = self.width / SQRT_OF_NUM_CELLS

        for _, w in pairs(self.cells) do
            for _, v in pairs(w) do
                love.graphics.setColor({255, 180, 180, 65})
                -- love.graphics.rectangle("line", (v.x-1) * ts, (v.y-1) * ts, ts, ts)
                -- top left to top right
                love.graphics.line((v.x-1) * ts, (v.y-1) * ts, v.x * ts, (v.y-1) * ts)
                -- top right to bottom right
                love.graphics.line(v.x * ts, (v.y-1) * ts, v.x * ts, v.y * ts)
                -- bottom right to bottom left
                love.graphics.line(v.x * ts, v.y * ts, (v.x-1) * ts, v.y * ts)
                -- bottom left to top left
                love.graphics.line((v.x-1) * ts, v.y * ts, (v.x-1) * ts, (v.y-1) * ts)
                -- fill
                love.graphics.setColor(self.cells[v.x][v.y].state.color)
                love.graphics.rectangle("fill", (v.x-1) * ts + lw, (v.y-1) * ts + lw, ts - (lw*2), ts - (lw*2))
            end
        end
    love.graphics.setCanvas()
end 

-- @param radius of circle
-- @param how close the point is to the edge.
--        corresponds to possible distance from edge.
--        by default 0, meaning right on edge.
-- @param center x
-- @param center y
local random_point_by_circle_edge = function(radius, cx, cy, threshold)
    math.randomseed(os.time())
    local threshold = threshold or 0
    local cx = cx - ROOM_SIZE / 2
    local cy = cy - ROOM_SIZE / 2

    local t = 2 * math.pi * math.random()
    local r = math.random((radius - threshold)/radius, (threshold/radius) + 1) * radius
    return math.cos(t) * r + cx, math.sin(t) * r + cy
end

local function distance(r1, r2)
    local dx = r2.x - r1.x
    local dy = r2.y - r1.y
    return math.sqrt(dx^2 + dy^2)
end

generate_rooms = function(radius, cx, cy, cell_size, cells)
    math.randomseed(os.time())

    local cell_state_to_room = function(_sc, _ec)
        for i=_sc.x+1, _ec.x do
            for j=_sc.y+1, _ec.y do
                cells[i][j].state = Cell.state.room
            end
        end
    end

    local room = {
        one = {},
        two = {}
    }
    local sc, ec = {}, {}

    room.one.x, room.one.y = random_point_by_circle_edge(radius, cx, cy)
    room.one.x = room.one.x - (room.one.x % cell_size)
    room.one.y = room.one.y - (room.one.y % cell_size)

    -- starting cell to ending cell
    sc.x, sc.y = room.one.x/cell_size, room.one.y/cell_size
    ec.x, ec.y = sc.x + ROOM_SIZE/cell_size, sc.y + ROOM_SIZE/cell_size

    cell_state_to_room(sc, ec)

    room.two.x = cx - (room.one.x - cx) - ROOM_SIZE
    room.two.y = cy - (room.one.y - cy) - ROOM_SIZE

    sc.x, sc.y = room.two.x/cell_size, room.two.y/cell_size
    ec.x, ec.y = sc.x + ROOM_SIZE/cell_size, sc.y + ROOM_SIZE/cell_size

    cell_state_to_room(sc, ec)

    room.one = Room.new(room.one.x, room.one.y, ROOM_SIZE, ROOM_SIZE, Room.type.start)
    room.two = Room.new(room.two.x, room.two.y, ROOM_SIZE, ROOM_SIZE, Room.type.finish)

    return {
        room.one, room.two
    }
end

fill = function(cells, nx, ny, cell_size)
    for i=1, nx do
        cells[i] = {}
        for j=1, ny do
            cells[i][j] = Cell.new(i,j, cell_size)
        end
    end
end