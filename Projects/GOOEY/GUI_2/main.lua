


local UIParent = require "GUI"



local tl = CreateFrame("Frame") --create a new frame
tl:SetSize(20,20) --set its width and height
tl:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 50, 50) --anchor it to the UIParent (the screen)
tl.tex = tl:CreateTexture() --create a texture parented to the frame
tl.tex:SetTexture(255,255,100,255) --give the texture a block color
tl.tex:SetAllPoints(tl) -- set all of the textures anchors to the frame
tl:SetScript("OnMouseDown", function(self, x, y) self:StartMoving()  end) --add a script to run when mousedown on the frame
tl:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing()  end) 



local br = CreateFrame("Frame")
br:SetSize(20,20)
br:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 200, 200)
br.tex = br:CreateTexture()
br.tex:SetTexture(255,255,100,255)
br.tex:SetAllPoints(br)
br:SetScript("OnMouseDown", function(self, x, y) self:StartMoving()  end)
br:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing()  end)



local f = CreateFrame("Frame")
f:SetSize(200,200)
f:SetPoint("TOPLEFT", tl,"BOTTOMRIGHT", 0, 0)

f:SetPoint("BOTTOMRIGHT", br, "TOPLEFT",0,0)
f.tex = f:CreateTexture()
f.tex:SetTexture(20,30,130,255)
f.tex:SetPoint("TOPLEFT", f, "TOPLEFT",0,0)
f.tex:SetPoint("TOPRIGHT", f, "TOPRIGHT",0,0)
f.tex:SetPoint("BOTTOM", f, "CENTER", 0,-10)
f.tex2 = f:CreateTexture()
f.tex2:SetTexture(200,30, 30,255)
f.tex2:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT",0,0)
f.tex2:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT",0,0)
f.tex2:SetPoint("TOP", f, "CENTER", 0,10)

local parent = br
for i = 1, 10 do
	local f = CreateFrame("Frame","testbox"..i,parent) --named frames have global names
	f:SetSize(40,40)
	f:SetPoint("TOPLEFT", parent,"BOTTOMRIGHT", 20, 20)

	f.tex = f:CreateTexture()
	f.tex:SetTexture(i*25,255-i*255,255,255)
	f.tex:SetAllPoints(f)
	f.ID = i

	f:EnableMouse(true)
	f:SetScript("OnMouseDown", function(self, x, y) self:Hide()  end)
	f:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing()  end)
	f:SetScript("OnEnter", function(self)self.tex:SetTexture(self.ID*25,255-self.ID*255,110,255) end ) --script when mouse hovers over the frame
	f:SetScript("OnLeave", function(self)self.tex:SetTexture(self.ID*25,255-self.ID*255,255,255) end )
	parent = f
end

local g = CreateFrame("Button",nil, f)

g:SetPoint("TOPLEFT", f, "TOPLEFT",10,10)
g:SetPoint("TOPRIGHT", f, "TOPRIGHT", -10, 10)
g:SetPoint("BOTTOM", f, "TOP",0,45)
g:SetText("test button")

g:SetNormalTexture("b1normal.png")
g:SetPushedTexture("b1pushed.png")
g:SetPushedTextOffset(2,2)

local h = CreateFrame("Button")

h:SetPoint("LEFT", g, "LEFT",0,0)
h:SetPoint("RIGHT", g, "RIGHT", 0, 0)
h:SetPoint("TOP", g, "BOTTOM",0,10)
h:SetHeight(35)
h:SetText("test button 2")

h:SetNormalTexture("b1normal.png")
h:SetPushedTexture("b1pushed.png")
h.i = 2
h:SetScript("OnMouseDown", function(self) _G["testbox"..self.i]:Hide()
										_G["testbox"..(self.i-1)]:Show()
										self.i = self.i <10 and self.i+1 or 2
										end )
h:SetScript("OnClick", function(self) print("test") end)


--callbacks

function love.update(dt)
	UIParent:update(dt)
end

function love.keypressed(key)
	UIParent:keypressed(key,uni)

end

function love.mousepressed(x,y,button)
	UIParent:mousepressed(x,y,button)
end

function love.mousereleased(x,y,button)
	UIParent:mousereleased(x,y,button)
end

function love.draw()
	UIParent:draw()
end

