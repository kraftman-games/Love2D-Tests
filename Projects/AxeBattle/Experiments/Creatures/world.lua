
local lg = love.graphics
local floor = math.floor
-- basic world for testing collision


local world = {}
world.buckets = {}

world.size = 20
world.bucketsize = 20
world.buckets = {}


function world:GetBucket(i,j)
	return self.buckets[i] and self.buckets[i][j]
end

function world:CreateBucket(i,j)
	self.buckets[i] = self.buckets[i] or {}
	self.buckets[i][j] = self.buckets[i][j] or {}

	return self.buckets[i][j]
end


function world:MousePressed(x,y,button)
	x = floor(x/self.bucketsize)
	y = floor(y/self.bucketsize)
	local bucket = self:GetBucket(x,y) or self:CreateBucket(x,y)
	
	bucket.enabled = not bucket.enabled
	
end


function world:Update(dt)


end

function world:Collides(x,y)
	x = floor(x/self.bucketsize)
	y = floor(y/self.bucketsize)
	return self:GetBucket(x,y) and self:GetBucket(x,y).enabled
end

function world:Initialise()
	local bucket
	for i = 1,self.size do
		for j = 1, self.size do
			if (i == 1 or i == self.size) or (j == 1 or j == self.size) then
				bucket = self:CreateBucket(i,j)
				bucket.enabled = true
			end
		end
	end

end

function world:Draw()
	love.graphics.setColor(255,255,255,255)
	for i = 1,self.size do
		for j = 1,self.size do
			if self:GetBucket(i,j) and self:GetBucket(i,j).enabled then
				lg.rectangle("fill",i*self.size,j*self.size, self.bucketsize-2, self.bucketsize-2)
			end
		end
	end
end

world:Initialise()

return world