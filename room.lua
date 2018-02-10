Room = {}
Room.__index = Room
Room.new = function(x, y, width, height)
    local self = setmetatable({}, Room)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    
    return self
end