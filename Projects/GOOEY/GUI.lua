-- ===============================================
--			LOCALS

local tinsert = table.insert
local tremove = table.remove
local min = math.min
local max = math.max 
local strlower = string.lower
local strupper = string.upper
local floor = math.floor
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

ISSUES:
button:
anchoring: need to check it works for most cases.
anchor to center doesnt work


fonstring needs re writing to move the syntax highlighting to the multilineeditbox


todo:
MLEB:
turn the MLEBLine into the single line edit box for use in other place
MLEBLine is the newer version of editbox, but needs converting to be standalone
add fonts per editbox
move the box inwards when showing the scrollbars

]]

blue = {80, 160, 255, 255}
purple = {220, 50, 210, 255}
red = {200, 50, 80, 255}

local StringTypes = {}
	
StringTypes["if"] = blue
StringTypes["then"] = blue
StringTypes["else"] = blue
StringTypes["end"] = blue
StringTypes["local"] = blue
StringTypes["function"] = blue
StringTypes["while"] = blue
StringTypes["return"] = blue

StringTypes["1"] = purple
StringTypes["2"] =purple
StringTypes["3"] = purple
StringTypes["4"] = purple
StringTypes["5"] = purple
StringTypes["6"] = purple
StringTypes["7"] = purple
StringTypes["8"] = purple
StringTypes["9"] = purple
StringTypes["0"] = purple
StringTypes["+"] = red
StringTypes["-"] = red
StringTypes["="] = red
StringTypes["*"] = red
StringTypes["("] = red
StringTypes[")"] = red
StringTypes[","] = red

StringTypes["{"] = purple
StringTypes["}"] = purple

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
UIParent.EditBoxs = {}

UIParent.Strings = {}

UIParent.Scripts = {}
UIParent.Scripts.OnKeyDown = {}
UIParent.Scripts.OnMouseDown = {}
UIParent.Scripts.OnEnter = {}
UIParent.Scripts.OnLeave = {}
UIParent.Scripts.OnMouseUp = {}
UIParent.Scripts.OnUpdate = {}
UIParent.Scripts.OnClick = {}
UIParent.Scripts.OnEnterPressed = {}
UIParent.Scripts.OnDraw = {}
UIParent.Scripts.OnShow = {}
UIParent.Scripts.OnHide = {}
UIParent.Scripts.OnEscapePressed = {}
UIParent.Scripts.PreDraw = {}
UIParent.Scripts.OnSizeChanged = {}

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

function IsMouseButtonDown(button)
	return love.mouse.isDown(button)
end

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
		if child.__VARS.sizing then
			if child.__VARS.sizing == "TOP" then
				child:SetHeight( child:GetBottom() -my + child.__VARS.yoff)
			elseif child.__VARS.sizing == "LEFT" then
				child:SetWidth( child:GetRight() -mx + child.__VARS.xoff)
			elseif child.__VARS.sizing == "RIGHT" then
				child:SetWidth(mx-child:GetLeft() -child.__VARS.xoff)
			elseif child.__VARS.sizing == "BOTTOM" then
				child:SetHeight(my-child:GetTop() -child.__VARS.yoff)
			end
		end
	end
end

function UIParent:draw()
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
	for _,frame in pairs(UIParent.Frames) do
		if frame.__VARS.mousedown then
			frame.__VARS.mousedown = nil

			
			if frame.__VARS.pushedtexture then
				frame.__VARS.pushedtexture:Hide()
				frame.__VARS.normaltexture:Show()
			end

			if frame.__SCRIPTS.OnClick then
				if x > frame:GetLeft() and x < frame:GetRight() and y > frame:GetTop() and y < frame:GetBottom() then
					frame.__SCRIPTS.OnClick(frame, x, y, button)
				end
			end

		end

		if frame.__SCRIPTS and frame.__SCRIPTS.OnMouseUp then
			frame.__SCRIPTS.OnMouseUp(frame,x,y,button)
		end
	end
end

function UIParent:keypressed(key,uni)
	for _,f in pairs(self.Frames) do
		if f.__VARS.focus or f.__VARS.keyenabled then
			f:keypressed(key,uni)
		end
	end
end

function UIParent:keyreleased(key,uni)
	for _,f in pairs(self.Frames) do
		if f.__VARS.focus or f.__VARS.keyenabled then
			--f:keyreleased(key,uni)
		end
	end
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
	temp.__LAYERS[6] = {} -- FRAMES
	
	if tostring(name) then
		_G[tostring(name)] = temp
	end

	tinsert(UIParent.Frames, temp)
	tinsert(parent.__VARS.children, temp)
	
	return temp
end

function UIObject:SetFrameStrata(strata)
	strata = Strata[strata] or strata
	for i = 1, #self.__VARS.parent.__LAYERS[self.__VARS.layer] do
		if self.__VARS.parent.__LAYERS[self.__VARS.layer][i] == self then
			tremove(self.__VARS.parent.__LAYERS[self.__VARS.layer], i)
			break
		end
	end
	self.__VARS.layer = strata
	tinsert(self.__VARS.parent.__LAYERS[strata], self)
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
	
	--this function needs a rewrite to better handler anchor/size precedence
	

	self.__VARS.left = GetAnchor(self.__VARS.anchors, "left") 
	self.__VARS.right = GetAnchor(self.__VARS.anchors, "right") 

	self.__VARS.top = GetAnchor(self.__VARS.anchors,"top", true) 
	self.__VARS.bottom = GetAnchor(self.__VARS.anchors,"bottom", true)
	
	
	local width = self.__VARS.left and self.__VARS.right and (self.__VARS.right-self.__VARS.left) or self.__VARS.width or 0
	local height = self.__VARS.top and self.__VARS.bottom and (self.__VARS.bottom-self.__VARS.top) or self.__VARS.height or 0
	
	if width ~= self.__VARS.width or height ~= self.__VARS.height then
		self.__VARS.height = height
		self.__VARS.width = width
		if self.__SCRIPTS and self.__SCRIPTS.OnSizeChanged then
			self.__SCRIPTS.OnSizeChanged(self)
		end
	end
	


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

function UIObject:SetParent( parent)
	for i = 1, #self.__VARS.parent.__VARS.children do
		if self.__VARS.parent.__VARS.children[i] == self then
			tremove(self.__VARS.parent.__VARS.children, i)
		end
	end
	for i = 1, #self.__VARS.parent.__LAYERS[self.__VARS.layer] do
		if self.__VARS.parent.__LAYERS[self.__VARS.layer][i] == self then
			tremove(self.__VARS.parent.__LAYERS[self.__VARS.layer],i)
		end
	end

	tinsert(parent.__LAYERS[self.__VARS.layer], self)
	tinsert(parent.__VARS.children, self)
	self.__VARS.parent = parent
	self:ReCalcPosition()
	self:ReDraw()
end

function UIObject:GetScaleY()
	return self.__VARS.scaley * self.__VARS.parent:GetScaleY()
end

function UIObject:SetWidth( width)
	if width ~= self:GetWidth() then
		self.__VARS.width = math.max(width, self.__VARS.minwidth)
		self:ReCalcPosition()
	end
end

function UIObject:SetHeight(height)
	if height ~= self:GetHeight() then
		self.__VARS.height = math.max(height, self.__VARS.minheight)
		self:ReCalcPosition()
	end
end


function UIObject:SetSize(x,y)
	if not y then y = x end
	self.__VARS.width = x
	self.__VARS.height = y
	self:ReCalcPosition()
end


function UIObject:GetLeft()
	return self.__VARS.left or self.__VARS.right and (self.__VARS.right - self:GetWidth()) or 0
end



function UIObject:GetRight()
	return self.__VARS.right or self.__VARS.left and (self.__VARS.left+ self:GetWidth()) or 0
end


function UIObject:GetTop()
	return self.__VARS.top or self.__VARS.bottom and self.__VARS.bottom - self:GetHeight() or 0
end


function UIObject:GetBottom()
	return self.__VARS.bottom or self.__VARS.top and self.__VARS.top + self:GetHeight() or 0
end

function UIObject:GetCenter()
	--dodgy? needs a think
	return (self:GetLeft() + self:GetRight())/2, (self:GetTop() + self:GetBottom())/2
end


function UIObject:GetWidth()
	return math.max((self.__VARS.width or self.__VARS.right - self.__VARS.left or 0),self.__VARS.minwidth)
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
		self.__VARS.anchors[point][1].__VARS.childanch[self] = nil --remove its listing from the frame it was anchored to
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
	if not self.__VARS.isshown then
		if self.__SCRIPTS and self.__SCRIPTS.OnShow then
			self.__SCRIPTS.OnShow(self)
		end
	end
	self.__VARS.isshown = true
end

function UIObject:Hide()
	if self.__VARS.isshown then
		if self.__SCRIPTS and self.__SCRIPTS.OnHide then
			self.__SCRIPTS.OnHide(self)
		end
	end
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
		temp.__VARS.layer = Layers[layer] or layer or 2
		temp.__VARS.isshown = false
		tinsert(parent.__LAYERS[temp.__VARS.layer], temp)
		return temp
end

function Texture:SetTexture(path,g,b,a) -- textures stored as quads to handle settexcoords
	if type(path) == "table" then
		self.__VARS.block = true
		self.__VARS.color = path
	elseif type(path) == "number" then
		self.__VARS.block = true
		self.__VARS.color = {path,g,b,a}
	else
		
		self.__VARS.image = love.graphics.newImage(path)
		self.__VARS.basewidth = self.__VARS.image:getWidth()
		self.__VARS.baseheight = self.__VARS.image:getHeight()
		self.__VARS.quadheight = 1
		self.__VARS.quadwidth = 1
		self.__VARS.quad = love.graphics.newQuad(0,0,self.__VARS.basewidth,self.__VARS.baseheight,self.__VARS.basewidth,self.__VARS.baseheight)
		self.__VARS.color = nil
		self.__VARS.block = nil
		self:SetTexCoord(0,1,0,1)
	end
	self.__VARS.isshown = true
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
		temp.__VARS.layer = 6
		tinsert(parent.__LAYERS[6], temp)
		
		return temp
end

function Frame:CreateTexture(...)
	return Texture:Create(self,...)
end

function Frame:StartSizing(dir)

	local mx, my = love.mouse.getPosition()
	
	self:SetPoint("TOPLEFT", UIParent, "TOPLEFT", self:GetLeft(), self:GetTop())
	self:SetPoint("BOTTOMRIGHT", UIParent, "TOPLEFT", self:GetRight(), self:GetBottom())
	if dir == "TOP" then
		self.__VARS.yoff = my - self:GetTop()
		self.__VARS.anchors.topleft = nil
		self.__VARS.anchors.top = nil
		self.__VARS.anchors.topright = nil
	elseif dir == "LEFT" then
		self.__VARS.xoff = mx - self:GetLeft()
		self.__VARS.anchors.topleft = nil
		self.__VARS.anchors.left = nil
		self.__VARS.anchors.bottomleft = nil
	elseif dir == "RIGHT" then
		self.__VARS.xoff = mx-self:GetRight()
		self.__VARS.anchors.topright = nil
		self.__VARS.anchors.right = nil
		self.__VARS.anchors.bottomright = nil
	elseif dir == "BOTTOM" then
		self.__VARS.yoff = my-self:GetBottom()
		self.__VARS.anchors.bottomright = nil
		self.__VARS.anchors.bottom = nil
		self.__VARS.anchors.bottomleft = nil
	end
	self.__VARS.sizing = dir
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

function Frame:EnableKeyboard(var)
	self.__VARS.keyenabled = var
end


function Frame:MouseDown(x,y,button,index)
	for i = 1, #self.__LAYERS do
		for j =  #self.__LAYERS[i],1,-1 do
			if self.__LAYERS[i][j].MouseDown then
				if self.__LAYERS[i][j]:MouseDown(x,y,button,j) then
					tremove(self.__VARS.parent.__LAYERS[self.__VARS.layer],index)
					tinsert(self.__VARS.parent.__LAYERS[self.__VARS.layer], self)
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

function Frame:keypressed(key,uni)
	if key == "escape" then
		if self.__SCRIPTS.OnEscapePressed then
			self.__SCRIPTS.OnEscapePressed(self)
		end
	end
	if self.__SCRIPTS.OnKeyDown then
		self.__SCRIPTS.OnKeyDown(self, key,uni)
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
		--if self.__SCRIPTS.OnEnter then
			if not self.__VARS.mouseover then
				for i = 1, #UIParent.Frames do
					if UIParent.Frames[i] == self then
						if self.__SCRIPTS.OnEnter then
							self.__SCRIPTS.OnEnter(self, x, y)
						end
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
		--end
	end

end


function Frame:SetScript(script, func)
	if not (type(script) == "string") then
		error("string expected, got "..type(script))
	end
	

	UIParent.Scripts[script][self] = func
	self.__SCRIPTS[script] = func
end

function Frame:Draw()
	if self.__VARS.isshown then
		if self.__SCRIPTS.PreDraw then
			self.__SCRIPTS.PreDraw(self)
		end
	end

	for i = 1, #self.__LAYERS do
		for j = 1,#self.__LAYERS[i] do
			if self.__LAYERS[i][j].__VARS.isshown then
				self.__LAYERS[i][j]:Draw()
			end
		end
	end
	if self.__VARS.isshown then
		if self.__SCRIPTS.OnDraw then
			self.__SCRIPTS.OnDraw(self)
		end
	end
end

function Frame:SetBackdrop(t)
	---[[
	self.__VARS.tl = self:CreateTexture(nil, 1)
	self.__VARS.tl:SetTexture(t.edgeFile)
	self.__VARS.tl:SetTexCoord(0.5, 0.625, 0,1)
	self.__VARS.tl:SetPoint("TOPLEFT", self, "TOPLEFT")
	self.__VARS.tl:SetSize(t.edgeSize)

	self.__VARS.tr = self:CreateTexture(nil, 1)
	self.__VARS.tr:SetTexture(t.edgeFile)
	self.__VARS.tr:SetTexCoord(0.625, 0.75, 0,1)
	self.__VARS.tr:SetPoint("TOPRIGHT", self, "TOPRIGHT")
	self.__VARS.tr:SetSize(t.edgeSize)

	self.__VARS.bl = self:CreateTexture(nil,1)
	self.__VARS.bl:SetTexture(t.edgeFile)
	self.__VARS.bl:SetTexCoord(0.75, 0.875, 0,1)
	self.__VARS.bl:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT")
	self.__VARS.bl:SetSize(t.edgeSize)
	
	self.__VARS.br = self:CreateTexture(nil, 1)
	self.__VARS.br:SetTexture(t.edgeFile)
	self.__VARS.br:SetTexCoord(0.875, 1, 0,1)
	self.__VARS.br:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")
	self.__VARS.br:SetSize(t.edgeSize)

	self.__VARS.l = self:CreateTexture(nil,1)
	self.__VARS.l:SetTexture(t.edgeFile)
	self.__VARS.l:SetTexCoord(0, 0.125, 0,1)
	self.__VARS.l:SetPoint("TOPLEFT", self, "TOPLEFT", 0, t.edgeSize)
	self.__VARS.l:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, -t.edgeSize)
	self.__VARS.l:SetWidth(t.edgeSize)

	self.__VARS.r = self:CreateTexture(nil,1)
	self.__VARS.r:SetTexture(t.edgeFile)
	self.__VARS.r:SetTexCoord(0.125, 0.25, 0,1)
	self.__VARS.r:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, t.edgeSize)
	self.__VARS.r:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, -t.edgeSize)
	self.__VARS.r:SetWidth(t.edgeSize)


	local img2 = love.image.newImageData(t.edgeFile)
	
	local w = img2:getHeight()
	local img = love.image.newImageData(w,w)

	for i = 0, w-1 do
		for j = 0, w-1 do
			img:setPixel(i, j, img2:getPixel(j+w*2, w-1-i))
		end
	end

	self.__VARS.t = self:CreateTexture(nil, 1)
	self.__VARS.t:SetTexture(img)
	self.__VARS.t:SetPoint("TOPLEFT", self, "TOPLEFT", t.edgeSize, 0)
	self.__VARS.t:SetPoint("TOPRIGHT", self, "TOPRIGHT", -t.edgeSize, 0)
	self.__VARS.t:SetHeight(t.edgeSize)
	

	for i = 0, w-1 do
		for j = 0, w-1 do
			img:setPixel(i, j, img2:getPixel(j+w*3, i))
		end
	end

	self.__VARS.b = self:CreateTexture(nil, 1)
	self.__VARS.b:SetTexture(img)
	self.__VARS.b:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", t.edgeSize, 0)
	self.__VARS.b:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -t.edgeSize,0)
	self.__VARS.b:SetHeight(t.edgeSize)

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

function FontString:GetStringWidth()
	return self.__VARS.font:getWidth(self.__VARS.text)
end

function FontString:GetStringHeight()
	return self.__VARS.font:getHeight(self.__VARS.text)
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

		if self:GetWidth() + self:GetHeight() == 0 then
			love.graphics.print(self.__VARS.text, self:GetLeft(), self:GetTop(), self:GetRot(), self:GetScaleX(),
			self:GetScaleY())
		elseif self:GetStringWidth() > self:GetWidth() then
			--if height > self height 
			--else
			love.graphics.printf(self.__VARS.text, self:GetLeft(), self:GetTop(), self:GetWidth(), "left")
			--end
		else
			love.graphics.print(self.__VARS.text, self:GetLeft(), self:GetTop(), self:GetRot(), self:GetScaleX())
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

function Button:Create(parent, name)

	local temp = Frame:Create(parent, name)
	temp.__index = Button
	setmetatable(temp, temp)
	temp.__VARS.enabled = true
	
	temp.__VARS.normaltexture = temp:CreateTexture()
	temp.__VARS.normaltexture:SetAllPoints(temp)
	temp.__VARS.normaltexture:SetTexture(0,0,0,0)
	
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
	self.__VARS.normaltexture:SetTexture(path)
end

function Button:SetPushedTexture(path)
	if not self.__VARS.pushedtexture then
		self.__VARS.pushedtexture = self:CreateTexture()
		self.__VARS.pushedtexture:SetAllPoints(self)
	end
	self.__VARS.pushedtexture:SetTexture(path)
end

function Button:SetDisabledTexture(path)
	if not self.__VARS.disabledtexture then
		self.__VARS.disabledtexture = self:CreateTexture()
		self.__VARS.disabledtexture:SetAllPoints(self)
	end
	self.__VARS.disabledtexture:SetTexture(path)
end

function Button:SetText(text)
	if not self.__VARS.normalfontstring then
		self.__VARS.normalfontstring = self:CreateFontString()
		self.__VARS.normalfontstring:SetPoint("TOPLEFT", self, "TOPLEFT", 10, 5)
		self.__VARS.normalfontstring:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT",-10, -5)
	end
	self.__VARS.normalfontstring:SetText(text)
end

function Button:GetText()
	return self.__VARS.normalfontstring:GetText()
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

				if self.__VARS.pushedtexture then
					self.__VARS.pushedtexture:Show()
					self.__VARS.normaltexture:Hide()
				end

				self.__SCRIPTS.OnMouseDown(self, x, y, button)
				tremove(self.__VARS.parent.__LAYERS[self.__VARS.layer],index)
				tinsert(self.__VARS.parent.__LAYERS[self.__VARS.layer], self)
				return true
			end
		end
	end
end


function Button:GetStringWidth()
	return self.__VARS.normalfontstring:GetWidth()
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


function EditBox:Create(parent, ...)

	local temp = Frame:Create(parent, ...)
	temp.__index = EditBox
	setmetatable(temp, temp)

	temp.__VARS.mouseEnabled = true
	
	tinsert(UIParent.EditBoxs, temp)
	
	return temp
end

function EditBox:MouseDown(x,y,button)

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
		
			for _,eb in pairs(UIParent.EditBoxs) do
				if eb == self then
					eb.__VARS.focus = true
				else
					eb.__VARS.focus = nil
				end
			end
	
			self.__VARS.mousedown = true
		if self.__SCRIPTS.OnMouseDown then
			self.__SCRIPTS.OnMouseDown(self, x, y, button)
			tremove(self.__VARS.parent.__LAYERS[self.__VARS.layer],index)
			tinsert(self.__VARS.parent.__LAYERS[self.__VARS.layer], self)
			return true
		end
	end
end

function EditBox:SetText(text)
	if not self.__VARS.body then 
		self.__VARS.body  = self:CreateFontString()
		self.__VARS.body:SetPoint("TOPLEFT", self, "TOPLEFT", 5, 5)
		self.__VARS.body:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -5, -5)
	end
	self.__VARS.body:SetText(text)

end

function EditBox:GetText()
	return self.__VARS.body:GetText()
end

function EditBox:GetStringHeight()
	return self.__VARS.body:GetStringHeight()
end

function EditBox:GetStringWidth()
	return self.__VARS.body:GetStringWidth()
end

function EditBox:keypressed(key,uni)
	if self.__SCRIPTS.OnKeyDown then
		self.__SCRIPTS.OnKeyDown(self,key,uni)
	end
	if not self.__VARS.body then 
		self.__VARS.body  = self:CreateFontString()
		self.__VARS.body:SetAllPoints(self)
	end
	if key == "tab" then
		
	elseif key == 'backspace' then
		self:SetText(self:GetText():sub(1,-2))
	elseif key == 'return' then
		if self.__SCRIPTS.OnEnterPressed then
			self.__SCRIPTS.OnEnterPressed(self)
		end
	elseif key == "escape" then
		if self.__SCRIPTS.OnEscapePressed then	
			self.__SCRIPTS.OnEscapePressed(self)
		end
	else
		if uni > 31 and uni < 127 then
			self.__VARS.body.__VARS.text = self.__VARS.body.__VARS.text..string.char(uni)
			
		end
	end
end

function EditBox:ClearFocus()
	self.__VARS.focus = nil
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




local MultiLineEditBox = {}
MultiLineEditBox.__index = Frame
setmetatable(MultiLineEditBox, MultiLineEditBox)


function MultiLineEditBox:Create(parent, ...)

	local temp = Frame:Create(parent, ...)
	temp.__index = MultiLineEditBox
	setmetatable(temp, temp)

	temp.__VARS.mouseEnabled = true
	temp.__VARS.fontsize = 12
	temp.__VARS.lines = {}
	temp.__VARS.blockwidth = 0
	temp.__VARS.blockheight = 0
	
	tinsert(UIParent.EditBoxs, temp)
	
	temp.vscroll = CreateFrame("Button")
	temp.vscroll:SetWidth(10)
	temp.vscroll:SetPoint("TOPRIGHT", temp, "TOPRIGHT", -2, 2)
	temp.vscroll.t = temp.vscroll:CreateTexture()
	temp.vscroll.t:SetTexture(80,80,80,120)
	temp.vscroll.t:SetAllPoints(temp.vscroll)
	
	temp.vscroll:SetScript("OnMouseDown", function(self)
																											self.yoff = self:GetTop()-love.mouse.getY()
																											
																												self:SetScript("OnUpdate", function(self)
																													local y = love.mouse.getY()-temp:GetTop()+self.yoff
																													y = math.max(y,0)
																													y = math.min(temp:GetHeight()-self:GetHeight(),y)
																													self:SetPoint("TOPRIGHT", temp, "TOPRIGHT", -2, y)
																													temp:SetOffset(nil, -(y/(temp:GetHeight() -self:GetHeight()))*temp.__VARS.blockheight)
																													
																												end)
																											end)
	temp.vscroll:SetScript("OnMouseUp", function(self) self:SetScript("OnUpdate", nil) end)
	
	temp.hscroll = CreateFrame("Button")
	temp.hscroll:SetHeight(10)
	temp.hscroll:SetPoint("BOTTOMLEFT", temp, "BOTTOMLEFT", 2, -2)
	temp.hscroll.t = temp.hscroll:CreateTexture()
	temp.hscroll.t:SetTexture(80,80,80,120)
	temp.hscroll.t:SetAllPoints(temp.hscroll)

	temp.hscroll:SetScript("OnMouseDown", function(self)
																											self.xoff = self:GetLeft()-love.mouse.getX()
																											
																												self:SetScript("OnUpdate", function(self)
																													local x = love.mouse.getX()-temp:GetLeft()+self.xoff
																													x = math.max(x,2)
																													x = math.min(temp:GetWidth()-self:GetWidth(),x)
																													self:SetPoint("BOTTOMLEFT", temp, "BOTTOMLEFT", x, -2)
																													temp:SetOffset(-(x/(temp:GetWidth() -self:GetWidth()))*temp.__VARS.blockwidth,nil)
																													
																												end)
																											end)
	temp.hscroll:SetScript("OnMouseUp", function(self) self:SetScript("OnUpdate", nil) end)
	
	temp:SetScript("OnSizeChanged", function(self) self:Resize() end)
	temp:AddLine()
	temp:SetOffset(0,0) --compensate for the extra line that the first new line adds
	
		
	return temp
end

function MultiLineEditBox:SetOffset(offsx, offsy)
	if not offsx then
		offsx = self.__VARS.lines[1]:GetLeft() - self:GetLeft()
	end
	if not offsy then
		offsy = self.__VARS.lines[1]:GetTop() - self:GetTop()
	end
	self.__VARS.lines[1]:SetPoint("TOPLEFT", self, "TOPLEFT", offsx, offsy)
	
end

function MultiLineEditBox:GetOffset()
 return self.__VARS.lines[1]:GetLeft() - self:GetLeft(), self.__VARS.lines[1]:GetTop() - self:GetTop()
end

function MultiLineEditBox:Resize() --resizes the scrollbars and shows/hides them
	
	if love.graphics.getFont() then
	
	self.__VARS.blockwidth = 0
	
		for i = 1, #self.__VARS.lines do
				self.__VARS.blockwidth = math.max(self.__VARS.blockwidth,love.graphics.getFont():getWidth(self.__VARS.lines[i].text))
		end
	
	self.__VARS.blockheight = #self.__VARS.lines*self.__VARS.fontsize
		
		if self.__VARS.blockwidth > self:GetWidth() then
			self.hscroll:SetWidth(math.max(10,(self:GetWidth()/self.__VARS.blockwidth)*self:GetWidth()-20))
			self.hscroll:Show()
		else
			self.hscroll:Hide()
			self:SetOffset(0, nil)
		end
		
		if self.__VARS.blockheight > self:GetHeight() then
			self.vscroll:SetHeight(math.max(10,(self:GetHeight()/self.__VARS.blockheight)*self:GetHeight()-20))
			self.vscroll:Show()
		else
			self.vscroll:Hide()
			self:SetOffset(nil,0)
		end
	end
end



function MultiLineEditBox:MouseDown(x,y,button)

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
		
			for _,eb in pairs(UIParent.EditBoxs) do
				if eb == self then
					eb.__VARS.focus = true
				else
					eb.__VARS.focus = nil
				end
			end
	
			self.__VARS.mousedown = true
		if self.__SCRIPTS.OnMouseDown then
			self.__SCRIPTS.OnMouseDown(self, x, y, button)
			tremove(self.__VARS.parent.__LAYERS[self.__VARS.layer],index)
			tinsert(self.__VARS.parent.__LAYERS[self.__VARS.layer], self)
			return true
		end
	end
	
	
	
		self:SelectLine(floor((y - self:GetTop()+(self:GetTop()-self.__VARS.lines[1]:GetTop()))/self.__VARS.fontsize)+1) --set the line mouse is on as the selected
		-- the below needs changing to use the editbox font and not just a random one!
		if self.__VARS.selectedline.text:len() > 0  then
			local cpos = floor(((x-self:GetLeft())/(love.graphics.getFont():getWidth(self.__VARS.selectedline.text)/self.__VARS.selectedline.text:len()))) --set the character position
			self.__VARS.selectedline.cpos = math.min(cpos, self.__VARS.selectedline.text:len())
		end
	
end



function MultiLineEditBox:SelectLine(index)
	if self.__VARS.lines[index] then
		for i = 1, #self.__VARS.lines do
			local l = self.__VARS.lines[i]
			if i == index then
				l.selected = true
			elseif l.selected then
			l:Split()
				l.buffer = love.graphics.newCanvas(self:GetWidth(), self.__VARS.fontsize)
				love.graphics.setCanvas(l.buffer)
				l:Draw(true) -- true means destined for buffer
				love.graphics.setCanvas()
				l.selected = false
			else
				l.selected = false
			end
	end
	self.__VARS.selectedline = self.__VARS.lines[index]
	self.__VARS.selectedline.selected = true
	end
end

function MultiLineEditBox:keypressed(key,uni)

	local sl = self.__VARS.selectedline

	if key == "escape" then
		self:ClearFocus()
	elseif key == "left" then
		if sl.cpos == 0 then
			if sl.index > 1 then
				self:SelectLine(sl.index-1)
				self.__VARS.selectedline.cpos = self.__VARS.selectedline.text:len()
			end
		else
			sl:keypressed(key, uni)
		end
		
	elseif  key == "right" then
		if sl.cpos == sl.text:len() then
			if sl.index < #self.__VARS.lines then
				self:SelectLine(sl.index+1)
				self.__VARS.selectedline.cpos = 0
			end
		else
			sl:keypressed(key, uni)
		end
	elseif key == "up" then
		if sl.index > 1 then
			self:SelectLine(sl.index-1)
			self.__VARS.selectedline.cpos = math.min(self.__VARS.selectedline.text:len(), sl.cpos)
		end
	elseif key == "down" then
		if sl.index < #self.__VARS.lines then
			self:SelectLine(sl.index+1)
			self.__VARS.selectedline.cpos = math.min(self.__VARS.selectedline.text:len(), sl.cpos)
		end
	elseif key == "backspace" then
		if sl.cpos == 0 then
			if sl.index > 1 then
				self:SelectLine(sl.index-1)
				self.__VARS.selectedline.cpos = self.__VARS.selectedline.text:len()
				self.__VARS.selectedline.text = self.__VARS.selectedline.text..sl.text
				
				table.remove(self.__VARS.lines, sl.index)
				for i = 2, #self.__VARS.lines do
					self.__VARS.lines[i]:SetPoint("TOPLEFT", self.__VARS.lines[i-1], "BOTTOMLEFT")
					self.__VARS.lines[i].index = i
				end
				self.__VARS.selectedline:Split() -- re highlight the new current line
			end
		else
			sl:keypressed(key,uni)
		end
	elseif key == "return" then
		local temp = sl.text
		sl.text = sl.text:sub(1, sl.cpos)
		self:AddLine(sl.index+1, temp:sub(sl.cpos+1))
	else
		sl:keypressed(key,uni)
	end
	
	self.timer = -0.5
	self.lastkey = key
	self:SetScript("OnUpdate", function(self,dt)
		self.timer = self.timer + dt
		if self.timer > 0.05 then
			if love.keyboard.isDown(self.lastkey) then
				self:keypressed(key, uni)
				self.timer = 0
			else
				self:SetScript("OnUpdate", nil)
			end
		end
	end)
	self:Resize()
end

function MultiLineEditBox:Draw()
	love.graphics.setScissor(self:GetLeft(), self:GetTop(), self:GetWidth(), self:GetHeight())
	for i = 1, #self.__VARS.lines do
		local l = self.__VARS.lines[i]
		
		if l.selected then
			l:Draw()
			local f = love.graphics.getFont()
			local x
			if self.__VARS.selectedline.text:len() > 0 then
			 x = l:GetLeft()+love.graphics.getFont():getWidth(l.text:sub(1, l.cpos))
			 else
			 x = l:GetLeft()
			end
			love.graphics.line(x, l:GetTop(),x, l:GetBottom())
		else
			love.graphics.setBlendMode("premultiplied")
			love.graphics.draw(l.buffer, l:GetLeft(), l:GetTop())
			love.graphics.setBlendMode("alpha")
		end
	end
	love.graphics.setScissor()
end

function MultiLineEditBox:ClearFocus()
	self.__VARS.focus = nil
end



--============================ MLEBLINE ====================================================

local MLEBLine = {}
MLEBLine.__index = Frame
setmetatable(MLEBLine, MLEBLine)

function MLEBLine:Draw(buffer)
local dist = 0
	if self.set then
		for i = 1, #self.set do
			love.graphics.setColor(StringTypes[self.set[i].w] or {255,255,255,255})
			if buffer then
				love.graphics.print(self.set[i].w, dist, 0)
			else
					love.graphics.print(self.set[i].w, dist+self:GetLeft(), self:GetTop())
			end
			dist = dist + love.graphics.getFont():getWidth(self.set[i].w)
		end
		love.graphics.setColor(255,255,255,255)
	end
end

function MLEBLine:Create(parent,...)

	local temp = Frame:Create(parent, ...)
	temp.__index = MLEBLine
	setmetatable(temp, temp)
	temp.__VARS.mouseEnabled = true
	
	tinsert(UIParent.EditBoxs, temp)
	
	return temp
end

function MultiLineEditBox:AddLine(position, text)
	if type(position) == "string" then
		text = position
		position = #self.__VARS.lines+1
	elseif not position then
		position = #self.__VARS.lines+1
		text = ""
	end
	
	local l = MLEBLine:Create(self)
	
	l.text = text or ""
	l.cpos = 0
	l.index = position
	
	if #self.__VARS.lines <1 then
		l:SetPoint("TOPLEFT", self, "TOPLEFT")
		l:SetHeight(12)
		l:SetPoint("RIGHT", self, "RIGHT")
	else
		l:SetPoint("TOPLEFT", self.__VARS.lines[position-1], "BOTTOMLEFT")
		l:SetHeight(12)
		l:SetPoint("RIGHT", self, "RIGHT")
	end
	
	if position < #self.__VARS.lines then
		table.insert(self.__VARS.lines, position,l)
		self.__VARS.lines[1]:SetPoint("TOPLEFT", self, "TOPLEFT")
		for i = 2, #self.__VARS.lines do
			self.__VARS.lines[i]:SetPoint("TOPLEFT", self.__VARS.lines[i-1], "BOTTOMLEFT")
			self.__VARS.lines[i].index = i
		end
	else
		table.insert(self.__VARS.lines,position,l)
	end
	
	self:SelectLine(position)
	l:Split()
	local x, y = self:GetOffset()
	self:SetOffset(nil, y-self.__VARS.fontsize)
		
end



function MLEBLine:keypressed(key, uni)
	--[[
	if self.__SCRIPTS.OnKeyDown then
		self.__SCRIPTS.OnKeyDown(self,key,uni)
	end
	
	if not self.__VARS.body then 
		self.__VARS.body  = self:CreateFontString()
		self.__VARS.body:SetAllPoints(self)
	end
	--]]
	if key == "left" then
		self.cpos = math.max(0, self.cpos - 1)
	elseif key == "right" then
		self.cpos = math.min(self.cpos+1, self.text:len())
	elseif key == 'backspace' then
		if self.cpos > 0 then
			self.text = self.text:sub(1, self.cpos-1)..self.text:sub(self.cpos+1)
			self.cpos = self.cpos - 1
		end
	elseif key == "return" then
		if self.__SCRIPTS.OnEnterPressed then
			self.__SCRIPTS.OnEnterPressed(self)
		end
	elseif key == "escape" then
		if self.__SCRIPTS.OnEscapePressed then	
			self.__SCRIPTS.OnEscapePressed(self)
		end
	elseif key == "tab" then
		self.text = self.text:sub(1, self.cpos).."    "..self.text:sub(self.cpos+1)
		self.cpos = self.cpos+4
	elseif uni > 31 and uni < 127 then
		
		self.text = self.text:sub(1, self.cpos)..string.char(uni)..self.text:sub(self.cpos+1)
		self.cpos = self.cpos+1
		
	end
	self:Split()
	
end


function MLEBLine:ClearFocus()
	self.__VARS.focus = nil
end

function MLEBLine:Split()
	self.set = words(self.text)
end


--======================================================================================
--======================================================================================
--======================================================================================
--======================================================================================
--======================================================================================


function CreateFrame(typ, name, parent)
	parent = parent or UIParent
	if typ == "Frame" then
		return Frame:Create(parent,name)
	elseif typ == "Button" then
		return Button:Create(parent,name)
	elseif typ == "EditFrame" then
		return EditFrame:Create(parent,name)
	elseif typ == "EditBox" then
		return EditBox:Create(parent,name)
	elseif typ == "MultiLineEditBox" then
		return MultiLineEditBox:Create(parent, name)
	end
end

function RequireFrame()
	return Frame
end



return UIParent