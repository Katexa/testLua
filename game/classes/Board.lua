local Gem = require("classes.Gem")

local Board = {}
Board.__index = Board

function Board:new(rows, cols)
  local obj = {}
  obj.rows = rows or 10
  obj.cols = cols or 10
  obj.grid = {}
  setmetatable(obj, self)
  return obj
end

--создаем игровое поле
function Board:Initialize()
  for row = 1, self.rows do
    self.grid[row] = {}
    for col = 1, self.cols do
      self.grid[row][col] = Gem:new("normal", math.random(1, 6), row, col)
      
      --проверяем, чтобы созданные гемы не создавали соединений с предыдущими
      local t = 0
      while self:CheckMatchesAtPosition(self.grid[row][col]) and t < 10 do
        self.grid[row][col].color = math.random(1, 6)
        t = t + 1
      end
    end
  end
  self:Draw() 
end

function Board:GetGem(row, col)
  return self.grid[row][col]
end

--выводим игровое поле в консоль
function Board:Draw()
  local startRow = "    "
  local secondRow = "   "
  for i = 1, self.cols do 
    startRow = startRow .. i-1 .. " "
    secondRow = secondRow .. "--"
  end
  print (startRow) -- номера столбцов
  print (secondRow) -- отделение номеров от поля
  for row = 1, self.rows do
    local srow = row-1 .. " | " -- номера строк
    for col = 1, self.cols do
      local gem = self:GetGem(row, col)
      srow = srow .. gem:Draw() .. " "
    end
    print(srow) 
  end
  print("_______________________") -- отделение полей друг от друга
end

--отпределяем куда нужно сдвинуть гем и вызываем функцию move
function Board:Swap(row, col, direct)
  local gem1 = self:GetGem(row, col)
  local gem2 = self:GetGem(row, col)
  if direct == "l" then
    gem2 = self:GetGem(row, col-1)
  end
  if direct == "r" then
    gem2 = self:GetGem(row, col+1)
  end
  if direct == "u" then
    gem2 = self:GetGem(row-1, col)
  end
  if direct == "d" then
    gem2 = self:GetGem(row+1, col)
  end
  self:Move(gem1, gem2)
  self:Draw()
end

--меняем гемы местами
function Board:Move(gem1, gem2)
  local tempRow, tempCol = gem1.row, gem1.col
  gem1.row, gem1.col = gem2.row, gem2.col
  gem2.row, gem2.col = tempRow, tempCol
    
  self.grid[gem1.row][gem1.col], self.grid[gem2.row][gem2.col] = gem1, gem2
end

--проверяем есть ли совпадения на всем поле
function Board:CheckMatches()
  local matches = {}
    
  -- Проверка горизонтальных совпадений
  for row = 1, self.rows do
    local currentColor = nil
    local matchStart = 1
    local matchLength = 1
        
    for col = 1, self.cols do
      local gem = self.grid[row][col]
      if currentColor == gem.color then
        matchLength = matchLength + 1
      else
        if matchLength >= 3 then
          table.insert(matches, {
              row = row,
              startCol = matchStart,
              endCol = col - 1,
              horizontal = true
          })
        end
        currentColor = gem.color
        matchStart = col
        matchLength = 1
      end
    end
        
    if matchLength >= 3 then
      table.insert(matches, {
          row = row,
          startCol = matchStart,
          endCol = self.cols,
          horizontal = true
      })
    end
  end
  -- Проверка вертикальных совпадений
  for col = 1, self.cols do
    local currentColor = nil
    local matchStart = 1
    local matchLength = 1
        
    for row = 1, self.rows do
      local gem = self.grid[row][col]
      if currentColor == gem.color then
        matchLength = matchLength + 1
      else
        if matchLength >= 3 then
          table.insert(matches, {
              col = col,
              startRow = matchStart,
              endRow = row - 1,
              horizontal = false
          })
        end
        currentColor = gem.color
        matchStart = row
        matchLength = 1
      end
    end
        
    if matchLength >= 3 then
      table.insert(matches, {
        col = col,
        startRow = matchStart,
        endRow = self.rows,
        horizontal = false
      })
    end
  end
  return #matches > 0 and matches or false
end

--помечаем все уничтоженные гемы как пустые
function Board:RemoveMatches(matches)
  for _, match in ipairs(matches) do
    if match.horizontal then
      for col = match.startCol, match.endCol do
        self.grid[match.row][col]:MarkMatched()
      end
    else
      for row = match.startRow, match.endRow do
        self.grid[row][match.col]:MarkMatched()
      end
    end
  end
  self:Draw()
end

-- тут перемещаем все гемы вниз и "пустые" гемы наполняем новыми значениями
function Board:RefillBoard()
  for col = 1, self.cols do
    local emptySpaces = 0
    -- Считаем пустые места и сдвигаем гемы вниз
    for row = self.rows, 1, -1 do
      local gem = self:GetGem(row, col)
      if gem.matched then
        emptySpaces = emptySpaces + 1
      elseif emptySpaces > 0 then
        --print(col, row, emptySpaces, gem.row)
        gem.row = gem.row + emptySpaces
        local tempGem = self:GetGem(gem.row, col)
        self.grid[gem.row][col], self.grid[row][col] = gem, tempGem
      end
    end
  end
  self:Draw()
  -- Заполняем пустые гемы новыми значениями
  for col = 1, self.cols do
    for row = 1, self.rows do
      local gem = self:GetGem(row, col)
      if gem.matched then
        gem.matched = false
        gem.row = row
        gem.col = col
        gem.color = math.random(1, 6)
        local t = 0
        while self:CheckMatchesAtPosition(gem) and t < 5 do
          gem.color = math.random(1, 6)
          t = t + 1
        end
        --print (row, col, gem.matched)
      end
    end
  end
  self:Draw()
end

--проверим, создает ли три в ряд элемент в линию или в столбик
function Board:CheckMatchesAtPosition(gem)
  local line = self:IsLine(gem)
  local column = self:IsColumn(gem)
  return line or column
end

--проверяем есть ли совпадения с гемом по линии или нет
function Board:IsLine(gem)
  if not gem then 
    return false 
  end
  local color = gem.color
  local count = 1
    
  -- Проверяем влево
  for col = gem.col - 1, 1, -1 do
    if self:GetGem(gem.row, col) and self:GetGem(gem.row, col).color == color then
      count = count + 1
    else
      break
    end
  end
    
  -- Проверяем вправо
  for col = gem.col + 1, #self.grid[gem.row] do
    if self:GetGem(gem.row, col) and self:GetGem(gem.row, col).color == color then
      count = count + 1
    else
      break
    end
  end
    
  return count >= 3
end

--проверяем есть ли совпадения с гемом по столбцу или нет
function Board:IsColumn(gem)
  if not gem then 
    return false 
  end
    
  local color = gem.color
  local count = 1
    
  -- Проверяем вверх
  for row = gem.row - 1, 1, -1 do
    if self:GetGem(row, gem.col) and self:GetGem(row, gem.col).color == color then
      count = count + 1
    else
      break
    end
  end
    
  -- Проверяем вниз
  for row = gem.row + 1, #self.grid do
    if self:GetGem(row, gem.col) and self:GetGem(row, gem.col).color == color then
      count = count + 1
    else
      break
    end
  end
  
  return count >= 3
end

-- Проверяем все возможные обмены гемов
function Board:HasPossibleMoves()
  for row = 1, self.rows do
    for col = 1, self.cols do
      -- Проверяем обмен с правым соседом
      if col ~= self.cols then
        --print(row, col)
        if self:CheckSwap(row, col, row, col + 1) then
          return true
        end
      end
            
      -- Проверяем обмен с нижним соседом
      if row ~= self.rows then
        --print(row, col)
        if self:CheckSwap(row, col, row + 1, col) then
          return true
        end
      end
    end
  end
    
  return false
end

--проверяем, если поменять гему местами, будут ли совпадения
function Board:CheckSwap(row1, col1, row2, col2)
  local gem1 = self:GetGem(row1, col1)
  local gem2 = self:GetGem(row2, col2)
    
  if not gem1 or not gem2 then
    return false
  end
    
  -- Временно меняем гемы
  self.grid[row1][col1], self.grid[row2][col2] = gem2, gem1
  gem1.row, gem1.col, gem2.row, gem2.col = row2, col2, row1, col1
    
  -- Проверяем образуются ли совпадения
  local hasMatch = self:CheckMatchesAtPosition(gem1) or self:CheckMatchesAtPosition(gem2)

  -- Возвращаем гемы на место
  self.grid[row1][col1], self.grid[row2][col2] = gem1, gem2
  gem1.row, gem1.col, gem2.row, gem2.col = row1, col1, row2, col2
    
  return hasMatch
end

function Board:Mix()
  -- Собираем все гемы в список
  local allGems = {}
  for row = 1, self.rows do
    for col = 1, self.cols do
      local gem = self:GetGem(row, col)
      if gem then
        table.insert(allGems, gem)
      end
    end
  end
    
  --Перемешиваем гемы
  for i = #allGems, 2, -1 do
    local j = math.random(1, i)
    allGems[i], allGems[j] = allGems[j], allGems[i]
  end
    
  -- Распределяем обратно на поле
  local index = 1
  for row = 1, self.rows do
    for col = 1, self.cols do
      if index <= #allGems then
        local gem = allGems[index]
        gem.row, gem.col = row, col
        self.grid[row][col] = gem
        index = index + 1
      end
    end
  end
  self:Draw()
end

return Board