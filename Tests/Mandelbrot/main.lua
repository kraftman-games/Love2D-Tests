resolution =2--if you change it to 1 your will get SUPER resolution but to SUPER lag!

size = 600
kt = 50
m = 4.0
xmin = 1.5
xmax = -0.3
ymin = -1.5
ymax = 1.5
dx = (xmax-xmin)/size
dy = (ymax-ymin)/size

pixels = {}

function MainCalculation()
	tx = wx*wx-(wy*wy+jx)
	ty = 2.0*wx*wy+jy
	wx = tx
	wy = ty
	r = wx*wx+wy*wy --
	k = k+1
	if r<=m and k<kt then 
	MainCalculation()
	end
end

local buffer

function mainloop()
	buffer = love.graphics.newCanvas()
	love.graphics.setCanvas(buffer)
	for x = 0,size,resolution do
		jx = xmin+x*dx
		for y = 0,size,resolution do
			jy = ymin+y*dy
			k = 0
			wx = 0.0
			wy = 0.0
			MainCalculation()
			table.insert(pixels,{X = x, Y = y, C = k,})
		end
	end
	
	for i,v in pairs(pixels) do
		if v.C == 50 then
			love.graphics.setColor(0,0,0,255)
		else
			love.graphics.setColor( v.C/50*255, v.C/50*255, 0, 255 )
		end
		--print(v.C)
		love.graphics.rectangle("fill",v.X,v.Y,resolution,resolution)
	end
	love.graphics.setCanvas()
	if resolution > 2 then
		resolution = resolution -1
		mainloop()
	end
end



mainloop()



function love.mousepressed(x,y,button)
 resolution = 10
 mainloop()
end

function love.mousereleased(x,y,button)
	
end

function love.draw()
	love.graphics.setColor( 255, 255, 255, 255 )
	love.graphics.draw(buffer,0,0)
	love.graphics.print(love.timer.getFPS(), 400, 400)

end
