--[[
shader 1
recalc colours
angle = sum of all neighbour angles that fall on the pixel
r,g,b,a = angle, size

shader 2
display them
color = angle
intensity = scale


draw:
draw new colours to fb1
draw fb1 through shader 1 to fb2

draw fb2 through shader 2 

alternate

]]






local fb1 = love.graphics.newCanvas()
local fb2 = love.graphics.newCanvas()

local calcshader = love.graphics.newPixelEffect [[

extern image fb;

  vec4 effect(vec4 global_color, Image texture, vec2 tc, vec2 pc)
        {
        vec4 pixel = Texel(fb, texture_coords);
        
        

    	}

]]

local outputshader = love.graphics.newPixelEffect [[
    


    vec3 HSV(float h, float s, float v)
    {
    	if (s <= 0 ) {
    		return vec3 (0.0);
    	}
        h = h * 6;
    	float c = v*s;
    	float x = (1-abs((mod(h,2)-1)))*c;
    	float m = v-c;
    	float r = 0.0,0.0,0.0;
        float g = 0.0;
        float b = 0.0;

    	if (h < 1) { 
            r = c;
            g = x;
            b = 0.0;
	        }
	    else if (h < 2) {
            r = x;
            g = c;
            b = 0.0; 
			}
	    else if (h < 3) {
            r = 0.0;
            g = c;
            b = x; 
			}
	    else if (h < 4) {
            r = 0.0;
            g = x;
            b = c;  
			}
	    else if (h < 5) {
            r = x;
            g = 0.0;
            b = c;  
			}
	    else  {
		    r = c;
            g = 0.0;
            b = x; 
			}
	    
    	
    	return vec3(r+m,g+m,b+m);
    }

     vec4 effect(vec4 global_color, Image texture, vec2 tc, vec2 pc)
        {
        vec4 pixel = Texel(texture, texture_coords);

        return vec4(HSV(pixel.r, pixel.g,1.0),1.0)

    	}

]]





function love.update(dt)
	local x,y = love.mouse.getPosition()
	calcshader:send("mouse", x, y)

end




function love.draw()
	love.graphics.setRenderTarget(fb2)
	love.graphics.setPixelEffect(calcshader)
	love.graphics.draw(fb1)
	love.graphics.setPixelEffect(outputshader)
	love.graphics.draw(fb2)
	fb1, fb2 = fb2, fb1
	love.graphics.setPixelEffect()

end