
local printQueue = {}
local thisThread = love.thread.getThread()

local function print(text)
	table.insert( printQueue, text )
end

local function printSomething()
	print('printer thread')
	print('hello')
	print('world')
end

local function sendPrints()
	if #printQueue > 0 and not thisThread:peek('print') then
		local prints = table.concat( printQueue, "\n" )
		thisThread:set('print', prints)
		printQueue = {}
	end
end

while true do
	printSomething()
	sendPrints()
end