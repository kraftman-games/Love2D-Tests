local random = math.random
local tinsert = table.insert
local lg = love.graphics

local world = require "world"

local player = require "player"(world)

io.stdout:setvbuf("no")
require "creature"
local c = require "groundcreature"
local creature = CreateNewScaredJumper(world,40,40)
local fiend = CreateNewAggresiveJumper(world,40,40)
 --require "groundcreature"
--require "flyingcreature"


function love.keypressed(key)
	player:KeyPressed(key)
end

function love.keyreleased(key)
	player:KeyReleased(key)
end


function love.mousepressed(x,y,button)
	world:MousePressed(x,y,button)
end

function love.update(dt)
	world:Update(dt)
	player:Update(dt)
	creature:Update(dt)
	fiend:Update(dt)
end

function love.draw()
	world:Draw()
	player:Draw()
	creature:Draw()
	fiend:Draw()
end

