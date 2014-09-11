

require "socket"


local f = CreateFrame("Frame")
--=====================================
local tinsert = table.insert


--====================================

--[[
	handle channel welcome message
	multi line
	user list
	font support
]]

f:SetSize(400, 400)
f:SetPoint("TOPLEFT", UIParent, "TOPLEFT")

f.login = CreateFrame("Frame", nil, f)
f.login:SetAllPoints(f)


f.login.name = CreateFrame("EditBox", nil, f.login)
f.login.name:SetSize(140,20)
f.login.name:SetPoint("TOPLEFT", f.login, "TOPLEFT", 100, 50)
f.login.name.bg = f.login.name:CreateTexture()
f.login.name.bg:SetAllPoints(f.login.name)
f.login.name.bg:SetTexture(100,100,100,255)
f.login.name:SetScript("OnEnterPressed", function(self) f:connect(self:GetText()) end)
f.login.nlabel = f.login:CreateFontString()
f.login.nlabel:SetText("Username:")
f.login.nlabel:SetPoint("topleft", f.login.name, "topleft", -80, 3)


--======================

f.main = CreateFrame("Frame",nil,f)
local m = f.main
m:SetAllPoints(f)



m.input = CreateFrame("EditBox", nil, m)
m.input:SetPoint("BOTTOMLEFT", m, "bottomleft" )
m.input:SetPoint("BOTTOMRIGHT", m,"BOTTOMRIGHT")
m.input:SetHeight(30)
m.input.edge = m.input:CreateTexture()
m.input.edge:SetTexture(COLORS.edgec)
m.input.edge:SetPoint("TOPLEFT", m.input, "TOPLEFT")
m.input.edge:SetPoint("TOPRIGHT", m.input, "TOPRIGHT")
m.input.edge:SetHeight(3)
m.input:SetScript("OnKeyDown", function(self, key)
	if key == "up" then
		
		if f.selected.history[#f.selected.history+f.selected.histcount] then
			self:SetText(f.selected.history[#f.selected.history+f.selected.histcount])
		end
		f.selected.histcount = f.selected.histcount-1
	elseif key == "down" then
		
		if f.selected.history[#f.selected.history+f.selected.histcount] then
			self:SetText(f.selected.history[#f.selected.history+f.selected.histcount])
		else
			self:SetText("")
		end
		f.selected.histcount = f.selected.histcount+1
	end
end)

m.input:SetScript("OnEnterPressed", 
	function(self) 
		f:send(self:GetText())
		self:SetText("")
		f.selected.histcount = 0
	end)

m.chan = CreateFrame("Frame", nil, m)
m.chan:SetPoint("TOPLEFT", m , "TOPLEFT")
m.chan:SetPoint("TOPRIGHT", m, "TOPRIGHT")
m.chan:SetHeight(25)
m.chan.b = m.chan:CreateTexture()
m.chan.b:SetTexture(COLORS.edgec)
m.chan.b:SetPoint("BOTTOMLEFT", m.chan, "BOTTOMLEFT")
m.chan.b:SetPoint("BOTTOMRIGHT", m.chan, "BOTTOMRIGHT")
m.chan.b:SetHeight(3)
f.channels = {}
f.strchan = {}

function f:NewChannel(name)
	if f.strchan[name] then
		print("you are already in this channel")
		return
	end
	local button = CreateFrame("Button", nil, m.chan)
	button:SetText(name)
	tinsert(f.channels, button)
	f.strchan[name] = button
	button.chat = m:CreateFontString()
	button.chat:SetPoint("BOTTOMLEFT", m.input, "TOPLEFT", 5, 0)
	button.chat:SetPoint("BOTTOMRIGHT", m.input, "TOPRIGHT", -5, 0)
	button.chat:SetHeight(15)

	button:SetPoint("TOP", m.chan, "TOP")
	button:SetPoint("BOTTOM", m.chan, "BOTTOM")
	if #f.channels == 1 then
		button:SetPoint("LEFT",  m.chan, "LEFT",5,0)
	else
		button:SetPoint("LEFT", f.channels[#f.channels-1], "RIGHT",5,0)
	end
	button:SetText(name)
	button:SetWidth(50)
	button.history = {}
	button.histcount = 0

	function button:Select()
		for k,b in pairs(f.channels) do
			if b == self then
				b.selected = true
				f.selected = b
				b.chat:Show()
			else
				b.selected = false
				b.chat:Hide()
			end
		end
	end

	button:Select()
	button:SetScript("OnClick", function(self) self:Select() print("meep") end)

end

m.users = CreateFrame("Frame", nil, m)
m.users:SetPoint("TOPRIGHT", m.chan, "BOTTOMRIGHT")
m.users:SetPoint("BOTTOMRIGHT", m.input, "TOPRIGHT")
m.users:SetWidth(10)
m.users.t = m.users:CreateTexture()
m.users.t:SetTexture(180, 60, 60, 255)
m.users.t:SetAllPoints(m.users)




m:Hide()


f:SetScript("OnUpdate", function(self) 
	if self.con then
		local test,err = self.con:receive("*l")
		if test and not (test == "") then
			print(test)
			self:process(test)
		end
	end
end)

function f:send(msg)
	local chan
	if f.selected then
		chan = f.selected:GetText()
		if chan ~= "Server" then
			f:print(chan, f.name..": "..msg)
			f.selected.history[#f.selected.history+1] = msg
			msg= "PRIVMSG "..chan.." : "..msg

		end
	else

	end
	
		print("sending: "..msg)
		f.con:send(msg.."\r\n") 
		if not chan then
			fprint("SERVER", msg)
		end
end

function f:DelChannel(chan)
	if not f.strchan[chan] then
		print("you aren't in that channel")
		return
	end
	f.strchan[chan] = nil
	for i = 1, #f.channels do
		if f.channels[i]:GetText() == chan then
			if f.channels[i+1] then
				f.channels[i+1]:SetPoint("LEFT", f.channels[i-1], "RIGHT",5,0)
			end
			f.channels[i]:Hide()
			table.remove(f.channels, i)
			break
		end
	end
	if f.selected:GetText() == chan then
		f.selected = f.selected[#f.selected]
	end

end

function f:print(dest,msg)
	if not f.strchan[dest] then
		f:NewChannel(dest)
		print("making private channel")
	end
	if f.strchan[dest] then
		msg = "["..os.date("%H:%M").."] "..msg

		f.strchan[dest].chat:SetText(f.strchan[dest].chat:GetText().."\n"..msg)
		f.strchan[dest].chat:SetHeight(f.strchan[dest].chat:GetHeight() + f.strchan[dest].chat:GetTextHeight())
	end

end

function f:process(msg)
	if msg:find("^PING (.+)$") then
		print(msg)
		local st = msg:match("^PING (.+)$")
		self.con:send("PONG "..st)
		print("PONG "..st)

	elseif msg:find("^:%S+ (%d+)") then
		local num = msg:match("^:%S+ (%d+)")
		if num == "001" then
			--[[
			if password then
				self:send("PRIVMSG NickServ :IDENTIFY "..password)
			end
			]]
		end
		
	elseif msg:find("^:%S+ JOIN (%S+)$") then
		local name, channel = msg:match("^:.-~(%S-)@.- JOIN (%S+)$")
		if name == f.name then
			print("making new channel: "..channel)
			self:NewChannel(channel)
		else
			f:print(channel, name.." has joined.")
		end
	elseif msg:find("^:%S+ PART (%S-).+$") then
		local name, channel,msg = msg:match("^:.-~(%S-)@.- PART (%S+) *:*(.*)$")
		if name == f.name then
			print("closing channel: "..channel)
			self:DelChannel(channel)
		else
			f:print(channel, name.." has left. "..(msg and "("..msg..")") or "")
		end
	elseif msg:find("(%S+) PRIVMSG (%S+)" ) then
		source, dest,txt = msg:match("^:(%S-)!~%S+@%S+ PRIVMSG (%S+) :(.+)$") 
		if dest:find("^#") then
			f:print(dest, source..": "..txt)
		else
			f:print(source, source..": "..txt)
		end
	else
		f:print("Server",msg)
	end
end

function f:connect(name)
	if name == "" then
		return
	end
	f.name = name
	self.con = socket.tcp()
	
	local succ, err = self.con:connect("irc.freenode.org", 6667)
	self.con:settimeout(0)
	print(succ, err)
	if not succ then
		print(err)
	else
		f:NewChannel("Server")
		self:send("NICK "..name)
		self:send("USER "..name.." unknown unknown unknown")
		f.login:Hide()
		f.main:Show()
		
	end


end

return f