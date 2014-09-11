


require "autothread"


local sub_thread = newThread("testthread") 

sub_thread:start()


sub_thread:run [[require "love.image"]]
sub_thread:run [[ function runGet.NewImage(seed)
										math.randomseed(seed)
										local rand = math.random
										local img = love.image.newImageData(1000,1000)
										for i = 0,999 do
											main_thread:set("progress", math.floor((i/999)*100))
											for j = 0,999 do
												img:setPixel(i,j,rand(255),rand(255),rand(255),255)
											end
										end
										main_thread:set("NewImage",img)
									end
										 ]]


local image
local progress


function runGet.NewImage(data)
	image = love.graphics.newImage(data)
end

function runPeek.progress(data)
	progress = "Loading image, "..data.."%"
end

function love.update(dt)
	updateThreads()
end

function love.draw()
	updateThreads()
	if image then
		love.graphics.draw(image, 100, 50)
	end
	
	if progress then
		love.graphics.print("progress: "..progress, 10,60)
	end
end


function love.keypressed(key)
	key = tonumber(key) or string.byte(key)
	sub_thread:set("NewImage",key)
end