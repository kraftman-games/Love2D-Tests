function love.load()
	math.randomseed(os.time())
	blocksize = 20
	player = {
		position = {
			x = 100,
			y = -100
		},
		size = {
			x = 20,
			y = 40
		}
	}
	--order textures in fancy table
	blocktextures = {
		["Stone"] = love.graphics.newImage("Stone.png"),
		["Grass"] = love.graphics.newImage("Grass.png"),
		["Dirt"] = love.graphics.newImage("Dirt.png")
	}
	playerimg = love.graphics.newImage("player.png")
	--midpoint displacement 2D terrain generator
	points = {0,0}
	beginratio = 2^10/4
	function routine()
		add = 0
		for point = 1, #points do
			point = point+add
			if point >= #points then return end
			point1 = points[point]
			point2 = points[point+1]
			point3 = (point1+point2)/2+math.random(-beginratio,beginratio)
			table.insert(points, point+1, point3)
			add = add+1
		end
	end
	for i = 1, 10 do
		routine()
		beginratio = beginratio/2
	end
	--make the real terrain that you see
	field = {}
	for i,v in pairs(points) do
		h = math.floor(v+0.5)
		for blockies = 1,10 do
			if blockies == 1 then
				chosentexture = "Grass"
			elseif blockies > 1 and blockies < 5 then
				chosentexture = "Dirt"
			elseif blockies > 4 then
				chosentexture = "Stone"
			end
			block = {
				position = {
					x = i*blocksize,
					y = (h*blocksize)+(blockies*blocksize)
				},
				size = {
					x = blocksize,
					y = blocksize
				},
				texture = chosentexture
			}
			table.insert(field,block)
		end
	end
	--WHATCHA DOING?
	love.graphics.setBackgroundColor(0,100,175)
	newpos = nil
	t1 = 0
	friction = 0
end
--collision detection blargh 3:
function collision(np)
	local col = false
	for i,o in pairs(field) do
		local x1 = o.position.x-np.x
		local x2 = 400
		local y1 = o.position.y-np.y
		local y2 = 300
		if math.sqrt((x1-x2)^2+(y1-y2)^2) < 100 then--you dont have to check collision with blocks that are not closeby
			local ap = {x = o.position.x-np.x,y = o.position.y-np.y}
			local as = o.size
			local bp = {x = 400, y = 300}
			local bs = player.size
			YON = ap.x + as.x > bp.x and bp.x + bs.x > ap.x and ap.y + as.y > bp.y and bp.y + bs.y > ap.y
			if YON then col = true end
		end
	end
	if col then else--if there was no collision, aprove movement
		player.position.x = np.x
		player.position.y = np.y
	end
	return col
end
--keys blabla
function love.update(dt)
	t1 = t1+dt
	if t1 > 0.001 then
		if itcollided == false then
			friction = friction + 0.5--gravity
		end
		if love.keyboard.isDown("a") then
			local newpos = {x = player.position.x, y = player.position.y}
			newpos.x = newpos.x-2
			collision(newpos)
		end
		if love.keyboard.isDown("d") then
			local newpos = {x = player.position.x, y = player.position.y}
			newpos.x = newpos.x+2
			collision(newpos)
		end
		local newpos = {x = player.position.x, y = player.position.y}
		newpos.y = newpos.y+(friction)
		itcollided = collision(newpos)
		if itcollided then--OH OH IT TOUCHED SOMETHING
			friction = 0--STOP
		end
		t1 = 0
	end
end
function love.keypressed(k)
	if k == " " then
		friction = -10--set jump friction
	end
end	
--drawy
function love.draw()
	love.graphics.draw(playerimg,400,300,0,player.size.x/playerimg:getWidth(),player.size.y/playerimg:getHeight())
	for i,o in pairs(field) do
		if o.position.x-player.position.x > 0 and o.position.x-player.position.x < 800 and o.position.y-player.position.y > 0 and o.position.y-player.position.y < 600 then--only draw blocks that only get on the screen
			whattexture = blocktextures[o.texture]
			love.graphics.draw(whattexture,o.position.x-player.position.x,o.position.y-player.position.y,0,o.size.x/whattexture:getWidth(),o.size.y/whattexture:getHeight())	
		end
	end
end