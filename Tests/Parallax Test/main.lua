--[[
flat list of all items sorted by depth

hierarchy of items in order to 

--]]


local template = {}
template.x = 0
template.y = 0
template.z = 0
template.xoff = 0
template.yoff = 0
template.zoff = 0
template.children = {}
local flat = {}

local tinsert = table.insert



--[[
function template:updateLoc() --update location, feeds down
	self.x = self.parent.x + self.xoff
	self.y = self.parent.y + self.yoff
	self.z = self.parent.z + self.zoff
	
	self.realx = self.x
	self.realy = self.y
	--self.circle = #self.children *10
	for i = 1, #self.children do
		self.children[i]:updateLoc()
	end
end

function template:draw()
	love.graphics.print(self.label, self.realx, self.realy)
	for i = 1, #self.children do
		self.children[i]:draw()
	end
end


function template:Create(label)
	local n = {}
	n.__index = template
	setmetatable(n,n)
	n.label = label or ""
	n.x = 0
	n.y = 0 
	n.z = 0 
	n.vx = 0
	n.vy = 0
	n.vz = 0
	n.offx = 0 
	n.offy = 0 
	n.offz = 0
	n.realx = 0
	n.realy = 0
	n.children = {}
	n.parent = self
	
	tinsert(self.children, n)
	tinsert(flat, n)
	return n
end

local center = template:Create()
center.xoff = 200
center.yoff = 200

center.label = "test"

local test = center:Create("test2")
test.xoff = 20
test.yoff = 20

center:updateLoc()




function love.draw()
	center:draw()
end


--]]
local cam = {}
cam.x = 400
cam.y = 300
cam.z = 0
cam.dist = 200
cam.width = 800
cam.height = 600

local cubes = {}

for i = 1, 20 do
	local c = {}
	c.x = math.random(0,800)
	c.y = math.random(0,600)
	c.z = math.random(0,255)
	tinsert(cubes, c)
end

function love.update(dt)

	if love.keyboard.isDown("d") then
		cam.x = cam.x + dt *1000
	end
	
	if love.keyboard.isDown("a") then
		cam.x = cam.x - dt *1000
	end

	if love.keyboard.isDown("s") then
		cam.z = cam.z - dt *1000
	end
	
	if love.keyboard.isDown("w") then
		cam.z = cam.z + dt *1000
	end
end

function love.draw()
	for i = 1, #cubes do
		love.graphics.setColor(255,255,255,255-cubes[i].z + cam.z)
		love.graphics.rectangle("fill", cubes[i].x+cam.x/cubes[i].z, cubes[i].y+cam.y/cubes[i].z,10,10)
	end
end

