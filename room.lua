Room = {}
Room.__index = Room
Room.new = function(x, y, width, height, type)
    local self = setmetatable({}, Room)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.type = type
    
    return self
end

Room.type = {
    start = {},
    finish = {}
}