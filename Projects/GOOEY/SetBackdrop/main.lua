


local ui = require "GUI"

local f = CreateFrame("Frame")

f:SetPoint("TOPLEFT", ui, "TOPLEFT", 100, 100)

f:SetSize(100,400)
f.bg = f:CreateTexture(nil, 1)
f.bg:SetTexture(200,200,200,255)
f.bg:SetPoint("TOPLEFT", f, "TOPLEFT", 10,10)
f.bg:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -10,-10)

local test = love.graphics.newImage("test2.tga")



love.graphics.setBackgroundColor(180,190,240,255 )




f:SetBackdrop({
	edgeFile = "test2.png",
	edgeSize = 16,
	insets = {left = 4,right = 4, top = 4, bottom = 4}

})

f:SetSize(200,200)

function love.keypressed(key, uni)
	if key == "up" then
		f:SetHeight(f:GetHeight() - 20)
	elseif key == "down" then
		f:SetHeight(f:GetHeight() +20)
	elseif key == "left" then
		f:SetWidth(f:GetWidth() - 20)
	elseif key == "right" then
		f:SetWidth(f:GetWidth() +20)
	end
end

function love.update(dt)
	ui:update(dt)
end

local w = test:getHeight()
local scx = 5
local scy = 3

function love.draw()
	ui:draw()
	love.graphics.print(love.timer.getFPS(), 10, 10)
		
end