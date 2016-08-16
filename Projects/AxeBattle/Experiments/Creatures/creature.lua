
local lg = love.graphics
local lt = love.timer
local tinsert = table.insert
local random = math.random


BaseCreature = {}

BaseCreature.__index = BaseCreature

function BaseCreature:GetNewX(dt)

	local x = self.x + self.vx*dt

	if self:CanWalk() == false and not self.jumping then
		x = self.x
	end

	if self:CollidesWithWorld(x, self.y) then
		self.vx = -(self.vx*0.2)
		--self.ax = 0
		x = self.x + self.vx*dt
		if not self.jumping then
			self.vy = 0
			self:StartJump()
		end
	end
	return x
end

function BaseCreature:GetNewY(dt)
	-- update gravity
	self.vy = self.vy + dt*self.gravitySpeed
	

	local y = self.y + self.vy*dt
	if self:CollidesWithWorld(self.x, y) then
		if self.vy >= 0 then
			self.isOnFloor = true
			self.vy = 0
			self.jumping = false
			--need to work out the actual distance to the tile eventually
		else
			self.vy = -(self.vy*0.1)
		end

		self.ay = 0

		if math.abs(self.vy) < 20 then
			self.vy = 0
		end

		y = self.y + self.vy*dt
	
	end

	if self.vy < 0 then
		self.isOnFloor = false
	end

	return y
end

function BaseCreature:UpdateJump(dt)
	if self.jumping and self.jumptime < 0.3 then
		self.vy = self.jumpSpeed
		self.jumptime = self.jumptime + dt
	end
end

function BaseCreature:UpdateVelocities(dt)
	
	self.vx = self.vx*0.9 + self.ax*dt
end



function BaseCreature:GetPlayerRange()
	-- change this to the player later
	return love.mouse.getPosition()
end

function BaseCreature:Update(dt)

	self:UpdateVelocities(dt)

	self:UpdateJump(dt)

	self.x, self.y = self:GetNewX(dt), self:GetNewY(dt)

	self:UpdateDecisions(dt)

end

function BaseCreature:OnFloor()
	return self.isOnFloor
end

function BaseCreature:StartJump()
	if self:CanJump() and self:OnFloor() and (not self.jumping) then
		
		self.jumping = true
		self.jumptime = 0
	end
end

function BaseCreature:CanJump()
	return self.canjump
end

function BaseCreature:CanWalk()
	return self.canWalk
end


function BaseCreature:MoveLeft()
	self.vx = 0
	self.ax = -1000
end

function BaseCreature:MoveRight()
	self.vx = 0
	self.ax = 1000
end

function BaseCreature:SetPlayerRange(range)
	self.playerRange = range
end

function BaseCreature:CollidesWithWorld(x,y)
	for i = x, x+self.size do
		for j = y, y+self.size do
			if self.world:Collides(i,j) then
				return true
			end
		end
	end
end

function BaseCreature:Draw()
	local x, y = self:GetPlayerRange()
	love.graphics.setColor(unpack(self.color))
		
	if math.abs(x - self.x) < self.playerRange then
		lg.print("in range", 20, 320)
	end
	lg.rectangle("fill", self.x, self.y, self.size, self.size)
	lg.print(self.isOnFloor and "on floor "..self.vy or "in air"..self.vy , 20 ,300)
end


function BaseCreature:HasGravity()
	return self.hasgravity
end

function CreateBaseCreature(world,x,y)
	local cret = setmetatable({}, BaseCreature)
	cret.world = world
	cret.x = x
	cret.y = y
	cret.vx = 0
	cret.vy = 0
	cret.vxmax = 100
	cret.hasgravity = true
	cret.size = 10
	cret.jumptime = 0
	cret.ax = 0
	cret.jumpSpeed = -150
	cret.decisiontimer = 0
	cret.nextDecisionTime = 1
	cret.playerRange = 0
	cret.gravitySpeed = 1000
	

	return cret
end