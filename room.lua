Room = {}
Room.__index = Room
Room.new = function(x, y, width, height, type, cell_size)
    local self = setmetatable({}, Room)
    self.x = x
    self.y = y
    self.cx = x / cell_size
    self.cy = y / cell_size
    self.width = width
    self.height = height
    self.cwidth = width / cell_size
    self.cheight = height / cell_size
    self.type = type
    
    return self
end

Room.type = {
    start = {color = {0, 178, 128}},
    finish = {color = {193, 39, 45}}
}