
local Time = love.timer.getMicroTime

local timer = {}

function test()
	timer.a = Time()
	local msg = "1"

	for i = 1, 10000 do
		msg = msg..1
	end

	timer.b = Time()

	local img = love.image.newImageData(100,100)
	for i = 0, 99 do
		for j = 0,99 do
			img:setPixel(i,j,1,0,0,0) -- 0's coudl be used for other stuff, etc
		end
	end

	timer.c = Time()
	local t = {}
	for a in msg:gmatch("(%d)") do
	
		t[#t+1] = a
	end

	timer.d = Time()
	local t2 ={}
	for i = 0,99 do
		for j = 0,99 do
			t2[#t2] = img:getPixel(i,j)
		end
	end

	timer.e = Time()

end

function love.draw()
if timer.a then
	love.graphics.print("serialise string: "..(timer.b-timer.a), 10, 20)
	love.graphics.print("serialise imgdata: "..(timer.c-timer.b), 10, 40)
	love.graphics.print("unpack string: "..(timer.d-timer.c), 10, 60)
	love.graphics.print("unpack imgdata: "..(timer.e-timer.d), 10, 80)
end
end

function love.keypressed()
test()

end