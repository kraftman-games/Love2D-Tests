
local UIParent = require "GUI"

local f = CreateFrame("Frame")
f:SetSize(200,200)
f:SetPoint("TOPLEFT", UIParent,"TOPLEFT", 40, 50)



f:EnableMouse(true)
f:SetScript("OnMouseDown", function(self, x, y) self:StartMoving()  end)
f:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing()  end)

local g = CreateFrame("Frame",f)
g:SetSize(20, 20)
g:SetPoint("TOPLEFT", f, "TOPLEFT",0,0)
g.tex = g:CreateTexture()
g.tex:SetTexture(255,20,20,255)
g.tex:SetAllPoints(g)
g:EnableMouse(true)
g:SetScript("OnMouseDown", function(self) print("cheese")self.tex:SetTexture(0,255,0,255) end)
g:SetScript("OnMouseUp", function(self) self.tex:SetTexture(255,20,20,255) end)

local g = CreateFrame("Frame",f)
g:SetSize(20, 20)
g:SetPoint("TOPRIGHT", f, "TOPRIGHT",0,0)
g.tex = g:CreateTexture()
g.tex:SetTexture(20,255,20,255)
g.tex:SetAllPoints(g)

local g = CreateFrame("Frame",f)
g:SetSize(20, 20)
g:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT",0,0)
g.tex = g:CreateTexture()
g.tex:SetTexture(25,20,255,255)
g.tex:SetAllPoints(g)

local g = CreateFrame("Frame",f)
g:SetSize(20, 20)
g:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT",0,0)
g.tex = g:CreateTexture()
g.tex:SetTexture(255,255,20,255)
g.tex:SetAllPoints(g)
g:SetScript("OnEnter", function(self) self.tex:SetTexture(0,255,255,255) print("test)") end)
g:SetScript("OnLeave", function(self) self.tex:SetTexture(255,255,0,255) end)


for i = 1, 10 do
local g = CreateFrame("Frame",f)
g:SetSize(50, 50)
g:SetPoint("TOPRIGHT", f, "BOTTOMRIGHT",i*52,0)
g.tex = g:CreateTexture()
g.tex:SetTexture(i*25,255-i*25,20,255)
g.tex:SetAllPoints(g)
g:SetScript("OnMouseDown", function(self) self:StartMoving() end)
g:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)
end



function love.update(dt)
	UIParent:Update(dt)
end

function love.keypressed(key)
	if key == "up" then
		f:SetWidth(f:GetWidth()+10)
	end

end

function love.mousepressed(x,y,button)
	UIParent:MouseDown(x,y,button)
end

function love.mousereleased(x,y,button)
	UIParent:MouseUp(x,y,button)
end

function love.draw()
	UIParent:Draw()

	--love.graphics.rectangle("fill", f:GetLeft(), f:GetTop(), f:GetWidth(), f:GetHeight())
	--love.graphics.rectangle("fill", g:GetLeft(), g:GetTop(), g:GetWidth(), g:GetHeight())
	love.graphics.print(love.timer.getFPS(), 20, 20)
end

