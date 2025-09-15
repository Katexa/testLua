package.path = package.path .. 
    ";./?.lua" ..
    ";./classes/?.lua" ..
    ";E:/Lua/myprograms/game/?.lua" ..
    ";E:/Lua/myprograms/game/classes/?.lua"
-- У меня почему то среда ищет эту папку по странным путям и не находит, поэтому я вручную прописала путь. 
-- Если у вас также не работает, то можете указать путь до папки вручную, как я.  

local function loadModule(name)
    local success, result = pcall(require, name)
    return result
end

local Gem = loadModule("classes.Gem")
local Board = loadModule("classes.Board")
local Game = loadModule("classes.Game")

math.randomseed(os.time())

local function main()
  local game = Game:new(10, 10)
  game:start()
end

main()