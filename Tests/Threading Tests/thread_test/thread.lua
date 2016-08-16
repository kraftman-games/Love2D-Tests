--====================== thread.lua ==================
--====================================================

require ('love.timer')
require ('love.image')

local random = math.random

local this_thread = love.thread.getThread("engine")
local main_thread = love.thread.getThread("main")

local EVENTS = {}



function EVENTS.NewImage(data)
	
	math.randomseed(data)
	---[[
	local img = love.image.newImageData(1000,1000)
	for i = 0, 499 do
		for j = 0, 499 do
			img:setPixel(i,j, random(255), random(255), random(255), 255)
		end
	end
	--]]
	main_thread:send("GetImage", img)
end

while true do
	main_thread:send("test", "beep")
	this_thread:send("test", "booop")
	for event, func in pairs(EVENTS) do
		local data = this_thread:receive(event)
		if data then
			func(data)
		end
	end
end
--]]