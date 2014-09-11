
local EVENTS_GET = {}
local EVENTS_PEEK = {}

maint = love.thread.getThread("main")
sub = love.thread.newThread("engine", "thread.lua")

sub:start()


local function run(thread, data)
	local msg = thread:peek("RUN")
	if msg then
		msg = msg.." "..data
	else
		msg = data
	end
	thread:set("RUN", msg)
end

run(sub, "require 'love.graphics'")
run(sub, "require 'love.image'")
run(sub, [[function EVENTS_GET.NewImage(seed) 
						math.randomseed(seed)
						local img = love.image.newImageData(500,500)
						for i = 0, 499 do for j = 0,499 do
							 img:setPixel(i,j,math.random(255), math.random(255), math.random(255),255)
						end end
						maint:set('NewImage', img)
					end
							 ]])


local i = 1
local image

function love.draw()
	i = i + 1
	love.graphics.print(i, 50, 50)
	
	local test = maint:peek("test")
	if test then
		love.graphics.print(test, 40, 40)
	end

	local er = sub:peek("error")
	if er then
			love.graphics.print(er, 20, 20)
	end

	for event, func in pairs(EVENTS_PEEK) do
		local data = maint:peek(event)
		if data then
			func(data)
		end
	end
	for event, func in pairs(EVENTS_GET) do
		local data = maint:peek(event)
		if data then
			func(data)
		end
	end

	if image then
		love.graphics.draw(image, 100,20)
	end
end


function love.keypressed(key)
	key = tonumber(key) or string.byte(key)
sub:set("NewImage",key)
end

function EVENTS_GET.NewImage(data)
	image = love.graphics.newImage(data)
end