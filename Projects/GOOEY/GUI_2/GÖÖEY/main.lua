
local UIParent = require "GUI"

local tl = CreateFrame("Frame")
tl:SetSize(20,20)
tl:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 50, 50)
tl.tex = tl:CreateTexture()
tl.tex:SetTexture(255,255,100,255)
tl.tex:SetAllPoints(tl)
tl:SetScript("OnMouseDown", function(self, x, y) self:StartMoving()  end)
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


for i = 1, 10 do
	local f = CreateFrame("Frame","testbox"..i)
	f:SetSize(40,40)
	f:SetPoint("TOPLEFT", br,"BOTTOMRIGHT", i*42, 0)

	f.tex = f:CreateTexture()
	f.tex:SetTexture(i*25,255-i*255,255,255)
	f.tex:SetAllPoints(f)
	f.ID = i

	f:EnableMouse(true)
	f:SetScript("OnMouseDown", function(self, x, y) self:StartMoving()  end)
	f:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing()  end)
	f:SetScript("OnEnter", function(self)self.tex:SetTexture(self.ID*25,255-self.ID*255,110,255) end )
	f:SetScript("OnLeave", function(self)self.tex:SetTexture(self.ID*25,255-self.ID*255,255,255) end )
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
	if br:IsVisible() then
		love.graphics.print(br:GetLeft(), 20, 20)
	end
end

