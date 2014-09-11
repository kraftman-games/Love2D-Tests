function love.load()
    effect = love.graphics.newPixelEffect [[
        
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
        {
            return vec4(0.5, 1.0, 1.0, 1.0);
        }
    ]]


    effect2 = love.graphics.newPixelEffect [[
        
        const float blurSize = 1.0/512.0; // I've chosen this size because this will result in that every step will be one pixel wide if the RTScene texture is of size 512x512
 
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
        {
        vec4 sum = vec4(0.0);
 
   sum += texture2D(texture, vec2(texture_coords.x - 4.0*blurSize, texture_coords.y)) * 0.05;
   sum += texture2D(texture, vec2(texture_coords.x - 3.0*blurSize, texture_coords.y)) * 0.09;
   sum += texture2D(texture, vec2(texture_coords.x - 2.0*blurSize, texture_coords.y)) * 0.12;
   sum += texture2D(texture, vec2(texture_coords.x - blurSize, texture_coords.y)) * 0.15;
   sum += texture2D(texture, vec2(texture_coords.x, texture_coords.y)) * 0.16;
   sum += texture2D(texture, vec2(texture_coords.x + blurSize, texture_coords.y)) * 0.15;
   sum += texture2D(texture, vec2(texture_coords.x + 2.0*blurSize, texture_coords.y)) * 0.12;
   sum += texture2D(texture, vec2(texture_coords.x + 3.0*blurSize, texture_coords.y)) * 0.09;
   sum += texture2D(texture, vec2(texture_coords.x + 4.0*blurSize, texture_coords.y)) * 0.05;

   sum += texture2D(texture, vec2(texture_coords.x, texture_coords.y - 4.0*blurSize)) * 0.05;
   sum += texture2D(texture, vec2(texture_coords.x, texture_coords.y- 3.0*blurSize)) * 0.09;
   sum += texture2D(texture, vec2(texture_coords.x, texture_coords.y- 2.0*blurSize)) * 0.12;
   sum += texture2D(texture, vec2(texture_coords.x, texture_coords.y - blurSize)) * 0.15;
   sum += texture2D(texture, vec2(texture_coords.x, texture_coords.y)) * 0.16;
   sum += texture2D(texture, vec2(texture_coords.x, texture_coords.y + blurSize)) * 0.15;
   sum += texture2D(texture, vec2(texture_coords.x, texture_coords.y  + 2.0*blurSize)) * 0.12;
   sum += texture2D(texture, vec2(texture_coords.x, texture_coords.y + 3.0*blurSize)) * 0.09;
   sum += texture2D(texture, vec2(texture_coords.x, texture_coords.y + 4.0*blurSize)) * 0.05;
   return sum/2;
}


    ]]
end


local image = love.graphics.newImage("mesh.png")

function love.draw()
   

    -- LOOK AT THE PRETTY COLORS!
    love.graphics.setPixelEffect(effect2)
    love.graphics.draw(image)
end

local t = 0
function love.update(dt)
    t = t + dt
    --effect:send("time", t)
end

