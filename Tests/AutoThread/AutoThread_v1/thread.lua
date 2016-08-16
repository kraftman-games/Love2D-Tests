
require "love.thread"



EVENTS_GET = {}
EVENTS_PEEK = {}

local thread = love.thread.getThread("engine")
 maint = love.thread.getThread("main")

EVENTS = {}

local COMMANDS = {}

function COMMANDS.RUN(data)
	assert(loadstring(data))()
end


while true do
	if thread:peek("RUN") then
		COMMANDS.RUN(thread:get("RUN"))
	end
	
	for event, func in pairs(EVENTS_PEEK) do
		local data = thread:peek(event)
		if data then
			func(data)
		end
	end
				
	for event, func in pairs(EVENTS_GET) do
		local data = thread:get(event)
		if data then
			func(data)
		end
	end
end
