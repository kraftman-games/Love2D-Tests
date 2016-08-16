
local random = math.random
math.randomseed(5)

local map = {}

for i = 1, 500 do 
	map[i] = {}
	for j = 1, 500 do
		map[i][j] = 0
	end
end

--seed the map
for i = 1, 15 do
	local a, b = random(500), random(500)
	for j = a-5, a+5 do 
		for k = b-5, b+5 do
			if  map[j] and map[j][k] then
				map[j][k] = 1
			end
		end
	end
end



local buffer = love.graphics.newFramebuffer()

local function increment()


for i = 1, 500 do
	for j = 1, 500 do
		
		local chance = 0
		
		if map[i-1] then
			chance = chance + (map[i-1][j-1] or map[i-1][500])
			chance = chance + map[i-1][j]
			chance = chance + (map[i-1][j+1] or map[i-1][1])
		else
			chance = chance + (map[500][j-1] 
			or map[500][500])
			chance = chance + map[500][j]
			chance = chance + (map[500][j+1] or map[500][1])
		end
		
		if map[i+1] then
			chance = chance + (map[i+1][j-1] or map[i+1][500])
			chance = chance + map[i+1][j]
			chance = chance + (map[i+1][j+1] or map[i+1][1])
		else	
			chance = chance +( map[1][j-1] or map[1][500])
			chance = chance + map[1][j]
			chance = chance + (map[1][j+1] or map[1][1])
		end
			
		chance = chance + (map[i][j-1] or map[i][500])
		chance = chance + map[i][j]
		chance = chance + (map[i][j+1] or map[i][1])
		chance = chance + random(4)
		

		if chance > 5 then
			map[i][j] = 1
		else
			map[i][j] = 0
		end
	end
end




--     draw
	love.graphics.setRenderTarget(buffer)	
	
	for i = 1, 500 do
		for j = 1, 500 do
			if map[i][j] == 1 then
				love.graphics.setColor(0,255,0,255)
			else
				love.graphics.setColor(0,0,255,255)
			end
			love.graphics.rectangle("fill", i*2, j*2, 2, 2)
		end
	end
	
	love.graphics.setRenderTarget()
end

--=====


--=========== LOAD ======================

function love.load()

end

--=============== KEYBOARD ==============

function love.keypressed(key,uni)

end



--================= UPDATE =====================

function love.update(dt)


end

-- ================== MOUSE =================

function love.mousepressed(x,y,button)
	increment()
end

function love.mousereleased(x,y,button)
	
end

-- ================= DRAW =====================

function love.draw()
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(buffer,0,0)
	love.graphics.print(love.timer.getFPS(), 400, 400)
end