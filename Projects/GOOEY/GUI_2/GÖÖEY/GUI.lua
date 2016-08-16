-- ===============================================
--			LOCALS

local tinsert = table.insert
local tremove = table.remove
local min = math.min
local max = math.max 
local strlower = string.lower
local strupper = string.upper
love.graphics.newCanvas = love.graphics.newCanvas or love.graphics.newFrameBuffer

local valid = { top = true,
				left = true,
				right = true,
				bottom = true,
				topleft = true,
				topright = true,
				bottomleft = true,
				bottomright = true,
				center = true}


--=============================================

--[[


mouse enabled:
all mouse enabled frames need to be in a table that gets parsed

clicking on a frame raises it to the top of the strata

"BACKGROUND"
"LOW"
"MEDIUM"
"HIGH"
"DIALOG"
"FULLSCREEN"
"FULLSCREEN_DIALOG"
"TOOLTIP"


child:getlevel = parent:getlevel + 1

clicking on a frame: raise the frame level (which raises child levels)


]]


local Strata = {BACKGROUND = 1,
				LOW = 2,
				MEDIUM = 3,
				HIGH = 4,
				DIALOG = 5,
				FULLSCREEN = 6,
				FULLSCREEN_DIALOG = 7,
				TOOLTIP = 8}

local Layers = {BACKGROUND = 1,
				BORDER  =2,
				ARTWORK = 3,
				OVERLAY = 4,
				HIGHLIGHT = 5}

UIParent = {}
UIParent.__VARS = {}

UIParent.Frames = {} --flat list of all frames

UIParent.Strings = {}

UIParent.Scripts = {}
UIParent.Scripts.OnKeyDown = {}
UIParent.Scripts.OnMouseDown = {}
UIParent.Scripts.OnEnter = {}
UIParent.Scripts.OnLeave = {}
UIParent.Scripts.OnMouseUp = {}
UIParent.Scripts.OnUpdate = {}

UIParent.children = {}

UIParent.__LAYERS = {}
UIParent.__LAYERS[1] = {} -- BACKGROUND
UIParent.__LAYERS[2] = {} -- LOW
UIParent.__LAYERS[3] = {} -- MEDIUM
UIParent.__LAYERS[4] = {} -- HIGH
UIParent.__LAYERS[5] = {} -- DIALOG
UIParent.__LAYERS[6] = {} -- FULLSCREEN
UIParent.__LAYERS[7] = {} -- FULLSCREEN_DIALOG
UIParent.__LAYERS[8] = {} -- TOOLTIP

UIParent.__VARS.children = {}
local mx, my
function UIParent:update(dt)
	for f, func in pairs(self.Scripts.OnUpdate) do
		func(f, dt)
	end

	mx, my = love.mouse.getPosition()
	local found
	for i = #self.__LAYERS,1,-1 do
		for j = #self.__LAYERS[i],1,-1 do
			if self.__LAYERS[i][j]:CheckMouse(mx,my) then
				found = true
				break
			end
		end
	end

	if not found then
		for i = 1, #self.Frames do
			if self.Frames[i].__VARS.mouseover then
				self.Frames[i].__VARS.mouseover = nil
				if self.Frames[i].__SCRIPTS.OnLeave then
					self.Frames[i].__SCRIPTS.OnLeave(self.Frames[i])
				end
			end
		end
	end


	for _,child in pairs(self.Frames) do
		
		if child.__VARS.moving then
			child.__VARS.left = mx - child.__VARS.xoff
			child.__VARS.right = my - child.__VARS.yoff
			child:SetPoint("TOPLEFT", UIParent, "TOPLEFT", child.__VARS.left, child.__VARS.right)
			child:ReCalcPosition()
		end
	end
end

function UIParent:draw()
	--[[ FB STUFF
	for i = 1, #self.__VARS.children do
		if self.__VARS.children[i].changed then
			local left, right, top, bottom = unpack(self:GetCanvasSize({0,0,0,0}))
			self.__VARS.fb = love.graphics.newCanvas(right-left, top-bottom)
			love.graphics.push()
			love.graphics.translate(left, top)
				self:draw()
			love.graphics.pop()
		end
		self.__VARS.children[i].changed = nil
	end
	]]
	for i = 1, #self.__LAYERS do
		for j = 1, #self.__LAYERS[i] do
			if self.__LAYERS[i][j].__VARS.isshown then
				self.__LAYERS[i][j]:Draw()
			end
		end
	end
end

function UIParent:mousepressed(x,y,button)
	for i = #UIParent.__LAYERS, 1, -1 do
		for j = #UIParent.__LAYERS[i],1,-1 do
			if UIParent.__LAYERS[i][j]:MouseDown(x,y,button,j) then
				return
			end
		end
	end
end

function UIParent:mousereleased(x,y,button)
	for i = #UIParent.__LAYERS, 1, -1 do
		for j = #UIParent.__LAYERS[i],1,-1 do
			UIParent.__LAYERS[i][j]:MouseUp(x,y,button,j)
		end
	end
end

function UIParent:keypressed(key,uni)


end

function UIParent:keyreleased(key,uni)

end

function UIParent:GetWidth()
	return self.__VARS.width
end

function UIParent:GetHeight()
	return self.__VARS.height
end

function UIParent:GetX()
	return self.__VARS.x
end

function UIParent:GetY()
	return self.__VARS.y
end

function UIParent:GetLeft()
	return 0
end

function UIParent:GetTop()
	return 0 
end

function UIParent:GetRight()
	return love.graphics.getWidth()
end

function UIParent:GetBottom()
	return love.graphics.getHeight()
end

function UIParent:GetRot()
	return self.__VARS.rot
end

function UIParent:GetPoint()
	return self.__VARS.x, self.__VARS.y
end

function UIParent:SetPoint(x,y)
	
end

function UIParent:IsVisible()
	return true
end

function UIParent:SetScale(x,y)
	self.__VARS.scalex = x
	self.__VARS.scaley = y
end

function UIParent:GetScale()
	return self.__VARS.scalex, self.__VARS.scaley
end

function UIParent:SetScaleX(x)
	self.__VARS.scalex = x
end

function UIParent:GetScaleX()
	return self.__VARS.scalex
end

function UIParent:SetScaleY(y)
	self.__VARS.scaley = y
end

function UIParent:GetScaleY()
	return self.__VARS.scaley
end

UIParent.__VARS.width = love.graphics.getWidth()
UIParent.__VARS.height = love.graphics.getHeight()
UIParent.__VARS.x = 0
UIParent.__VARS.y = 0
UIParent.__VARS.rot = 0
UIParent.__VARS.scalex = 1
UIParent.__VARS.scaley = 1
UIParent.__VARS.childanch = {}


--=====================================================================
--=====================================================================
--=====================================================================
--=====================================================================
--=====================================================================
--=====================================================================
--=====================================================================
--=====================================================================
--=====================================================================
--=====================================================================
--=====================================================================

local tinsert = table.insert

local UIObject = {} --basic methods common to all objects

UIObject.__index = UIObject


function UIObject:Create(parent,name)
	local temp = {}
	temp.__index = UIObject
	setmetatable(temp, temp)
	temp.__VARS = {}
	temp.__VARS.x = 0
	temp.__VARS.y = 0
	temp.__VARS.rot = 0
	temp.__VARS.width = 0
	temp.__VARS.height = 0
	temp.__VARS.minheight = 0
	temp.__VARS.minwidth = 0
	temp.__VARS.children = {}
	temp.__VARS.parent = parent
	temp.__VARS.shown = true
	temp.__VARS.isshown = true
	temp.__VARS.scalex = 1
	temp.__VARS.scaley = 1
	temp.__VARS.anchors = {} -- this objects anchors
	temp.__VARS.childanch = {} -- objects anchored to this object


	temp.__LAYERS = {}
	temp.__LAYERS[1] = {} -- BACKGROUND
	temp.__LAYERS[2] = {} -- BORDER
	temp.__LAYERS[3] = {} -- ARTWORK
	temp.__LAYERS[4] = {} -- OVERLAY
	temp.__LAYERS[5] = {} -- HIGHLIGHT
	
	if tostring(name) then
		_G[tostring(name)] = temp
	end

	tinsert(UIParent.Frames, temp)
	tinsert(parent.__VARS.children, temp)
	
	return temp
end


function UIObject:ReDraw()
	if self.__VARS.parent == UIParent then
		--[[
			make a new framebuffer
			draw all anchored objects
			and child anchored objects

		]]
	else
		self.__VARS.parent:ReDraw()
	end
end


local testcoords = {left = {"topleft", "bottomleft", "left"},
					right = {"topright", "bottomright", "right" },
					top = {"top", "topleft", "topright"},
					bottom = {"bottomright", "bottom", "bottomleft"},
					}

local function GetAnchor(anch,dir, rev)
	for i = 1, #testcoords[dir] do
		local a = anch[testcoords[dir][i]]
		if a then
			if rev then
				if a[2] == "top" or a[2] == "topleft" or a[2] == "topright" then
					return a[1]:GetTop() + a[4]
				elseif a[2] == "left" or a[2] == "right" or a[2] == "center" then 
					return a[1]:GetTop() + a[1]:GetHeight()/2 + a[4]
				elseif a[2] == "bottomright" or a[2] == "bottom" or a[2] == "bottomleft" then
					return a[1]:GetBottom() + a[4]
				end
			else
				if a[2] == "topleft" or a[2] == "left" or a[2] == "bottomleft" then
					if a[1]:GetLeft() then
						return a[1]:GetLeft() + a[3]
					end
				elseif a[2] == "top" or a[2] == "bottom" or a[2] == "center" then
						return a[1]:GetLeft() + a[1]:GetWidth()/2 + a[3]
				elseif a[2] == "topright" or a[2] == "right" or a[2] == "bottomright" then
					if a[1]:GetRight() then
						return a[1]:GetRight() + a[3]
					end
				end
			end
		end
	end
end

function UIObject:ReCalcPosition()
	
	--[[
		this function needs a rewrite to better handler anchor/size precedence
	--]]

	local a = self.__VARS.anchors

	
	self.__VARS.left = GetAnchor(self.__VARS.anchors, "left") 

	self.__VARS.right = GetAnchor(self.__VARS.anchors, "right") 

	self.__VARS.top = GetAnchor(self.__VARS.anchors,"top", true) 
	self.__VARS.bottom = GetAnchor(self.__VARS.anchors,"bottom", true)

	self:SetWidth(self.__VARS.left and self.__VARS.right and (self.__VARS.right-self.__VARS.left) or self.__VARS.width or 0)

	self:SetHeight (math.max( (self.__VARS.top and self.__VARS.bottom and (self.__VARS.bottom-self.__VARS.top) or self.__VARS.height or 0), self.__VARS.minheight))
	

	--work out the new position of all things anchored to this object
	for obj in pairs(self.__VARS.childanch) do
		obj:ReCalcPosition()
	end


end

function UIObject:GetCanvasSize(coords)
	
	coords[1] = math.min(coords[1], self:GetLeft())
	coords[2] = math.max(coords[1], self:GetRight())
	coords[3] = math.min(coords[1], self:GetTop())
	coords[4] = math.max(coords[1], self:GetBottom())

	for i = 1, self.__VARS.children do
		self.__VARS.children[i]:GetCanvasSize(coords)
	end
end


function UIObject:SetScale(x,y)
	if not y then
		y = x
	end
	
	self.__VARS.scalex = x
	self.__VARS.scaley = y
	self:ReCalcPosition()
	self:ReDraw()
end

function UIObject:GetScale()
	return self.__VARS.scalex, self.__VARS.scaley
end

function UIObject:SetMinWidth(w)
	self.__VARS.minwidth = w
	self:ReCalcPosition()
	self:ReDraw()
end

function UIObject:SetMinHeight(h)
	self.__VARS.minheight = h
	self:ReCalcPosition()
	self:ReDraw()
end

function UIObject:GetPoint()
	return self.__VARS.x, self.__VARS.y
end

function UIObject:SetScaleX(x)
	self.__VARS.scalex = x

	self:ReCalcPosition()
	self:ReDraw()
end

function UIObject:IsVisible()
	return self.__VARS.parent:IsVisible() and self.__VARS.isshown
end

function UIObject:GetScaleX()
	return self.__VARS.scalex * self.__VARS.parent:GetScaleX()
end

function UIObject:SetScaleY(self,y)
	
	self.scaley = y
	self:ReCalcPosition()
	self:ReDraw()
end

function UIObject:SetParent(self, parent)
	for i = 1, #self.__VARS.parent.children do
		if self.__VARS.parent.children[i] == self then
			tremove(self.__VARS.parent.children, i)
		end
	end
	tinsert(parent.__VARS.children, self)
	self.__VARS.parent = parent
	self:ReCalcPosition()
	self:ReDraw()
end

function UIObject:GetScaleY()
	return self.__VARS.scaley * self.__VARS.parent:GetScaleY()
end

function UIObject:SetWidth( width)
	self.__VARS.width = math.max(width, self.__VARS.minwidth)

end

function UIObject:SetHeight(height)
	self.__VARS.height = math.max(height, self.__VARS.minheight)

end


function UIObject:SetSize(x,y)
	self.__VARS.width = math.max(x, self.__VARS.minwidth)
	self.__VARS.height = math.max(y, self.__VARS.minheight)
end


function UIObject:GetLeft()
	return self.__VARS.left or self.__VARS.right and (self.__VARS.right - self:GetWidth()) or nil
end



function UIObject:GetRight()
	return self.__VARS.right or self.__VARS.left and self.__VARS.left+ self:GetWidth() or nil
end


function UIObject:GetTop()
	return self.__VARS.top or self.__VARS.bottom - self:GetHeight()
end


function UIObject:GetBottom()
	return self.__VARS.bottom or self.__VARS.top + self:GetHeight()
end

function UIObject:GetCenter()
	--dodgy? needs a think
	return (self:GetLeft() + self:GetRight())/2, (self:GetTop() + self:GetBottom())/2
end


function UIObject:GetWidth()
	return math.max((self.__VARS.width or self:GetRight() - self:GetLeft() or 0),self.__VARS.minwidth)
end
function UIObject:GetHeight()
	return math.max((self.__VARS.height  or self:GetBottom() - self:GetTop() or 0),self.__VARS.minheight)
end

function UIObject:GetRot()
	return self.__VARS.rot + self.__VARS.parent:GetRot()
end

function UIObject:SetRot(rot)
	 self__VARS.rot = rot
end

function UIObject:SetPoint(point, rframe, rpoint, ofx, ofy)
	
	if rframe == self then
		error("Attempt to anchor to self")
	end

	ofx = ofx or 0
	ofy = ofy or 0
	
	point = strlower(point)
	rpoint = rpoint and strlower(rpoint) or point
	rframe = (type(rframe) == "table")  and rframe or rframe or  _G[rframe] or self.__VARS.parent
	
	
	if not valid[point] then
		error("Incorrect syntax: SetPoint(point, relativeFrame, relativePoint, offsetx, offsety")
	end
	
	if self.__VARS.anchors[point] then
		self.__VARS.anchors[point][1].__VARS.childanch[self] = nil
	end
	 
	self.__VARS.anchors[point] = {rframe, rpoint, ofx or 0 , ofy or 0}
	rframe.__VARS.childanch[self] = self

	self:ReCalcPosition()
	self:ReDraw()
end

function UIObject:SetAllPoints(f)
	for point in pairs(valid) do
		if self.__VARS.anchors[point] then
			self.__VARS.anchors[point][1].__VARS.childanch[self] = nil
		end

		self.__VARS.anchors[point] = {f, point, 0,0}
		f.__VARS.childanch[self] = self
	end

	self:ReCalcPosition()
	self:ReDraw()
end

function UIObject:ClearAllPoints()
	self.__VARS.anchors = {}
	--self:ReCalcPosition()
	--self:ReDraw()
end

function UIObject:Show()
	self.__VARS.isshown = true
end

function UIObject:Hide()
	self.__VARS.isshown = nil
end

--======================================================================================
--======================================================================================
--======================================================================================
--======================================================================================
--======================================================================================
--======================================================================================
--======================================================================================
--======================================================================================

local Texture = {}
Texture.__index = UIObject
setmetatable(Texture, Texture)

function Texture:Create(parent, name, layer, inherits)

	local temp = UIObject:Create(parent,name)
		temp.__index = Texture
		setmetatable(temp, temp)
		temp.__VARS.layer = 2
		tinsert(parent.__LAYERS[2], temp)
		return temp
end

function Texture:SetTexture(path,g,b,a) -- textures stored as quads to handle settexcoords
	if type(path) == "number" then
		self.__VARS.block = true
		self.__VARS.color = {path,g,b,a}
	else
		self.__VARS.image = love.graphics.newImage(path)
		self.__VARS.basewidth = self.__VARS.image:getWidth()
		self.__VARS.baseheight = self.__VARS.image:getHeight()
		self.__VARS.quadheight = 1
		self.__VARS.quadwidth = 1
		self.__VARS.quad = love.graphics.newQuad(0,0,self.__VARS.basewidth,self.__VARS.baseheight,self.__VARS.basewidth,self.__VARS.baseheight)
		self:SetTexCoord(0,1,0,1)
	end
end

function Texture:SetTexCoord(left, right, top, bottom)
	
		self.__VARS.quadcoords = {left, right, top, bottom}
		left = self.__VARS.basewidth*left
		right = self.__VARS.basewidth*right
		top = self.__VARS.baseheight*top
		bottom = self.__VARS.baseheight*bottom
		local width = right - left
		local height = bottom-top
		self.__VARS.quadheight = height
		self.__VARS.quadwidth = width
		self.__VARS.quad = love.graphics.newQuad(left, top, width, height, self.__VARS.basewidth, self.__VARS.baseheight)
	
	
end

function Texture:SetColor(color)
	self.__VARS.color = color
end

function Texture:Draw()
	if self.__VARS.block then
		local oldcolor = {love.graphics.getColor()}
		love.graphics.setColor(self.__VARS.color)
		love.graphics.rectangle("fill", self:GetLeft(), self:GetTop(), self:GetWidth(), self:GetHeight())
		love.graphics.setColor(oldcolor)

	else
		if self.__VARS.color then
				love.graphics.setColorMode("modulate")
				love.graphics.setColor(unpack(self.__VARS.color))
		else
			love.graphics.setColorMode("replace")
			love.graphics.setColor(255,255,255,255)
		end
	
		love.graphics.drawq(self.__VARS.image, self.__VARS.quad, self:GetLeft(), self:GetTop(), self:GetRot(), (self.__VARS.width/self.__VARS.quadwidth),(self.__VARS.height/self.__VARS.quadheight))
		love.graphics.setColorMode("modulate")
		love.graphics.setColor(255,255,255,255)
	end
end



--======================================================================================
--======================================================================================
--======================================================================================
--======================================================================================
--======================================================================================

local Frame = {} --frame objects can handle mouse and keyboard events
Frame.__index = UIObject
setmetatable(Frame, Frame)

function Frame:Create(parent,name)
	local temp = UIObject:Create(parent,name)
		temp.__index = Frame
		setmetatable(temp, temp)
	
		temp.__SCRIPTS = {}
		temp.__VARS.mouseEnabled = true -- REMOVE
		temp.__VARS.layer = 1
		tinsert(parent.__LAYERS[1], temp)
		
		return temp
end

function Frame:CreateTexture(...)
	return Texture:Create(self,...)
end

function Frame:StartSizing()
	local mx, my = love.mouse.getPosition()
	self.__VARS.xoff = mx - self:GetRight()
	self.__VARS.yoff = my - self:GetBottom()
	self.__VARS.sizing = true
end

function Frame:StartMoving()
	self.__VARS.width = self.__VARS.width or self:GetRight() - self:GetLeft()
	self.__VARS.height = self.__VARS.height or self:GetBottom() - self:GetTop()

	local mx, my = love.mouse.getPosition()
	self.__VARS.xoff = mx - self:GetLeft()
	self.__VARS.yoff = my - self:GetTop()
	self:ClearAllPoints()
	self.__VARS.moving = true
end

function Frame:StopMovingOrSizing()
	self.__VARS.moving = false
	self.__VARS.sizing = false 
end

function Frame:EnableMouse(var)
self.__VARS.mouseEnabled = var

end

function Frame:MouseDown(x,y,button,index)


	for i = 1, #self.__LAYERS do
		for j =  #self.__LAYERS[i],1,-1 do
			if self.__LAYERS[i][j].MouseDown then
				if self.__LAYERS[i][j]:MouseDown(x,y,button,j) then
					return true
				end
			end
		end
	end
	
	if x > self:GetLeft() and x < self:GetRight() and y > self:GetTop() and y < self:GetBottom() then
		if self.__SCRIPTS.OnMouseDown then
			self.__VARS.mousedown = true
			self.__SCRIPTS.OnMouseDown(self, x, y, button)
			tremove(self.__VARS.parent.__LAYERS[self.__VARS.layer],index)
			tinsert(self.__VARS.parent.__LAYERS[self.__VARS.layer], self)
			return true
		end
	end
end

function Frame:MouseUp(x,y,button)
	for i = 1, #self.__LAYERS do
		for j =  #self.__LAYERS[i],1,-1 do
			if self.__LAYERS[i][j].MouseUp then
				if self.__LAYERS[i][j]:MouseUp(x,y,button) then
					return true
				end
			end
		end
	end
	
	if x > self:GetLeft() and x < self:GetRight() and y > self:GetTop() and y < self:GetBottom() then
		self.__VARS.mousedown = false	
		if self.__SCRIPTS.OnMouseUp then
			self.__SCRIPTS.OnMouseUp(self, x, y, button)
			return true
		end
	end

end

function Frame:CheckMouse(x,y)
	for i = 1, #self.__LAYERS do
		for j =  #self.__LAYERS[i],1,-1 do
			if self.__LAYERS[i][j].CheckMouse then
				if self.__LAYERS[i][j]:CheckMouse(x,y) then
					return true
				end
			end
		end
	end
	
	if x > self:GetLeft() and x < self:GetRight() and y > self:GetTop() and y < self:GetBottom() then
		if self.__SCRIPTS.OnEnter then
			if not self.__VARS.mouseover then
				for i = 1, #UIParent.Frames do
					if UIParent.Frames[i] == self then
						self.__SCRIPTS.OnEnter(self, x, y)
						self.__VARS.mouseover = true
					elseif UIParent.Frames[i].__VARS.mouseover then
						UIParent.Frames[i].__VARS.mouseover = nil
						if UIParent.Frames[i].__SCRIPTS.OnLeave then
							UIParent.Frames[i].__SCRIPTS.OnLeave(UIParent.Frames[i])
						end
					end
				end
			end
			return true
		end
	end

end


function Frame:SetScript(script, func)
	if not (type(script) == "string") then
		error("string expected, got "..type(script))
	end
	if not (type(func) == "function") then
		error("function expected, got "..type(func))
	end

	UIParent.Scripts[script][self] = func
	self.__SCRIPTS[script] = func
end

function Frame:Draw()
	for i = 1, #self.__LAYERS do
		for j = 1,#self.__LAYERS[i] do
			if self.__LAYERS[i][j].__VARS.isshown then
				self.__LAYERS[i][j]:Draw()
			end
		end
	end
end

function Frame:UpdateBackdrop()
	local bd = self.__VARS.backdrop
	local indent = self.__VARS.bdindent
	
	local sx = self:GetScaleX()
	local sy = self:GetScaleY()
	
	bd.TopLeft:SetWidth(indent*sx)
	bd.TopLeft:SetHeight(indent*sy)
	bd.TopLeft:SetTexCoord(0,1/(bd.TopLeft.basewidth/indent), 0,(1/(bd.TopLeft.basewidth/indent)))
	
	bd.Top:SetWidth((self.__VARS.width - 2*indent)*sx)
	bd.Top:SetHeight(indent*sy)
	bd.Top:SetPoint(indent,0)
	bd.Top:SetTexCoord((1/(bd.Top.basewidth/indent)), 1-(1/(bd.Top.basewidth/indent)), 0,(1/(bd.Top.basewidth/indent)))
	
	bd.TopRight:SetWidth(indent*sx)
	bd.TopRight:SetHeight(indent*sx)
	bd.TopRight:SetPoint((self.__VARS.width-indent),0)
	bd.TopRight:SetTexCoord(1-(1/(bd.TopRight.basewidth/indent)), 1, 0, (1/(bd.TopRight.basewidth/indent)))
	
	bd.Left:SetWidth(indent*sx)
	bd.Left:SetHeight((self.__VARS.height - 2*indent)*sy)
	bd.Left:SetPoint(0,indent)
	bd.Left:SetTexCoord(0,(1/(bd.Left.basewidth/indent)), (1/(bd.Left.basewidth/indent)),1-(1/(bd.Left.basewidth/indent)))
	
	bd.Center:SetWidth((self.__VARS.width - 2*indent)*sx)
	bd.Center:SetHeight((self.__VARS.height - 2*indent)*sy)
	bd.Center:SetPoint(indent,indent)
	bd.Center:SetTexCoord((1/(bd.Center.basewidth/indent)), 1-(1/(bd.Center.basewidth/indent)), (1/(bd.Center.basewidth/indent)), 1-(1/(bd.Center.basewidth/indent)))
	
	bd.Right:SetWidth(indent*sx)
	bd.Right:SetHeight((self.__VARS.height- 2*indent)*sy)
	bd.Right:SetPoint((self.__VARS.width-indent),indent)
	bd.Right:SetTexCoord(1-(1/(bd.Right.basewidth/indent)), 1, (1/(bd.Right.basewidth/indent)), 1-(1/(bd.Right.basewidth/indent)))
	
	bd.BottomLeft:SetWidth(indent*sx)
	bd.BottomLeft:SetHeight(indent*sy)
	bd.BottomLeft:SetPoint(0, (self.__VARS.height-indent))
	bd.BottomLeft:SetTexCoord(0, (1/(bd.BottomLeft.basewidth/indent)), 1-(1/(bd.BottomLeft.basewidth/indent)), 1)
	
	bd.Bottom:SetWidth((self.__VARS.width - 2*indent)*sx)
	bd.Bottom:SetHeight(indent*sy)
	bd.Bottom:SetPoint(indent, (self.__VARS.height-indent))
	bd.Bottom:SetTexCoord((1/(bd.Bottom.basewidth/indent)), 1-(1/(bd.Bottom.basewidth/indent)), 1-(1/(bd.Bottom.baseheight/indent)), 1)
	
	bd.BottomRight:SetWidth(indent*sx)
	bd.BottomRight:SetHeight(indent*sy)
	bd.BottomRight:SetPoint((self.__VARS.width-indent), (self.__VARS.height-indent))
	bd.BottomRight:SetTexCoord(1-(1/(bd.BottomRight.basewidth/indent)), 1, 1-(1/(bd.BottomRight.basewidth/indent)), 1)

	
end

function Frame:SetBackdrop(path, indent)
	self.__VARS.minwidth = 2*indent
	self.__VARS.minheight = 2*indent
	self.__VARS.backdrop = {}
	local bd = self.__VARS.backdrop
	self.__VARS.bdindent = indent
	bd.TopLeft = self:CreateTexture()
	bd.TopLeft:SetWidth(indent)
	bd.TopLeft:SetHeight(indent)
	bd.TopLeft:SetPoint(0,0)
	bd.TopLeft:SetTexture(path)
	bd.TopLeft:SetTexCoord(0,1/(bd.TopLeft.basewidth/indent), 0,(1/(bd.TopLeft.basewidth/indent)))
	
	bd.Top = self:CreateTexture()
	bd.Top:SetWidth(self.__VARS.width - 2*indent)
	bd.Top:SetHeight(indent)
	bd.Top:SetPoint(indent,0)
	bd.Top:SetTexture(path)
	bd.Top:SetTexCoord((1/(bd.Top.basewidth/indent)), 1-(1/(bd.Top.basewidth/indent)), 0,(1/(bd.Top.basewidth/indent)))
	
	bd.TopRight = self:CreateTexture()
	bd.TopRight:SetWidth(indent)
	bd.TopRight:SetHeight(indent)
	bd.TopRight:SetPoint(self.__VARS.width-indent,0)
	bd.TopRight:SetTexture(path)
	bd.TopRight:SetTexCoord(1-(1/(bd.TopRight.basewidth/indent)), 1, 0, (1/(bd.TopRight.basewidth/indent)))
		
	bd.Left = self:CreateTexture()
	bd.Left:SetWidth(indent)
	bd.Left:SetHeight(self.__VARS.height - 2*indent)
	bd.Left:SetPoint(0,indent)
	bd.Left:SetTexture(path)
	bd.Left:SetTexCoord(0,(1/(bd.Left.basewidth/indent)), (1/(bd.Left.basewidth/indent)),1-(1/(bd.Left.basewidth/indent)))
		
	bd.Center = self:CreateTexture()
	bd.Center:SetWidth(self.__VARS.width - 2*indent)
	bd.Center:SetHeight(self.__VARS.height - 2*indent)
	bd.Center:SetPoint(indent,indent)
	bd.Center:SetTexture(path)
	bd.Center:SetTexCoord((1/(bd.Center.basewidth/indent)), 1-(1/(bd.Center.basewidth/indent)), (1/(bd.Center.basewidth/indent)), 1-(1/(bd.Center.basewidth/indent)))

	bd.Right = self:CreateTexture()
	bd.Right:SetWidth(indent)
	bd.Right:SetHeight(self.__VARS.height- 2*indent)
	bd.Right:SetPoint(self.__VARS.width-indent,indent)
	bd.Right:SetTexture(path)
	bd.Right:SetTexCoord(1-(1/(bd.Right.basewidth/indent)), 1, (1/(bd.Right.basewidth/indent)), 1-(1/(bd.Right.basewidth/indent)))
	
	bd.BottomLeft = self:CreateTexture()
	bd.BottomLeft:SetWidth(indent)
	bd.BottomLeft:SetHeight(indent)
	bd.BottomLeft:SetPoint(0, self.__VARS.height-indent)
	bd.BottomLeft:SetTexture(path)
	bd.BottomLeft:SetTexCoord(0, (1/(bd.BottomLeft.basewidth/indent)), 1-(1/(bd.BottomLeft.basewidth/indent)), 1)
	
	bd.Bottom = self:CreateTexture()
	bd.Bottom:SetWidth(self.__VARS.width - 2*indent)
	bd.Bottom:SetHeight(indent)
	bd.Bottom:SetPoint(indent, self.__VARS.height-indent)
	bd.Bottom:SetTexture(path)
	bd.Bottom:SetTexCoord((1/(bd.Bottom.basewidth/indent)), 1-(1/(bd.Bottom.basewidth/indent)), 1-(1/(bd.Bottom.baseheight/indent)), 1)
		
	bd.BottomRight = self:CreateTexture()
	bd.BottomRight:SetWidth(indent)
	bd.BottomRight:SetHeight(indent)
	bd.BottomRight:SetPoint(self.__VARS.width-indent, self.__VARS.height-indent)
	bd.BottomRight:SetTexture(path)
	bd.BottomRight:SetTexCoord(1-(1/(bd.BottomRight.basewidth/indent)), 1, 1-(1/(bd.BottomRight.basewidth/indent)), 1)

end



--======================================================================================
--======================================================================================
--======================================================================================
--======================================================================================
--======================================================================================
--======================================================================================
--======================================================================================



local FontString = {}
FontString.__index = UIObject
setmetatable(FontString, FontString)

function FontString:Create(parent, font, size)

	local temp = UIObject:Create(parent)
	temp.__index = FontString
	setmetatable(temp, temp)
	
	temp.__VARS.text = ""
	if size then
		temp.__VARS.font = love.graphics.newFont(font,size)
	elseif font then
		temp.__VARS.font = love.graphics.newFont(font)
	else
		temp.__VARS.font = love.graphics.newFont(12)
	end
	tinsert(parent.__LAYERS[3], temp)

	temp.words = {}
	return temp
end

function FontString:GetTextWidth()
	return self.__VARS.font:getWidth(self.__VARS.text)
end

function words(s)
 local r = {};
 local last = ""
	for p = 1, s:len() do
		local c = s:sub(p, p);
		if c:find("%w") then
			if last:find("%w") then
				r[#r].w = r[#r].w .. c
			else
				r[#r+1] = {w = c}
			end
			--elseif  (c == " ") or (c == "\n") or (c == "\t") then
			--table.insert(r, {w = c})
		else
			table.insert(r, {w = c})
		end
		last = c
	end
	
	return r
end



function FontString:SetColor(color)
	self.__VARS.color = color
end



function FontString:SetText(text)
	self.__VARS.text = text or ""
end

function FontString:GetText()
	return self.__VARS.text
end


function FontString:Draw()
	love.graphics.setFont(self.__VARS.font)
	
		if self.__VARS.color then --override any color formatting if needed
			love.graphics.setColor(unpack(self.__VARS.color))
		end	
		local text = self.__VARS.text
		if self:GetTextWidth() > self:GetWidth() then
			local i = 0
			while self.__VARS.font:getWidth(self:GetText():sub(0,i))+5 < self:GetWidth() do
				i = i + 1
				if i == self:GetText():len() then
					break
				end
			end
			 
			--while math.ceil(self.__VARS.font:getWidth(text)/self:GetWidth())*self.__VARS.font:getHeight(text) > self:GetHeight()  do
				--text = text:sub(1,-2) 
			--end
			
				love.graphics.print(self:GetText():sub(0,i), self:GetLeft(), self:GetTop(), self:GetRot(), self:GetScaleX(), self:GetScaleY())
			
		else
			love.graphics.print(self.__VARS.text, self:GetLeft(), self:GetTop(), self:GetRot(), self:GetScaleX(), self:GetScaleY())
		end
end

function Frame:CreateFontString( path, size)
	return FontString:Create(self, path, size)
end

--======================================================================================
--======================================================================================
--======================================================================================
--======================================================================================
--======================================================================================
--======================================================================================

local Button = {} --comes with a fontstring by default (also needs a texture)
Button.__index = Frame
setmetatable(Button, Button)

function Button:Create(parent, font, size)

	local temp = CreateFrame("Frame", parent)
	temp.__index = Button
	setmetatable(temp, temp)
	temp.__VARS.enabled = true
	
	
	temp.__VARS.pushedfont = temp:CreateFontString()
	temp.__VARS.disabledfont = temp:CreateFontString()
	return temp
end

function Button:Click()
	if self.__Scripts.OnClick then
		self.__Scripts.OnClick(self)
	end
end

function Button:Disable()
	--set texture to disabled if available
	--block the onclick
	self.__VARS.enabled = false
	function self:MouseDown() end

end

function Button:Enable()
	--restore the texture
	--delete the blocked onclick
	self.__VARS.enabled= true
	self.MouseDown = nil
end

function Button:GetButtonState()
	return self.__VARS.mousedown
end

function Button:IsEnabled()
	return self.__VARS.enabled
end

function Button:SetNormalTexture(path)
	if type(path) == "string" then
		self.__VARS.normaltexture = self:CreateTexture()
		self.__VARS.normaltexture:SetTexture(path)
		self.__VARS.normaltexture:SetAllPoints(self)
	else
		--self.__VARS.normaltexture = path
	end
end

function Button:SetPushedTexture(path)
	if type(path) == "string" then
		self.__VARS.pushedtexture = self:CreateTexture()
		self.__VARS.pushedtexture:SetTexture(path)
		self.__VARS.pushedtexture:SetAllPoints(self)
	else
		--self.__VARS.normaltexture = path
	end
end

function Button:SetDisabledTexture(path)
	if type(path) == "string" then
		self.__VARS.disabledtexture = self:CreateTexture()
		self.__VARS.disabledtexture:SetTexture(path)
		self.__VARS.disabledtexture:SetAllPoints(self)
	else
		--self.__VARS.normaltexture = path
	end
end

function Button:SetText(text)
	if not self.__VARS.normalfontstring then
		self.__VARS.normalfontstring = self:CreateFontString()
		self.__VARS.normalfontstring:SetPoint("TOPLEFT", self, "TOPLEFT", 10, 5)
		self.__VARS.normalfontstring:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT",-10, -5)
	end
	self.__VARS.normalfontstring:SetText(text)
end

function Button:SetPushedTextOffset(x,y)
	
	self.__VARS.pushedoffsetx = x
	self.__VARS.pushedoffsety = y
end

function Button:MouseDown(x,y,button,index)
	for i = 1, #self.__LAYERS do
		for j =  #self.__LAYERS[i],1,-1 do
			if self.__LAYERS[i][j].MouseDown then
				if self.__LAYERS[i][j]:MouseDown(x,y,button,j) then
					return true
				end
			end
		end
	end
	
	if x > self:GetLeft() and x < self:GetRight() and y > self:GetTop() and y < self:GetBottom() then
		if self.__VARS.enabled then
			self.__VARS.mousedown = true
			if self.__SCRIPTS.OnMouseDown then
				
				self.__SCRIPTS.OnMouseDown(self, x, y, button)
				tremove(self.__VARS.parent.__LAYERS[self.__VARS.layer],index)
				tinsert(self.__VARS.parent.__LAYERS[self.__VARS.layer], self)
				return true
			end
		end
	end
end

function Button:Draw()

	if not self.__VARS.enabled then
		if self.__VARS.disabledtexture then
			self._VARS.disabledtexture:Draw()
		else
			self.__VARS.normaltexture:SetColor({150,150,150,255})
			self.__VARS.normaltexture:Draw()
			self.__VARS.normaltexture:SetColor(nil)
			self.__VARS.normalfontstring:Draw()
		end 
	elseif self.__VARS.mousedown then
		if self.__VARS.pushedtexture then
			self.__VARS.pushedtexture:Draw()
			if self.__VARS.pushedoffsetx then
				love.graphics.push()
				love.graphics.translate(self.__VARS.pushedoffsetx, self.__VARS.pushedoffsety)
				self.__VARS.normalfontstring:Draw()
				love.graphics.pop()
			end
		end
	else
		if self.__VARS.normaltexture then
			self.__VARS.normaltexture:Draw()
			self.__VARS.normalfontstring:Draw()
		end
	end

end
--======================================================================================
--======================================================================================
--======================================================================================
--======================================================================================
--======================================================================================
--======================================================================================
--======================================================================================
--======================================================================================

local EditBox = {}
EditBox.__index = Frame
setmetatable(EditBox, EditBox)


function EditBox:Create(parent, font, size)

	local temp = CreateFrame("Frame", parent)
	temp.__index = EditBox
	setmetatable(temp, temp)

	temp.body = temp:CreateFontString(font,size)
	temp.body:SetPoint(0,0)
	
	
	
	return temp
end

function EditBox:SetText(self, text)
	self.__VARS.body:SetText(text)
	if self.__VARS.format then --format if its needed
		self.__VARS.body:Format()
	else
		
	end
	
	if self.__VARS.wrapparent and self.__VARS.isshown then --set the parents size if needed
		self.__VARS.body.width = 0
		self.__VARS.body.height = 0
	
		for line in self.__VARS.body.text:gmatch("([^\n]*)\n?") do -- match per line to get max height and width
			if self.__VARS.body.font:getWidth(line) > self.__VARS.body.width then
				self.__VARS.body.width = self.__VARS.body.font:getWidth(line)
			end
			self.__VARS.body.height = self.__VARS.body.height + self.__VARS.body.font:getHeight()*1.2
		end
		self.__VARS.parent:SetWidth(self.__VARS.body.width+50)
		self.__VARS.parent:SetHeight(self.__VARS.body.height+60)
		if self.__VARS.parent.backdrop then
			self.__VARS.parent:UpdateBackdrop()
		end
	end
end

function EditBox:EditText(key,uni)
	local old = self:GetText()
		
	if uni == 8 then --backspace
		old = old:sub(1, old:len()-1)
	elseif uni == 13 then --return
		old = old.."\n"
	elseif key == "shift" or key == "ctrl" or key == "alt" then
	elseif uni == 9 then
		old = old.."   "
	else
		if uni > 0 then
			local s = string.char(uni)
			if s then
				old = old..s
			end
		end
	end
	
	--[[ this will change the name of the box
	if old:find("function") then
		local name = old:match("function%s+%w+%.(%w+)")
		name = name or old:match("function%s+(%w+)")
		name = name or old:match("(%w+)%s-=%s-function")
		if name then
			self.__VARS.title:SetText(name)
		end
	else
		self.__VARS.title:SetText("Variables")
	end
	--]]
	
	if old:find("\n.+function.+") then
		local body, extra = old:match("(.+)\n(.-function.+)")
			local t = CreateFrame("EditFrame", self.__VARS.parent)
			t:SetPoint(0,self.__VARS.parent:GetHeight()-20)
			t.text:SetText(extra)
			t:SetWidth(t.text:GetWidth()+50)
			t:SetHeight(t.text:GetHeight()+60)
			t:UpdateBackdrop()

			self.__VARS.parent.focus = nil
			self.__VARS.parent.subframes[t] = t
			t.parentframe = self.__VARS.parent
			t.focus = true
		old = body
	end
	self:SetText(old)
end

function EditBox:GetText()
	return self.__VARS.body:GetText()
end

function EditBox:SetFormatted(bool)
	self.__VARS.format = bool
	self.__VARS.body.format = bool
end

function EditBox:WrapParent(bool)
	self.__VARS.wrapparent = true
end

function EditBox.SetColor(self,color)
	self.__VARS.body:SetColor(color)
end




--======================================================================================
--======================================================================================
--======================================================================================
--======================================================================================
--======================================================================================
--======================================================================================

--[[
edit frame combines a fonstring title with an editbox and blips to control itself
--]]




function CreateFrame(typ, name, parent)
	parent = parent or UIParent
	if typ == "Frame" then
		return Frame:Create(parent,name)
	elseif typ == "Button" then
		return Button.Create(parent)
	elseif typ == "EditFrame" then
		return EditFrame:Create(parent)
	elseif typ == "EditBox" then
		return EditBox.Create(parent)
	elseif typ == "Project" then
		return Project.Create(parent)
	end
end



return UIParent