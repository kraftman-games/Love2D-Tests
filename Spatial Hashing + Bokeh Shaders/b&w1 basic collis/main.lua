--[[
BALLS  FPS
180 49
200 40
220 37
]]



local scwidth, scheight


local balls = {} -- table containing all of the balls
local mb = {}


function love.load()
	balls = {}
	scwidth = love.graphics.getWidth()
	scheight = love.graphics.getHeight()
end



function mb:update(dt) --movement pass
	
	local newx, newy
	newx = self.x + self.vx*dt
	newy = self.y + self.vy *dt
	

	if newx-self.r < 0 then
		newx = -(newx-self.r) +self.r
		self.vx = -self.vx
	elseif newx+self.r > scwidth then
		newx = scwidth - (newx-scwidth+self.r) -self.r
		self.vx = -self.vx
	end

	if newy-self.r < 0 then
		newy = -(newy-self.r) +self.r
		self.vy = -self.vy
	elseif newy+self.r > scheight then
		newy = scheight - (newy-scheight+self.r) -self.r
		self.vy = -self.vy
	end
	
	self.x = newx
	self.y = newy
	
	local ball
	local pen
	self.col = false
	for i = 1, #balls do
		if i ~= self.index then
			ball = balls[i]
			if (self.x - ball.x)^2 + (self.y - ball.y)^2 < (ball.r + self.r)^2 then
				self.col = true
			end
		end
	end
end






function mb:new()
	local b = {}
	local x, y = love.mouse.getPosition()
	b.x = math.random(20, scwidth-20)
	b.y = math.random(20,scheight-20)
	b.vx = math.random(-50,50)
	b.vy = math.random(-50,50)
	b.r = math.random(2,7)
	b.update = mb.update
	b.draw = mb.draw
	b.collide = mb.collide
	table.insert(balls, b)
	b.index = #balls

end


function mb:draw()
	if self.col then
		love.graphics.setColor(255,0,0,255)
	else
		love.graphics.setColor(255,255,255,255)
	end
	love.graphics.circle("fill", self.x, self.y, self.r, 16)
end

--======= standard callbacks

function love.mousepressed()
	for i = 1, 20 do
		mb:new()
	end
end


function love.update(dt)
	for i = 1, #balls do
		balls[i]:update(dt)
	end
end

function love.draw()
	for i = 1, #balls do
		balls[i]:draw()
	end

	love.graphics.print("FPS: "..love.timer.getFPS(), 10 ,10)
	love.graphics.print("Balls: "..#balls, 10 , 30)
end




