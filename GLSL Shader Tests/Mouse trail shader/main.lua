
--[=[
    effects = {}
    
    effects.imagepassthrough = love.graphics.newPixelEffect[[
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
        {
            return color * Texel(texture, texture_coords);
        }
    ]]
    
    effects.shapepassthrough = love.graphics.newPixelEffect[[
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
        {
            return color;
        }
    ]]
    
    effects.sphere = love.graphics.newPixelEffect[[
        extern number time; // time in seconds
        
        vec4 effect(vec4 color, Image texture, vec2 tc, vec2 pixel_coords)
        {
            vec2 p = -1.0 + 2.0 * tc;
            float r = dot(p, p);
            
            if (r > 1.0) discard;
            
            float f = (1.0 - sqrt(1.0 - r)) / (r);
            vec2 uv;
            uv.x = 1.0*p.x*f + time;
            uv.y = 1.0*p.y*f;
            
            return vec4(Texel(texture, uv).xyz, 1.0) * color;
        }
    ]]
    effects.sphere:send("time", 0)
    
    effects.sphere2 = love.graphics.newPixelEffect[[
        const float pi = 3.14159265;
        const float pi2 = 2.0 * pi;
        
        extern number time;
                
        vec4 effect(vec4 color, Image texture, vec2 tc, vec2 pixel_coords)
        {
            vec2 p = 2.0 * (tc - 0.5);
            
            float r = sqrt(p.x*p.x + p.y*p.y);
        
            if (r > 1.0) discard;
            
            float d = r != 0.0 ? asin(r) / r : 0.0;
                        
            vec2 p2 = d * p;
            
            float x3 = mod(p2.x / (pi2) + 0.5 + time, 1.0f);
            float y3 = p2.y / (pi2) + 0.5;
            
            vec2 newCoord = vec2(x3, y3);
            
            vec4 sphereColor = color * Texel(texture, newCoord);
                        
            return sphereColor;
        }
    ]]
    effects.sphere2:send("time", 0)


--]=]




fade = love.graphics.newPixelEffect [[
        // REMEMBER TO ADD ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       
        const float blurSize = 1.0/512.0; 
        

        vec4 effect(vec4 global_color, Image texture, vec2 texture_coords, vec2 pixel_coords)
        {

        vec4 sum = vec4(0.0);
        float fade = 0.0001;
 
       sum += (texture2D(texture, vec2(texture_coords.x - 4.0*blurSize, texture_coords.y)) * 0.05)-fade;
       sum += (texture2D(texture, vec2(texture_coords.x - 3.0*blurSize, texture_coords.y)) * 0.09)-fade;
       sum += (texture2D(texture, vec2(texture_coords.x - 2.0*blurSize, texture_coords.y)) * 0.12)-fade;
       sum += (texture2D(texture, vec2(texture_coords.x - blurSize, texture_coords.y)) * 0.15)-fade;
       sum += (texture2D(texture, vec2(texture_coords.x, texture_coords.y)) * 0.181)-fade;
       sum += (texture2D(texture, vec2(texture_coords.x + blurSize, texture_coords.y)) * 0.15)-fade;
       sum += (texture2D(texture, vec2(texture_coords.x + 2.0*blurSize, texture_coords.y)) * 0.12)-fade;
       sum += (texture2D(texture, vec2(texture_coords.x + 3.0*blurSize, texture_coords.y)) * 0.09)-fade;
       sum += (texture2D(texture, vec2(texture_coords.x + 4.0*blurSize, texture_coords.y)) * 0.05)-fade;
        sum.a = 1;
         
         return sum ;
        }
    ]]

fade2 = love.graphics.newPixelEffect [[
        // REMEMBER TO ADD ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       
        const float blurSize = 1.0/512.0; 
        

        vec4 effect(vec4 global_color, Image texture, vec2 texture_coords, vec2 pixel_coords)
        {

        vec4 sum = vec4(0.0);
        float fade = 0.00;
 
 sum += texture2D(texture, vec2(texture_coords.x, texture_coords.y - 4.0*blurSize)) * 0.05;
   sum += texture2D(texture, vec2(texture_coords.x, texture_coords.y- 3.0*blurSize)) * 0.09;
   sum += texture2D(texture, vec2(texture_coords.x, texture_coords.y- 2.0*blurSize)) * 0.12;
   sum += texture2D(texture, vec2(texture_coords.x, texture_coords.y - blurSize)) * 0.15;
   sum += texture2D(texture, vec2(texture_coords.x, texture_coords.y)) * 0.16;
   sum += texture2D(texture, vec2(texture_coords.x, texture_coords.y + blurSize)) * 0.15;
   sum += texture2D(texture, vec2(texture_coords.x, texture_coords.y  + 2.0*blurSize)) * 0.12;
   sum += texture2D(texture, vec2(texture_coords.x, texture_coords.y + 3.0*blurSize)) * 0.09;
   sum += texture2D(texture, vec2(texture_coords.x, texture_coords.y + 4.0*blurSize)) * 0.05;
        sum.a = 1;
         
         return sum ;
        }
    ]]







local fb1 = love.graphics.newCanvas()
local fb2 = love.graphics.newCanvas()


function love.draw()
     love.graphics.setPixelEffect()
    love.graphics.setRenderTarget(fb1)
    love.graphics.draw(fb2)
    if love.mouse.isDown("l") then
        local x,y = love.mouse.getPosition()
       local size = math.random(5,30)
        love.graphics.setColor(255,255,255,255)
        love.graphics.rectangle("fill",x-size/2,y-size/2, size, size) 
            
    elseif love.mouse.isDown("r") then
         local x,y = love.mouse.getPosition()
       local size = math.random(5,30)
        love.graphics.setColor(0,0,0,255)
        love.graphics.rectangle("fill",x-size/2,y-size/2, size, size) 
         love.graphics.setColor(255,255,255,255)
    end

    love.graphics.setRenderTarget(fb2)
    
        love.graphics.setPixelEffect(fade)
        love.graphics.draw(fb1)
    
    love.graphics.setRenderTarget()
    love.graphics.setPixelEffect(fade2)
    love.graphics.draw(fb2)

   
   
end
