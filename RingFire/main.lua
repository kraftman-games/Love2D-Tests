-------------------------------------------------
-- LOVE: ParticleSystem demo.						
-- Website: http://love2d.org
-- Licence: ZLIB/libpng									
-- Copyright (c) 2006-2009 LOVE Development Team
-------------------------------------------------


local effect = love.graphics.newPixelEffect [[

extern vec2 chroma;

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 pc)
{
   vec2 shift = chroma / 512.0;
   return vec4(Texel(tex, tc+shift).r, Texel(tex,tc).g, Texel(tex,tc-shift).b, 1.0);
}


]]

effect:send("chroma", {10, 10})

systems = {}
current = 1

local UIx, UIy

function love.load()
	part1 = love.graphics.newImage("part1.png");
	font = love.graphics.newFont(love._vera_ttf, 10)

	love.graphics.setColor(200, 200, 200);
	
	for i = 1, 10 do
		local p = love.graphics.newParticleSystem(part1, 1000)
		p:setEmissionRate(50)
		p:setSpeed(100, 100)
		p:setGravity(0)
		p:setSizes(0.5, 0.25)
		p:setColors(255, 255, 255, 150, 5, 153, 185, 0)
		p:setPosition(400, 300)
		p:setLifetime(0.2)
		p:setParticleLife(0.5)
		p:setDirection(-1.5)
		p:setSpread(0.5)
		p:setRadialAcceleration(0)
		p:setTangentialAcceleration(0)
		p:stop()
		table.insert(systems, p)
	end
	
	for i = 1, 20 do
		local p = love.graphics.newParticleSystem(part1, 1000)
		p:setEmissionRate(100)
		p:setSpeed(50, 50)
		p:setGravity(0)
		p:setSizes(math.random(0.5,0.8), math.random(0.25, 0.6))
		p:setColors(255, 255, 255, 255, 255, 255, 255, 0)
		p:setPosition(400, 300)
		p:setLifetime(0.1)
		p:setParticleLife(0.2)
		p:setDirection(-1.5)
		p:setSpread(360)
		p:setRadialAcceleration(0)
		p:setTangentialAcceleration(0)
		p:stop()
		table.insert(systems, p)
	end
	
	
	
	UIx, UIy = love.graphics.getWidth()/2, love.graphics.getHeight()/2
end

direction = 0


local t = 0
function love.update(dt)
	t = t + dt*math.random(10)
	effect:send("chroma", { math.sin(t+math.random(10)) * 10, math.cos(t+math.random(10)) * 10})

	if love.mouse.isDown("l") then
		for i = 1, #systems do
			local x, y = love.mouse.getX(), love.mouse.getY()
			
			local angle = math.atan2(y-UIy, x-UIx)
			local rand = math.random(0,10000)
			local testx = math.cos(rand)*100
			local testy = math.sin(rand)*100
			systems[i]:setPosition(400+testx, 300+testy)
			systems[i]:setDirection(rand)
			systems[i]:start()
		end
	end
	for i = 1, #systems do
		systems[i]:update(dt)
	end
end

local fb = love.graphics.newCanvas()

function love.draw()
	love.graphics.setPixelEffect()
	love.graphics.setColorMode("modulate")
	love.graphics.setBlendMode("additive")
	fb:clear()
	love.graphics.setRenderTarget(fb)
	for i = 1, #systems do
		love.graphics.draw(systems[i], 0, 0)
	end		
	love.graphics.setRenderTarget()
	
	love.graphics.setPixelEffect(effect)
	love.graphics.draw(fb)
end

function love.mousepressed(x, y, button)
	if button == "wu" then
		current = current + 1;
		if current > table.getn(systems) then current = table.getn(systems) end
	end

	if button == "wd" then
		current = current - 1;
		if current < 1 then current = 1 end
	end
end

function love.keypressed(key)
	if key == "escape" then
		love.event.push("q")
	end
	
	if key == "r" then
		love.filesystem.load("main.lua")()
		love.load()
	end
end