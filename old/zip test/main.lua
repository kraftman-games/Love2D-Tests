
require "lua51"
require "zip"

local zfile, err = zip.open(love.filesystem.getWorkingDirectory()..'/test.love')


function test()
	if zfile then
		for file in zfile:files() do
			--local test = io.open(love.filesystem.getSaveDirectory().."/newtest/"..file.filename, "wb")
			local test = love.filesystem.newFile("newtest/"..file.filename)
			test:open("w")
			test:write(zfile:open(file.filename):read("*a"))
			test:close()
		end
	end
end

test()

function love.draw()
	love.graphics.print(love.filesystem.getSaveDirectory(),20,40)

end