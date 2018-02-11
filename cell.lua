Cell = {}
Cell.__index = Cell
Cell.new = function(x, y, cell_size)
    local self = setmetatable({}, Cell)
    self.x = x
    self.y = y
    self.cell_size = cell_size
    self.state = Cell.state.unvisited

    return self
end

Cell.state = {
    unvisited = {color = {255, 176, 103}},
    visited = {color = {84, 255, 159}},
    room = {color = {255, 255, 255}}
}