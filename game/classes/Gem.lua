--трансформатор индекса в букву цвета
local names = {"A", "B", "C", "D", "E", "F", "-"} 

local Gem = {}
Gem.__index = Gem

function Gem:new(stype, color, row, col)
  local obj = {}
  obj.type = stype or "normal" --можно пометить специальный гем, ну а вообще для них лучше класс наследник сделать
  obj.color = color or 1 
  obj.row = row or 0
  obj.col = col or 0
  obj.matched = false
  setmetatable(obj, self)
  return obj
end

--возвращает нужный цвет по индексу
function Gem:Draw()
  return names[self.color]
end

--помечает гем как "взорванный"
function Gem:MarkMatched()
  self.matched = true
  self.color = 7
end

return Gem