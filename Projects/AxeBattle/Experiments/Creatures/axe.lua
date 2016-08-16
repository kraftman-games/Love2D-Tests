
local axe = {}
axe.__index = axe

local lg = love.graphics

function axe:Update(dt)
	self.x = self.x + dt*self.vx
	self.y = self.y + dt*self.vy

	self.vx = self.vx + self.ax*dt
	self.vy = self.vy + self.ay*dt
	self.aliveTime = self.aliveTime + dt
	if self.aliveTime > 2 then
		self.dead = true
		self.aliveTime = 0
	end
end

function axe:Draw()
	lg.rectangle('fill', self.x, self.y, self.width, self.height)
end

function axe:Fire()
	self.x = self.player.x
	self.y = self.player.y
	self.dead = false

	self.vx = 0
	self.vy = 0
	self.ax = 0
	self.ay = 0

	if self.player.facing == 'right' then
		self.vx = 1000
		self.ax = -1000
	elseif self.player.facing =='left' then
		self.vx = -1000
		self.ax = 1000
	elseif self.player.facing == 'up' then
		self.vy = -1000
		self.ay = 1000
	elseif self.player.facing == 'down' then
		self.vy = 1000
		self.ay = -1000
	end
end

function axe:IsDead()
	return self.dead
end

function NewAxe(player)
	local self = setmetatable({}, axe)

	self.x = player.x
	self.y = player.y
	self.vx = 0
	self.vy = 0
	self.ax = 0
	self.ay = 0
	self.width = 5
	self.height = 5
	self.speed = 100
	self.player = player
	self.dead = true
	self.aliveTime = 0
	self.direction = player.facing

	

	return self
end


return NewAxe