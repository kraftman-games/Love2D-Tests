

local ui = require "GUI"
COLORS = {}
COLORS.edgec = {200,200,200,255}

local irc = require "irc"

irc:SetAllPoints(ui)



function love.keypressed(key, uni)
	ui:keypressed(key,uni)
end

function love.mousepressed(x,y,button)
	ui:mousepressed(x,y,button)
end

function love.mouserleased(x,y,button)
	ui:mousereleased(x,y,button)
end

function love.update(dt)
	ui:update(dt)
end

function love.draw()
	ui:draw()
end