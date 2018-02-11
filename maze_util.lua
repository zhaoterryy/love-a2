local MazeUtil = {}

-- @param radius of circle
-- @param how close the point is to the edge.
--        corresponds to possible distance from edge.
--        by default 0, meaning right on edge.
-- @param center x
-- @param center y
MazeUtil.random_point_by_circle_edge = function(radius, cx, cy, threshold)
    math.randomseed(os.time())
    local threshold = threshold or 0
    local cx = cx - ROOM_SIZE / 2
    local cy = cy - ROOM_SIZE / 2

    local t = 2 * math.pi * math.random()
    local r = math.random((radius - threshold)/radius, (threshold/radius) + 1) * radius
    return math.cos(t) * r + cx, math.sin(t) * r + cy
end

MazeUtil.vector_distance = function(r1, r2)
    local dx = r2.x - r1.x
    local dy = r2.y - r1.y
    return math.sqrt(dx^2 + dy^2)
end

MazeUtil.generate_rooms = function(radius, cx, cy, cell_size, cells)
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

    room.one.x, room.one.y = MazeUtil.random_point_by_circle_edge(radius, cx, cy)
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

MazeUtil.fill = function(cells, nx, ny, cell_size)
    for i=1, nx do
        cells[i] = {}
        for j=1, ny do
            cells[i][j] = Cell.new(i, j, cell_size)
        end
    end
end

return MazeUtil