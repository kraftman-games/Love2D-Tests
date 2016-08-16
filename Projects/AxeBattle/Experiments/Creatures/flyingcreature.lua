
local tinsert = table.insert
local random = math.random
local creature = {}
setmetatable(creature,creature)
creature.__index = BaseCreature

local stance = {}
stance.aggressive = {}
stance.passive = {}
stance.defensive = {}


function creature:UpdateDecisions(dt)
	self.decisiontimer = self.decisiontimer + dt

	if self.decisiontimer > self.nextDecisionTime then
		self.decisiontimer = 0
		
		local x, y = self:GetPlayerRange()
		if math.abs(x - self.x) < self.playerRange and self.stance ~= stance.passive then
			print(self.stance, stance.aggressive)
			if self.stance == stance.aggressive then
				self:Attack(x,y)
			elseif self.stance == stance.defensive then
				self:Flee(x,y)
			end
		else
			self:MakePassiveDecision()
		end	
	end
end

function creature:MakePassiveDecision()
	self.passiveDecisions[random(#self.passiveDecisions)]()
	self.nextDecisionTime = random(0.5,0.7)
end

function creature:Attack(x,y)
	print("trying to attack")
	if x > self.x then
		self.ax = 600
	else
		self.ax = -600
	end
	self:StartJump()
	self.nextDecisionTime = random(0.5,1)
end

function creature:Flee(x,y)
	print("trying to flee")
	if x > self.x then
		self.ax = -600
	else
		self.ax = 600
	end
	self:StartJump()
	self.nextDecisionTime = random(0.5,1)
end

function CreateFlyingCreature(world, x, y)
	local cret = CreateBaseCreature(world,x,y)
	setmetatable(cret,cret)
	cret.__index = creature
	cret:SetPlayerRange(150)
	cret.canjump = false
	cret.canWalk = true
	cret.passiveDecisions = {}
	cret.stance = stance.aggressive
	tinsert(cret.passiveDecisions, function() cret.vy = -300 cret.ax = random(400,600) end)
	tinsert(cret.passiveDecisions, function() cret.vy = -300 cret.ax = random(-700, -400) end)

	return cret
end