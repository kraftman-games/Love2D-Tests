--[[
I saw a comment in #love a few days ago asking about spatial hashing in  LÖVE.
I haven't dealt with collisions or their efficiency much so far, so I thought I'd 
take a look into it, and make my first tutorial while I'm at it.

The aim of this is to learn a little about collision detection for circles in 2D, 
and how spatial hashing can greatly improve the performance.

1. Something to Collide
Before we can start worrying about the collision systems themselves, 
we'll need to create something with the potential to collide. 
In this example I'll be using simple circles so that we don't over complicate 
the collision calculations, and we'll need the circles to move so that the collisions can change over time:

First, we need a table to store all of the "balls" that are created, so that we can easily look them up later. 
We then need a function which creates new balls with some initial parameters such as size, speed, and position, 
and then adds these into the list that contains all of the other balls

--]]

local balls = {}

local function NewBall()
	local b = {} --create a table for this ball

	b.x, b.y = 400, 300 -- initial x and y location of the balls
	
	b.vx = math.random(-50,70) --initial velocities of the balls in the x and y direction
	b.vy = math.random(-50,70)
	b.r = math.random(2,7) --radius of the ball
	table.insert(balls, b)
																									
end

--[[
	then we need a function to update the positions of each ball in this table
--]]

local function UpdateBalls(dt)
	for i = 1, #balls do
			balls[i].x = balls[i].x + balls[i].vx * dt --update the locations of each ball
			balls[i].y = balls[i].y + balls[i].vy * dt
	end
end

local function DrawBalls()
	for i = 1, #balls do
		love.graphics.circle("fill", balls[i].x, balls[i].y, balls[i].r, 16)
	end
end

-- and a trigger to create the new balls

function love.mousepressed()
	NewBall()
end


-- We can then add these into love.update and love.draw respectively, to get our initial program!

function love.update(dt)
	UpdateBalls(dt)
end

function love.draw()
	DrawBalls()
end


