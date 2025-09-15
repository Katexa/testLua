local Board = require("classes.Board")

local moves = {["l"]=true, ["r"]=true, ["u"]=true, ["d"]=true}

local Game = {}
Game.__index = Game

function Game:new(rows, cols)
  local obj = {}
  obj.board = Board:new(rows, cols)
  obj.state = "player"
  setmetatable(obj, self)
  return obj
end

function Game:start()
  self.board:Initialize()
  self:Update()
end

function Game:Update()
  while self.state ~= "quit" do
    print("Напишите команду:")
    local input = io.read()
    local parts = self:Split(input, " ")
    if #parts == 4 and parts[1] == "m" and self:IsDigit(parts[2]) and self:IsDigit(parts[3]) and moves[parts[4]]  then
      parts[2] = tonumber(parts[2])
      parts[3] = tonumber(parts[3])
      if parts[4] == "l" and parts[3] == 0 or 
          parts[4] == "r" and parts[3] == self.board.cols-1 or
          parts[4] == "u" and parts[2] == 0 or
          parts[4] == "d" and parts[2] == self.board.rows-1 then
        print("Ошибка: команда должна быть вида m 0-9 0-9 {l,r,u,d} или q")
      else
        self.board:Swap(parts[2]+1, parts[3]+1, parts[4])
        local matches = self.board:CheckMatches()
        --self:Sleep(1)
        
        if matches then
          print ("Убираем совпадения...")
          self.board:RemoveMatches(matches)
          --self:Sleep(1)
          
          print ("Наполняем поле...")
          self.board:RefillBoard()
          --self:Sleep(1)
        else
          print ("Нет совпадений")
          self.board:Swap(parts[2]+1, parts[3]+1, parts[4])
          --self:Sleep(1)
        end
        
        --проверяем, появились ли еще совпадения после нового наполнения
        matches = self.board:CheckMatches()
        while matches do
          print ("Убираем совпадения...")
          self.board:RemoveMatches(matches)
          --self:Sleep(1)
          
          print ("Наполняем поле...")
          self.board:RefillBoard()
          matches = self.board:CheckMatches()
          --self:Sleep(1)
        end
        
        while not self.board:HasPossibleMoves() do
          print ("Нет возможных ходов. Перемешиваем...")
          self.board:Mix()
          matches = self.board:CheckMatches()
          
          while matches do
            print ("Убираем совпадения...")
            self.board:RemoveMatches(matches)
            --self:Sleep(1)
            
            print ("Наполняем поле...")
            self.board:RefillBoard()
            matches = self.board:CheckMatches()
            --self:Sleep(1)
          end
          --self:Sleep(1)
        end
      end
    else
      if #parts == 1 and parts[1] == "q" then
        self.state = "quit"
      else
        print("Ошибка: команда должна быть вида m 0-9 0-9 {l,r,u,d} или q")
      end
    end
  end
end

--проверка является ли введенный символ цифрой или нет
function Game:IsDigit(char)
    if not char or #char ~= 1 then return false end
    local digits = {["0"]=true, ["1"]=true, ["2"]=true, ["3"]=true, ["4"]=true, 
                    ["5"]=true, ["6"]=true, ["7"]=true, ["8"]=true, ["9"]=true}
    return digits[char]
end

--разделение ввода на элементы по пробелу
function Game:Split(str, delimiter)
    local result = {}
    for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end
    return result
end

--функция сна, странно работала на выводе, поэтому я закомментила ее в update
function Game:Sleep(seconds)
   local start = os.time()
    while os.time() - start < seconds do
        -- Просто ждем
    end
end

return Game