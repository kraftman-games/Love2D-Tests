
local sb = {}
sb.xoff = 30
sb.yoff = 30
sb.scale = 0.5




--[[
local oldgetwidth = love.graphics.getWidth

function love.graphics.getWidth()
	return oldgetwidth*sb.scale
end

local oldgetheight = love.graphics.getHeight

function love.graphics.getHeight()
	return oldgetheight*sb.scale
end
--]]

--[[
TODO:
work out a collision system

make a decent looking "bullet" to fire



--]]
require("myAPI") -- load the other file

DrawList = {{},{},{},{},{}} --list of all frames that need to be drawn
FrameList = {} --flat list of all frames

ConvertStrata = {}
ConvertStrata.BACKGROUND = 1
ConvertStrata.LOW = 2
ConvertStrata.MEDIUM = 3
ConvertStrata.HIGH = 4
ConvertStrata.TOOLTIP = 5
--[[
draw list layers

1 - BACKGROUND
2 - LOW
3 - MEDIUM
4 - HIGH
5 - TOOLTIP

--]]

local UIParent = {}

UIParent.width = love.graphics.getWidth()
UIParent.height = love.graphics.getHeight()

local gravity = 1


function love.load()
	bug = CreateFrame("MEDIUM")
	bug:SetSize(100, 100)
	bug:SetPoint(400, 300)
	bug:SetImage("bug.gif")
	bug:ClampedToScreen(true)
	bug:SetVelocity(0, 0)
	bug:SetScale(0.5)
	
	bug:SetRotation(0)
	
	bug.arm = CreateFrame("MEDIUM", bug)
	bug.arm:SetSize(16,64)
	bug.arm:SetImage("bugarm.gif")
	bug.arm:SetPoint(20, 45) --relative to parent
	bug.arm:SetOrigin(bug.arm.imagew/2,29)
	
	bug:SetCollide(true)
	local t = function(self, collider)
		self.vy = 0
		self.grounded = true
	end
	bug:SetOnCollision(t)
	
	ground = CreateFrame("BACKGROUND")
	ground:SetWidth(UIParent.width)
	ground:SetHeight(100)
	ground:SetPoint(0, (UIParent.height-100))
	ground:SetImage("floor.png")
	ground:SetColor(30, 0, 150)
	ground:SetCollide(false)
	
end



function love.update(dt)
	if IsKeyDown("a")then
		bug.x = bug.x - dt *100
	end
	if IsKeyDown("d")then
		bug.x = bug.x + dt*100
	end
	
	local mx, my = love.mouse.getPosition()
	local ax, ay = bug.arm:GetPoint()
	

	local angle = math.atan2(my-ay, mx-ax)-1.5
	
	bug.arm:SetRotation(angle)

	for frame in pairs(FrameList) do
		if frame.vx and frame.vx ~= 0 then
			frame.x = frame.x + frame.vx*dt*10
		end
		if frame.vy then
			if frame.grounded then
				frame.vy = frame.vy
			else
				frame.vy = frame.vy + gravity
			end
			frame.y = frame.y + frame.vy*dt*10 
		end
	end
	
	for frame in pairs(FrameList) do
		if frame:CanCollide()then
			local left, right, top, bottom = frame.x, frame.x + frame:GetWidth()*frame:GetScale(), frame.y, frame.y + frame:GetHeight()*frame:GetScale()
			for altframe in pairs(FrameList) do
				if not (frame == altframe) then
					local altleft, altright, alttop, altbottom = altframe.x, altframe.x + altframe:GetWidth(), altframe.y, altframe.y + altframe:GetHeight()
					if bottom > alttop and bottom < altbottom and left > altleft and right < altright then
						frame:OnCollide(altframe)
					end
				end
			end	
		end
	end	
end




function love.draw() --what to draw each frame
	for layer, frames in pairs(DrawList) do
		for k, frame in pairs(frames) do
			local r,g,b,a = frame:GetColor()
			if r then
				love.graphics.setColor(r,g,b,a)
			end
			
			local x, y = frame:GetPoint()
			
			if frame.image then
				local sx =  (frame:GetWidth() / frame.imagew) * frame:GetScale()
				local sy =  (frame:GetHeight() / frame.imageh) * frame:GetScale()
				local rot = frame:GetRotation() or 0
				local ox, oy = frame:GetOrigin() 
				love.graphics.draw(frame.image, x, y, rot, sx, sy, ox or 0, oy or 0)
			end
			
			if r then
				love.graphics.setColor(255,255,255,255)
			end
		end		
	end
end


function love.keypressed(key)
	if key == "b" or key == " " then
		bug.vy = -40
		bug.grounded = false
	end
	
	if key == "r" then
		love.filesystem.load("main.lua")()
		love.load()
	end
	
end

function love.mousepressed()
local bul = CreateFrame("HIGH")
		bul:SetImage("bugarm.gif")
		bul:SetSize(20,20)
		local x, y = bug.arm:GetPoint()
		bul:SetPoint(bug.arm:GetPoint())
		
		local xv, yv
		xv = cos(bug.arm.rot+1.5)*10
		yv = sin(bug.arm.rot+1.5)*10
		bul:SetVelocity(xv, yv)
		bul.grounded = true
		
		bul:SetCollide(true)
		local t = function(self, collider)
			
		end
		bul:SetOnCollision(t)
		
end



