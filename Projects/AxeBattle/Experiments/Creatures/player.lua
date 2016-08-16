

local tinsert, floor = table.insert, math.floor
local NewAxe = require 'axe'

local player = {}
player.__index = player

local lg = love.graphics


function player:MoveLeft(dt)
	self.vx = math.max(self.vx - dt*self.vacc, -self.vxmax)
end

function player:MoveRight(dt)
	self.vx = math.min(self.vx + dt*self.vacc, self.vxmax)
end

function player:Jump(dt)
	self.jumping = true
	if (self.jumpingFor < self.jumpFor) then
		self.jumpingFor = self.jumpingFor + dt

		self.vy = math.max(self.vy - dt*self.vyacc, -self.vymax)
	end
end


function player:Update(dt)

	if love.keyboard.isDown('a') then
		self:MoveLeft(dt)
		self.facing = 'left'
	end

	if love.keyboard.isDown('d') then
		self:MoveRight(dt)
		self.facing = 'right'
	end

	if love.keyboard.isDown(' ') then
		self:Jump(dt)
	end

	if love.keyboard.isDown('w') then
		self.facing = 'up'
	end

	if love.keyboard.isDown('s') then
		self.facing = 'down'
	end
	

	self:CheckXCollisions(dt)
	self:CheckYCollisions(dt)


	self.vx  = self.vx*0.7 -- damping
	self.vy = self.vy + dt*self.gravity

	if not self.axe:IsDead() then
		self.axe:Update(dt)
	end
end

function player:CheckXCollisions(dt)
	local newX = self.x + self.vx*dt
	if self.vx > 0 then
		if self.world:Collides(newX+self.width, self.y) or self.world:Collides(newX+self.width, self.y+self.height) then
			self.vx = 0 --(self.vx*-1)
			self.x = self.x  + self.vx*dt
		else
			self.x = newX
		end
	elseif self.vx <= 0 then
		if self.world:Collides(newX, self.y) or self.world:Collides(newX, self.y+self.height) then
			self.vx = self.vx*-1
			self.x = self.x  + self.vx*dt
		else
			self.x = newX
		end
	end

end

function player:CheckYCollisions(dt)
	local newY = self.y + self.vy*dt

	if self.vy < 0 then
		if self.world:Collides(self.x, newY) or self.world:Collides(self.x+self.width, newY) then
			self.vy = (self.vy*-1)*0.1
			self.y = self.y  + self.vx*dt
		else
			self.y = newY
		end
	else
		if self.world:Collides(self.x, newY+self.height) or self.world:Collides(self.x+self.width, newY+self.height) then
			self.vy = 0
			if self.startJump == false then
				self.jumping = false
				self.jumpingFor = 0
				self.jumpCount = 0
			end
		else
			self.y = newY
		end
	end
end

function player:Fire()
	if self.axe:IsDead() then
		self.axe:Fire()
	end
end

function player:KeyPressed(key)
	if key == ' ' then
		if self.jumpCount < 2 then
			self.startJump = true
			self.jumpCount = self.jumpCount + 1
			self.jumpingFor = 0
			self.vy = -200
		end
	end

	if key == 'e' then
		self:Fire()
	end
end

function player:KeyReleased(key)
	if key == ' ' then
		self.startJump = false
	end
end


function player:GetX()
	return floor(self.x+0.5)
end

function player:GetY()
	return floor(self.y+0.5)
end

function player:Draw()
	lg.rectangle('fill', self:GetX(), self:GetY(), self.height, self.height)
	if not self.axe:IsDead() then
		self.axe:Draw()
	end
end

function NewPlayer(world)
	local p = setmetatable({}, player)
	p.world = world
	p.x = 200
	p.y = 200
	p.vx = 0
	p.vy = 0
	p.vxmax = 3000
	p.vymax = 3000
	p.vacc = 2000
	p.vyacc = 2000
	p.width = 10
	p.height = 10
	p.height = 10
	p.jumpFor = 0.2
	p.jumpCount = 0
	p.jumpingFor = 0
	p.gravity = 1400
	p.facing = 'right'
	p.axe = NewAxe(p)

	return p
end	

return NewPlayer
