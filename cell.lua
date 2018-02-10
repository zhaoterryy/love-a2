Cell = {}
Cell.__index = Cell
Cell.new = function(x, y)
    local self = setmetatable({}, Cell)
    self.x = x
    self.y = y

    return self
end