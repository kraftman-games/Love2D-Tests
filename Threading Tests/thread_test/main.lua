-- ============== main.lua =============
--======================================

local gettime = love.timer.getMicroTime

function love.load()
	main_thread = love.thread.getThread("main")
	sub_thread = love.thread.newThread("engine", "thread.lua")
	sub_thread:start()
end

local a,b

local EVENTS = {}

local image

function love.update(dt)

	--testing
	local err = sub_thread:peek("error")
	if err then 
		print(err)
	end
	
	
	--actual stuff
	for event, func in pairs(EVENTS) do
		local data = main_thread:receive(event)
		if data then
			func(data)
		end
	end
	
	
	
end

function EVENTS.GetImage(data)

	image = love.graphics.newImage(data)
	b = gettime()
end

function EVENTS.error(data)
	print(data)
end


function love.draw()	
	if image then
		love.graphics.draw(image, 20, 30)
	end
	if a and b then 
		love.graphics.print(b-a, 10,10)
		end
end

function love.keypressed(k)
	if k == "w" then
		sub_thread:send("NewImage", 123)
		print(k.." pressed")
		a = gettime()
	elseif k == "e" then
		sub_thread:send("NewImage", 456)
		a = gettime()
	elseif k == "r" then
		main_thread:send("error", "test error")
	end
end