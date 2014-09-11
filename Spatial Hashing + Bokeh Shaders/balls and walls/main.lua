
local lg = love.graphics --shorthand for accessing the love.graphics module
local rand = math.random --shorter and also local version of random, for faster lookup
local abs = math.abs


local scwidth = 800
local scheight = 600


local balls = {}


local mb = {}


function love.load()
	balls = {}
end



function mb:update(dt) --movement pass
	
	local newx, newy
	newx = self.x + self.vx*dt
	newy = self.y + self.vy *dt
	
	--first we'll check if it collides with the walls, and correct it if it does
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

function mb:collide(dt)
	local ball
	local pen
	sel.col = false
	for i = 1, #balls do
		if i ~= self.index then
			ball = balls[i]
			if (self.x - ball.x)^2 + (self.y - ball.y)^2 < (ball.r + self.r)^2 then
				self.col = true
			end
			--[[
			pen =  (self.x - ball.x)^2 + (self.y - ball.y)^2 - (ball.r + self.r)^2 
			
			if pen < 0 then --balls are touching!
				pen = math.sqrt(pen) -- the ctual penetration
				local penx = pen*((self.x - ball.x)^2 - self.x-ball.x) --normalised for x
				local peny = pen*((self.y- ball.y)^2 - self.y-ball.y) --normalised for y
			end
			]]
		end
	end
		

end




function mb:new()
	local b = {}
	local x, y = love.mouse.getPosition()
	b.x = x
	b.y = y
	b.vx = rand(-50,50)
	b.vy = rand(-50,50)
	b.r = rand(5,15)
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


function love.mousereleased()
	mb:new()
end

function love.update(dt)
if love.mouse.isDown("l") then
	
	mb:new()
end
	for i = 1, #balls do
		balls[i]:update(dt)
	end
end

function love.draw()
	lg.setColor(255,255,255,255)
	for i = 1, #balls do
		balls[i]:draw()
	end
	lg.setColor(0,255,255,255)
	lg.print("FPS: "..love.timer.getFPS(), 10 ,10)
	lg.print("Balls: "..#balls, 10 , 30)
end