local mirror = love.graphics.newPixelEffect [[


		
    const float size = 1.0/512.0;
    extern float disty;
		extern float distx;

    vec4 effect(vec4 global_color, Image texture, vec2 tc, vec2 pc)
        {
					vec4 pixel;
				
				if (tc.y >= disty+size*5.0) {
					if (tc.x <= distx) {
						pixel = Texel(texture, vec2((tc.x - (tc.y-disty-size*5.0)*(tc.x-distx)*2), disty-(tc.y-disty-size*5.0)*2));
					}
					else
					pixel = Texel(texture, vec2((tc.x - (tc.y-disty-size*5.0)*(tc.x-distx)*2), disty-(tc.y-disty-size*5.0)*2));
					pixel.a = 1.0-(tc.y-disty)*10;
				}
				else if (tc.y >= disty) {
					pixel = vec4 (0.0);
					}
					else {
					pixel = Texel(texture, vec2(tc.x, tc.y));
					
					}
					return pixel;
        
    }
]]

local x = 200
local y = 250
local x2 = 50
local y2 = 250

local lk = love.keyboard


love.graphics.setRenderTarget = love.graphics.setCanvas


mirror:send("disty", 400/600)
mirror:send("distx", 400/800)

local img = love.graphics.newImage("rainbow.jpg")
local img2 = love.graphics.newImage("rainbow.jpg")

local fb = love.graphics.newCanvas()
love.graphics.setRenderTarget(fb)
		love.graphics.draw(img, x, y, 0, 0.5, 0.5)
		love.graphics.draw(img2, x2, y2, 0, 0.5, 0.5)
		love.graphics.setRenderTarget()

function love.update(dt)
	local found
	if lk.isDown("left") then 
		x = x - dt*400
		found = true
	end
	if lk.isDown("right") then
		x= x + dt*400
		found = true
	end
	if lk.isDown("up") then
	 y = y - dt*400
	 found = true
	end
	if lk.isDown("down") then
	 y = y + dt*400
	 found = true
	end
	
	if lk.isDown("a") then 
		x2 = x2 - dt*400
		found = true
	end
	if lk.isDown("d") then
		x2 = x2 + dt*400
		found = true
	end
	if lk.isDown("w") then
		y2 = y2 - dt*400
		found = true
	end
	if lk.isDown("s") then
	  y2 = y2 + dt*400
		found = true
	end
	
	if found then
		fb:clear()
		love.graphics.setRenderTarget(fb)
		love.graphics.draw(img, x, y, 0, 0.5, 0.5)
		love.graphics.draw(img2, x2, y2, 0, 0.5, 0.5)
		love.graphics.setRenderTarget()
	end
end

function love.draw()
love.graphics.setPixelEffect(mirror)
love.graphics.draw(fb)
love.graphics.setPixelEffect()
end



















