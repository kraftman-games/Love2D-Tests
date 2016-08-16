	

local scwidth, scheight --scene width and height

--these are just local references to speed up the calls/shorten the names
local lg = love.graphics
local lt = love.timer
local floor = math.floor
local pairs = pairs
local rand = math.random


local balls = {} -- table containing all of the balls
local mb = {} --this contains the functions that the balls use

local bwidth,cellsize --width of scene, in buckets, width of buckets in pixels

local buckets = {} --holds each bucket

local timer = {} --holds the timers to use to see how long the code is taking to run

local showgrid = true --show grid lines



function love.load()
	scwidth = love.graphics.getWidth() --query and store the width of the screen
	scheight = love.graphics.getHeight() --query and store the height of the screen
	
	bwidth = 2 --how many buckets the screen is divided into
	cellsize = scwidth/bwidth -- the width of the buckets
	
end


function mb:update(dt) --movement pass
	
	
	self.x = self.x + self.vx*dt --update the locations of each ball
	self.y = self.y + self.vy *dt
	

	if (self.x-self.r < 5 and self.vx < 0) or (self.x+self.r > scwidth-5 and self.vx > 0) then --reverse the direction if it collides with walls
		self.vx = -self.vx
	end

	if (self.y-self.r < 5 and self.vy < 0) or (self.y+self.r > scheight-5 and self.vy > 0) then
		self.vy = -self.vy
	end
	
	local loc	
	
	self.col = false -- reset the status of the collision
	
	for x = self.x-self.r, self.x+self.r, self.r*2 do
		for y= self.y-self.r, self.y+self.r, self.r*2 do
			 loc = floor(x/cellsize) + floor(y/cellsize)*bwidth
			if not buckets[loc] then
				buckets[loc] = {}
			end
			 buckets[loc][self] = self
		end
	end
	
end


function mb:new()
	local b = {}
	local x, y = love.mouse.getPosition()
	b.x = rand(20, scwidth-20)
	b.y = rand(20,scheight-20)
	b.vx = rand(-50,70)
	b.vy = rand(-50,70)
	b.r = rand(2,7)
	b.update = mb.update
	b.draw = mb.draw
	b.collide = mb.collide
	b.loc = {}

	table.insert(balls, b)
	b.index = #balls

end


function mb:draw()
	if self.col then
		lg.setColor(255,0,0,255)
	else
		lg.setColor(255,255,255,255)
	end
	lg.circle("fill", self.x, self.y, self.r, 16)
end

--======= standard callbacks

function love.mousepressed()
	for i = 1, 20 do
		mb:new()
	end
end


local function CollisionCheck()
	for k in pairs(buckets) do --for each bucket
		for b in pairs(buckets[k]) do --for each ball
			for bc in pairs(buckets[k]) do --check each other ball
				if b~=bc then
					if (b.x - bc.x)^2 + (b.y - bc.y)^2 < (b.r + bc.r)^2 then --check if the spheres intersect
						b.col = true
					end
				end
			end
		end
	end
end


function love.keypressed(key)
	if key == "up" then
		bwidth = bwidth + 1 --width of the screen in buckets
	elseif key == "down" then
		bwidth = bwidth - 1
	elseif key == "g" then
		showgrid = not showgrid
	end
	
	cellsize = scwidth/bwidth
	
end

function love.update(dt)
	
	timer.a = love.timer.getMicroTime()
	
	buckets = {}
	
	for i = 1, #balls do
		balls[i]:update(dt) --just updates their positions and bounces them off walls
	end
	
	timer.b = love.timer.getMicroTime()
		
		CollisionCheck()
	
	timer.c = love.timer.getMicroTime()
	
end

function love.draw()
	love.graphics.setColor(255,255,255,255)
	
	for i = 1, #balls do
		balls[i]:draw()
	end
	
	love.graphics.setColor(255,255,255,255)
	lg.print("FPS: "..lt.getFPS(), 10 ,10)
	lg.print("Balls: "..#balls, 10 , 30)
	lg.print("Cell width: "..cellsize, 10, 50)
	
	lg.print("Time to sort to buckets"..(timer.b-timer.a), 10, 80)
	lg.print("Time to check buckets"..(timer.c-timer.b), 10, 100)
	
	love.graphics.setColor(0,255,30,255)
	if showlines then
		for i = 0, scwidth, cellsize do
			love.graphics.line(i, 0, i, scheight)
		end
		for i = 0, scheight, cellsize do
			love.graphics.line(0, i, scwidth, i)
		end
	end
end




