local MazeUtil = {}
local _gen_path_direct, _gen_path_smart

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

    -- print(cell_size)
    -- print(sc.x, sc.y)
    -- print(ec.x, ec.y)
    cell_state_to_room(sc, ec)

    room.two.x = cx - (room.one.x - cx) - ROOM_SIZE
    room.two.y = cy - (room.one.y - cy) - ROOM_SIZE

    sc.x, sc.y = room.two.x/cell_size, room.two.y/cell_size
    ec.x, ec.y = sc.x + ROOM_SIZE/cell_size, sc.y + ROOM_SIZE/cell_size

    cell_state_to_room(sc, ec)

    room.one = Room.new(room.one.x, room.one.y, ROOM_SIZE, ROOM_SIZE, Room.type.start, cell_size)
    room.two = Room.new(room.two.x, room.two.y, ROOM_SIZE, ROOM_SIZE, Room.type.finish, cell_size)

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

MazeUtil.gen_path_easy = function(cells, rooms)
    math.randomseed(os.time())

    local start_room, end_room
    local starting_cell, ending_cell
    local dx, dy
    local direction
    for _, v in pairs(rooms) do 
        if v.type == Room.type.start then
            start_room = v
        elseif v.type == Room.type.finish then
            end_room = v
        end
    end

    dx, dy = end_room.cx - start_room.cx, end_room.cy - start_room.cy

    if math.abs(dx) > math.abs(dy) then
        local sy = start_room.cy + math.random(start_room.cheight)
        local ex = end_room.cx + math.random(end_room.cwidth)
        if dx > 0 then
            direction = "right"
            starting_cell = cells[start_room.cx + start_room.cwidth + 1][sy]
            ending_cell = cells[end_room.cx][sy]
        else
            direction = "left"
            starting_cell = cells[start_room.cx][sy]
            ending_cell = cells[end_room.cx + end_room.cwidth + 1][sy]
        end
        if dy > 0 then
            ending_cell = cells[ex][end_room.cy]
        elseif dy < 0 then
            ending_cell = cells[ex][end_room.cy + end_room.cheight + 1]
        end
    else
        local sx = start_room.cx + math.random(start_room.cwidth)
        local ey = end_room.cy + math.random(end_room.cheight)
        if dy > 0 then
            direction = "down"
            starting_cell = cells[sx][start_room.cy + start_room.cheight + 1]
            ending_cell = cells[sx][end_room.cy]
        else
            direction = "up"
            starting_cell = cells[sx][start_room.cy]
            ending_cell = cells[sx][end_room.cy + start_room.cheight + 1]
        end
        if dx > 0 then
            ending_cell = cells[end_room.cx][ey]
        elseif dx < 0 then
            ending_cell = cells[end_room.cx + end_room.cwidth + 1][ey]
        end
    end

    _gen_path_smart(cells, ending_cell, starting_cell, direction)
end

_gen_path_direct = function(cells, ec, cc)
    cc.state = Cell.state.visited
    if cc == ec then
        return
    end

    local dx, dy, nc
    dx = ec.x - cc.x
    dy = ec.y - cc.y

    if math.abs(dx) > math.abs(dy) then
        if dx > 0 then
            -- right
            nc = cells[cc.x + 1][cc.y]
        else
            -- left
            nc = cells[cc.x - 1][cc.y]
        end
    else
        if dy > 0 then
            -- down
            nc = cells[cc.x][cc.y + 1]
        else
            -- up
            nc = cells[cc.x][cc.y - 1]
        end
    end

    _gen_path_direct(cells, ec, nc)
end

_gen_path_smart = function(cells, ec, cc, dir)
    cc.state = Cell.state.visited
    if cc == ec then
        return
    end

    local dx, dy, nc
    dx = ec.x - cc.x
    dy = ec.y - cc.y

    if dir == nil then
        if math.abs(dx) > math.abs(dy) then
            if dx > 0 then
                dir = "right"
            else
                dir = "left"
            end
        else
            if dy > 0 then
                dir = "down"
            else
                dir = "up"
            end
        end
    end

    if dir == "right" then
        nc = cells[cc.x + 1][cc.y]
    elseif dir == "left" then
        nc = cells[cc.x - 1][cc.y]
    elseif dir == "down" then
        nc = cells[cc.x][cc.y + 1]
    elseif dir == "up" then
        nc = cells[cc.x][cc.y - 1]
    end

    if dir == "right" or dir == "left" then
        if cc.x == ec.x then
            if cc.y > ec.y then
                nc = cells[cc.x][cc.y - 1]
                dir = "up"
            elseif cc.y < ec.y then
                nc = cells[cc.x][cc.y + 1]
                dir = "down"
            end
        end
    elseif dir == "up" or dir == "down" then
        if cc.y == ec.y then
            if cc.x > ec.x then
                nc = cells[cc.x - 1][cc.y]
                dir = "left"
            elseif cc.x < ec.x then
                nc = cells[cc.x + 1][cc.y]
                dir = "right"
            end
        end
    end

    _gen_path_smart(cells, ec, nc, dir)
end

return MazeUtil