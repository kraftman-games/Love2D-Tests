--[[
need some strata

some frame levels
BACKGROUND
LOW
MEDIUM
HIGH
TOOLTIP



--]]
tinsert = table.insert
tremove = table.remove
sin = math.sin
cos = math.cos
deg = math.deg

IsKeyDown = love.keyboard.isDown


function CreateFrame(strata, parent)
	local frame = {}
	
	if parent then
		frame.parent = parent
	end
	
	
	function frame.SetWidth(self, width)
		if type(width) == "number" then
			self.width = width
		end
	end
	
	function frame.GetWidth(self)
		return self.width or nil
	end
	
	
	function frame.SetHeight(self, height)
		if type(height) == "number" then
			self.height = height
		end
	end
	
	function frame.GetHeight(self)
		return self.height or nil
	end
	
	function frame.SetSize(self, width, height)
		self:SetWidth(width)
		self:SetHeight(height)
	end
	function frame.SetPoint(self, x, y)
		if type(x) == "number" and type(y) == "number" then
			if frame:GetScale() then
				self.x = x*frame:GetScale()
				self.y = y*frame:GetScale()
			else
				self.x = x
				self.y = y
			end
		end	
	end
	
	function frame.GetPoint(self)
		if self.x and self.y then
			if self.parent and parent:GetPoint() then
				local x, y = parent:GetPoint()
				x, y = self.x + x, self.y + y
				return x, y
			else
				return self.x, self.y
			end
		else
			return nil
		end	
	end
	
	function frame.SetCollide(self, bool)
		frame.collides = bool
	
	end
	
	function frame.CanCollide(self)
		return frame.collides	
	end
	
	function frame.SetOnCollision(self, func)
		frame.OnCollide = func
	
	end
	
	function frame.OnCollision(self, collider)
		frame.OnCollide(self, collider)
	end
	
	function frame.SetVelocity(self, x, y)
		if type(x) == "number" and type(y) == "number" then
			self.vx = x
			self.vy = y		
		end
	end
	
	function frame.GetVelocity(self)
		if self.vx and self.vy then
			return self.vx, self.vy
		else
			return nil
		end
	end
	
	function frame.SetImage(self, file)
		self.image = love.graphics.newImage(file)
		self.imageh = self.image:getHeight()
		self.imagew = self.image:getWidth()
	end
	
	function frame.SetColor(self, r, g, b, a)
		self.r = r
		self.g = b
		self.b = b
		self.a = a
	end
	
	function frame.ClampedToScreen(bool)
		frame.clamped = bool
	end
	
	function frame.SetRotation(self, rotation)
		if type(rotation) == "number" then
			frame.rot = rotation
		end
	end
	
	function frame.GetRotation(self)
		if frame.rot then
			return frame.rot
		else
			return nil
		end
	end
	
	function frame.SetOrigin(self, x, y)
		self.originx = x
		self.originy = y
		
	end
	
	function frame.GetOrigin(self)
		return self.originx, self.originy
	end
	
	function frame.SetScale(self, scale)
		frame.scale = scale
	end
	
	function frame.GetScale(self)
		if self.parent then
		 return self.parent:GetScale() * (self.scale or 1)
		else 
			return self.scale or 1
		end
	end

	function frame.GetColor(self)
		if self.r and self.g and self.b then
			if self.a then
				return self.r, self.g, self.b, self.a
			else
				return self.r, self.g, self.b, 255
			end
		end
	end
	if strata then
		frame.strata = ConvertStrata[strata]
		tinsert(DrawList[frame.strata], frame)
	else
		frame.strata = 1 --set to background by default
		tinsert(DrawList[frame.strata], frame)
	end
	FrameList[frame] = frame
	return frame
end

