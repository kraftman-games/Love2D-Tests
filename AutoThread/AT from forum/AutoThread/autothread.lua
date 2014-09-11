local test = love.filesystem.newFileData([[
runGet = {}
runPeek = {}

 sub_thread = love.thread.getThread()
 main_thread = love.thread.getThread("main")


function run(data)
	assert(loadstring(data))()
end


while true do
	if sub_thread:peek("RUN") then
		run(sub_thread:get("RUN"))
	end
	
	for event, func in pairs(runPeek) do
		local data = sub_thread:peek(event)
		if data then
			func(data)
		end
	end
				
	for event, func in pairs(runGet) do
		local data = sub_thread:get(event)
		if data then
			func(data)
		end
	end
end]], "subthread","file")

runGet = {}
runPeek = {}
THREAD_ERRORS = {}

local main_thread = love.thread.getThread("main")

local threads = {}

local function run(thread, data)
	local msg = thread:peek("RUN")
	if msg then
		msg = msg.."\n"..data
	else
		msg = data
	end
	thread:set("RUN", msg)
end

function newThread(name)
	local t = love.thread.newThread(name, test)
	getmetatable(t).run = run
	threads[name] = t
	return t
end



local er
function updateThreads()
	for name, thread in pairs(threads) do
		THREAD_ERRORS[name] = thread:peek("error")
	end
	

	for event, func in pairs(runPeek) do
		local data = main_thread:peek(event)
		if data then
			func(data)
		end
	end

	for event, func in pairs(runGet) do
		local data = main_thread:get(event)
		if data then
			func(data)
		end
	end
end
