
local printerThread
local time

local function printTextFromPrinterThread()
	local printText = printerThread:get('print')
	if printText then
		print(printText)
	end
end

function love.load()
	printerThread = love.thread.newThread( 'printerThread', 'printer.lua' )
	printerThread:start()
	time = 0
end

function love.update( dt )
	time = time + dt
	print('main thread')
	printTextFromPrinterThread()
end

function love.draw()
	local timeLabel = string.format( "%03.2i", time )
	love.graphics.print( timeLabel, 10, 10 )
end