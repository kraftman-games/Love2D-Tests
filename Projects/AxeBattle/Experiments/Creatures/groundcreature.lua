
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
	self.nextDecisionTime = random(2,4)
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

function CreateNewAggresiveJumper(world, x, y)
	local cret = CreateBaseCreature(world,x,y)
	setmetatable(cret,cret)
	cret.__index = creature
	cret:SetPlayerRange(150)
	cret.canjump = true
	cret.canWalk = false
	cret.passiveDecisions = {}
	cret.stance = stance.aggressive
	local rand = math.random
	cret.color = {rand(255),rand(255),rand(255),255}
	tinsert(cret.passiveDecisions, function() cret.ax = -800 cret:StartJump()  end)
	tinsert(cret.passiveDecisions, function() cret.ax = 800 cret:StartJump()  end)
	tinsert(cret.passiveDecisions, function() cret.ax = 0  end)

	return cret
end

function CreateNewAggresiveWalker(world, x, y)
	local cret = CreateBaseCreature(world,x,y)
	setmetatable(cret,cret)
	cret.__index = creature
	cret:SetPlayerRange(150)
	cret.canjump = true
	cret.canWalk = true
	cret.jumpSpeed = -50
	cret.passiveDecisions = {}
	cret.stance = stance.aggressive
	tinsert(cret.passiveDecisions, function() cret.ax = -300 cret:StartJump()  end)
	tinsert(cret.passiveDecisions, function() cret.ax = 300 cret:StartJump()  end)
	tinsert(cret.passiveDecisions, function() cret.ax = 0  end)

	return cret
end



function CreateNewScaredJumper(world, x, y)
	local cret = CreateBaseCreature(world,x,y)
	setmetatable(cret,cret)
	cret.__index = creature
	cret:SetPlayerRange(150)
	cret.canjump = true
	cret.canWalk = false
	cret.passiveDecisions = {}
	local rand = math.random
	cret.color = {rand(255),rand(255),rand(255),255}
	cret.stance = stance.defensive
	tinsert(cret.passiveDecisions, function() cret.ax = -800 cret:StartJump()  end)
	tinsert(cret.passiveDecisions, function() cret.ax = 800 cret:StartJump()  end)
	tinsert(cret.passiveDecisions, function() cret.ax = 0  end)

	return cret
end

function CreateNewScaredWalker(world, x, y)
	local cret = CreateBaseCreature(world,x,y)
	setmetatable(cret,cret)
	cret.__index = creature
	cret:SetPlayerRange(150)
	cret.canjump = true
	cret.canWalk = true
	cret.jumpSpeed = -50
	cret.passiveDecisions = {}
	cret.stance = stance.defensive
	tinsert(cret.passiveDecisions, function() cret.ax = -300 cret:StartJump()  end)
	tinsert(cret.passiveDecisions, function() cret.ax = 300 cret:StartJump()  end)
	tinsert(cret.passiveDecisions, function() cret.ax = 0  end)

	return cret
end