

local function routine(points, maxpoints, ratio)
	add = 0
	for point = 1, #points-1 do
		if #points == maxpoints then break end
		point = point+add
		table.insert(points, point+1, (points[point]+points[point+1])/2+math.random(-ratio,ratio))
		add = add+1
	end
end

function PlotPoints(smoothness, maxpoints, left, right)
	local points = {0,50,50,-50,-100,-100,-50,50,50,0}
	
	ratio = math.floor((9^2-1)/(smoothness / 10))
	while #points < maxpoints-1 do
		routine(points,maxpoints, ratio)
		ratio = ratio/2
	end
	return points
end

local b = PlotPoints(80, 400, 0, -40)



function love.draw()
	
	for i = 1, #b - 1 do
		love.graphics.line(i+200, math.floor(b[i]+0.5)+250, i+201, math.floor(b[i+1]+0.5)+250)
	end
end