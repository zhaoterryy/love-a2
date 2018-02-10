require "cell"
require "room"

Maze = {}
Maze.__index = Maze

local generate_rooms
local ROOM_SIZE = 85

Maze.new = function(width, height)
    local self = setmetatable({}, Maze)

    self.width = width
    self.height = height
    self.canvas = love.graphics.newCanvas(width, height)
    self.get_canvas = function() return self.canvas end
    self.rooms = generate_rooms(math.min(width/2 - ROOM_SIZE/2, height/2 - ROOM_SIZE/2), width/2, height/2)

    return self
end

function Maze:update(dt)
    love.graphics.setCanvas(self.canvas)
    for _, v in pairs(self.rooms) do
        love.graphics.setColor({255, 255, 255})
        love.graphics.rectangle("fill", v.x, v.y, v.width, v.height)
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

generate_rooms = function(radius, cx, cy)
    math.randomseed(os.time())

    local r1_x, r1_y = random_point_by_circle_edge(radius, cx, cy)
    local rooms = {}
    table.insert(rooms, Room.new(r1_x, r1_y, ROOM_SIZE, ROOM_SIZE))

    local r2_x = cx - (r1_x - cx) - ROOM_SIZE
    local r2_y = cy - (r1_y - cy) - ROOM_SIZE
    table.insert(rooms, Room.new(r2_x, r2_y, ROOM_SIZE, ROOM_SIZE))


    return rooms
end