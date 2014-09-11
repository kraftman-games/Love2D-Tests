
--[[
meta methods and index

objectinstance has metatable object
lookup misses go to object.__index

object.__index = parent object.

so to cover all methods
setmetatable(objectinstance, objectinstance) --tells it to lookup its own __index
objectinstance.__index = object

--]]
local types = {}

local tinsert = table.insert

--========= UIParent ========

UIParent = {}
UIParent.atrib = {}
UIParent.atrib.width = love.graphics.getWidth()
UIParent.atrib.height = love.graphics.getHeight()
UIParent.atrib.children = {}
UIParent.atrib.anchor = {}
UIParent.atrib.anchor["LEFT"] = {0,0}
UIParent.atrib.anchor["RIGHT"] = {UIParent.atrib.width, 0}
UIParent.atrib.anchor["TOP"] = {0, 0}
UIParent.atrib.anchor["BOTTOM"] = {UIParent.atrib.height, UIParent.atrib.height/2}


-- ======== UIOBJECT ===============

local UIObject = {}
UIObject.__index = UIObject
setmetatable(UIObject, UIObject)

function UIObject.Create()
	local temp = {}
	temp.__index = UIObject
	setmetatable(temp, temp)
	temp.atrib = {}
	temp.atrib.children = {}
	temp.atrib.shown = true
	temp.atrib.parent = UIParent
	
	return temp
end

function UIObject.GetParent(self)
	return self.atrib.parent
end

function UIObject.GetName(self)
	return self.atrib.name
end

function UIObject.GetObjectType(self)
	return self.atrib.type
end
function UIObject.IsObjectType(self, typ)
	if self.atrib.type == typ then
		return true
	else
		return false
	end
end

function UIObject.CheckPosition(self)
	
end

function UIObject.draw(self)
	if self.atrib.shown then
		UIObject:CheckPosition()
	
		for i, child in pairs(self.atrib.children) do
			child:draw()
		end
	end
end

function UIObject.KeyDown(self, key, uni)
	for i, child in pairs(self.atrib.children) do
		if self.atrib.keyboard then
			child.KeyDown(key, uni)
		end
	end
end

function UIObject.KeyUp(self, key, uni)
	for i, child in pairs(self.atrib.children) do
		if self.atrib.keyboard then
			child.KeyUp(key, uni)
		end
	end
end


-- ====== Region ==============
local Region = {}
Region.__index = UIObject
setmetatable(Region, Region)

function Region.Create(self)
	local temp = UIObject:Create()
	temp.__index = Region
	setmetatable(temp, temp)
	temp.atrib.anchor = {}
	return temp
end

function Region.ClearAllPoints(self)
self.atrib.anchor = {}

end

function Region.GetBottom(self)
	

end

function Region.GetCenter()

end

function Region.GetHeight()

end

function Region.GetLeft(atrib)
	
		
end

function Region.GetRight()

end

function Region.GetTop()

end

function Region.Hide(self)
	self.atrib.shown = false
end

function Region.IsDragging(self)
	return self.atrib.dragging
end

function Region.IsShown(self)
	return self.atrib.shown
end

function Region.IsVisible(self)
	if self.atrib.shown then
		if parent then
			if parent:IsVisible() then
				return true
			else
				return false
			end			
		else
			return true
		end
	else
	return false
	end
end

function Region.SetAllPoints(self, frame)
	self.atrib.anchor["TOP"] = {frame,"TOP", 0,0}
	self.atrib.anchor["BOTTOM"] = {frame,"BOTTOM", 0,0}
	self.atrib.anchor["LEFT"] = {frame,"LEFT", 0,0}
	self.atrib.anchor["RIGHT"] = {frame,"RIGHT", 0,0}
end

function Region.SetHeight(self, height)

end

function Region:SetPoint(self, point, relativobject, relativepoint,x,y)
	if point == "TOPLEFT" then
		self.atrib.anchor["LEFT"] = {relativeobject, relativepoint, x, 0}
		self.atrib.anchor["TOP"] = {relativeobject, relativepoint, 0, y}
	elseif point == "TOPRIGHT" then
		self.atrib.anchor["TOP"] = {relativeobject, relativepoint, 0,y}
		self.atrib.anchor["RIGHT"] = {relativeobject, relativepoint, x,0}
	elseif point == "BOTTOMLEFT" then
		self.atrib.anchor["BOTTOM"] = {relativeobject, relativepoint, 0,y}
		self.atrib.anchor["LEFT"] = {relativeobject, relativepoint, x,0}
	elseif point == "BOTTOMRIGHT" then
		self.atrib.anchor["BOTTOM"] = {relativeobject, relativepoint, 0,y}
		self.atrib.anchor["RIGHT"] = {relativeobject, relativepoint, x,0}
	else
		self.atrib.anchor[point] = {relativeobject, relativepoint, x, y}
	end
end

function Region:SetWidth(self, width)

end

function Region:Show(self)
	self.atrib.shown = true
end

--================= LayerRegion =======

local LayeredRegion = {}
LayeredRegion.__index = Region
setmetatable(LayeredRegion,LayeredRegion)

function LayeredRegion.Create(self)
	local temp = Region:Create()
		temp.__index = LayeredRegion
		setmetatable(temp, temp)
		temp.atrib.drawlayer = "BACKGROUND"
		
	return temp
end

function LayeredRegion.GetDrawLayer(self)

end

function LayeredRegion.SetDrawLayer(self)

end

function LayeredRegion.SetVertexColor(self)

end

--================ Texture =========

local Texture = {}
Texture.__index = LayeredRegion

function Texture.Create(self,name,layer,parent)
	local temp = LayeredRegion:Create()
		temp.atrib.texture = ""
		temp.atrib.texturepath = ""
		temp.atrib.type = "Texture"
		tinsert(parent.atrib.children, temp)
end

function Texture.GetBlendMode(self)

end

function Texture.GetTexCoord(self)

end

function Texture.GetTexture(self)

end

function Texture.GetVertexColor(self)

end

function Texture.IsDesaturated()

end

function Texture:SetBlendMode(self, mode)

end

function Texture:SetDesaturated(self)

end

function Texture:SetRotation(self, angle)

end

function Texture:SetTexCoord(self, a,b,c,d,e,f,g,h)

end

function Texture:SetTexture(self, path, g,b,a)
	if not b then
		self.atrib.texturepath = "solidcolor"
		self.atrib.texturecolor = {path,g,b,a}
		self.atrib.texture = love.graphics.rectangle
	--block colour
	else
		self.atrib.texturepath = path
		self.atrib.texture = love.graphics.newImage(path)
		--it shoudl have a path
	end
end

--================= frame ==============

local Frame = {}
Frame.__index = Region
setmetatable(Frame, Frame)

function Frame.CreateTexture(self, name, layer)
	local text = Texture:Create(name, layer, self)
	return text
end

function Frame.Create(self, name, parent)
	
	local temp = Region.Create()
	temp.__index = Frame
	
	setmetatable(temp, temp)
	
	if name then
		_G[name] = temp
	end
	temp.atrib.name = name
	temp.atrib.type = "Frame"
	if parent then
		temp.atrib.parent = parent
	end
	tinsert(parent.atrib.children, temp)
	return temp
end



function Frame.CreateFontString(self, name, layer, inheritsfrom)

end


function Frame.EnableDrawLayer(layer)

end

function Frame.DisableDrawLayer(layer)

end

function Frame.EnableKeyboard(self, flag)
	self.atrib.keyboard = flag
end

function Frame.EnableMouse(self, flag)
	self.atrib.mouse = flag
end

function Frame.EnableMouseWheel(self, flag)
	self.atrib.mousewheel = flag
end

function Frame.GetChildren(self)
	return unpack(self.atrib.children)
end

function Frame.GetFrameStrata(self)

end

function Frame.GetFrameType(self)
	return self.atrib.type
end

local Button = {}
Button.__index = Frame

local FontInstance = {}
FontInstance.__index = UIObject

function CreateFrame(typ, name, parent)
	local temp
	if typ == "Frame" then
		temp = Frame:Create(name, parent)
	end
	return temp
end
