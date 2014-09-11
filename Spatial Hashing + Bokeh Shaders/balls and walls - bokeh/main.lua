

effect = love.graphics.newPixelEffect [[
uniform sampler2D bgl_RenderedTexture;
uniform sampler2D bgl_DepthTexture;
uniform float bgl_RenderedTextureWidth;
uniform float bgl_RenderedTextureHeight;

#define PI  3.14159265

float width = bgl_RenderedTextureWidth; //texture width
float height = bgl_RenderedTextureHeight; //texture height

vec2 texel = vec2(1.0/width,1.0/height);

//uniform variables from external script

uniform float focalDepth;  //focal distance value in meters, but you may use autofocus option below
uniform float focalLength; //focal length in mm
uniform float fstop; //f-stop value
uniform bool showFocus; //show debug focus point and focal range (red = focal point, green = focal range)

/* 
make sure that these two values are the same for your camera, otherwise distances will be wrong.
*/

float znear = 0.1; //camera clipping start
float zfar = 100.0; //camera clipping end

//------------------------------------------
//user variables

int samples = 4; //samples on the first ring
int rings = 7; //ring count

bool manualdof = false; //manual dof calculation
float ndofstart = 1.0; //near dof blur start
float ndofdist = 2.0; //near dof blur falloff distance
float fdofstart = 1.0; //far dof blur start
float fdofdist = 3.0; //far dof blur falloff distance

float CoC = 0.03;//circle of confusion size in mm (35mm film = 0.03mm)

bool vignetting = true; //use optical lens vignetting?
float vignout = 1.3; //vignetting outer border
float vignin = 0.0; //vignetting inner border
float vignfade = 22.0; //f-stops till vignete fades

bool autofocus = false; //use autofocus in shader? disable if you use external focalDepth value
vec2 focus = vec2(0.5,0.5); // autofocus point on screen (0.0,0.0 - left lower corner, 1.0,1.0 - upper right)
float maxblur = 1.0; //clamp value of max blur (0.0 = no blur,1.0 default)

float threshold = 0.5; //highlight threshold;
float gain = 25.0; //highlight gain;

float bias = 1.0; //bokeh edge bias
float fringe = 2.5; //bokeh chromatic aberration/fringing

bool noise = true; //use noise instead of pattern for sample dithering
float namount = 0.0001; //dither amount

bool depthblur = false; //blur the depth buffer?
float dbsize = 1.25; //depthblursize

/*
next part is experimental
not looking good with small sample and ring count
looks okay starting from samples = 4, rings = 4
*/

bool pentagon = false; //use pentagon as bokeh shape?
float feather = 0.4; //pentagon shape feather

//------------------------------------------


float penta(vec2 coords) //pentagonal shape
{
	float scale = float(rings) - 1.3;
	vec4  HS0 = vec4( 1.0,         0.0,         0.0,  1.0);
	vec4  HS1 = vec4( 0.309016994, 0.951056516, 0.0,  1.0);
	vec4  HS2 = vec4(-0.809016994, 0.587785252, 0.0,  1.0);
	vec4  HS3 = vec4(-0.809016994,-0.587785252, 0.0,  1.0);
	vec4  HS4 = vec4( 0.309016994,-0.951056516, 0.0,  1.0);
	vec4  HS5 = vec4( 0.0        ,0.0         , 1.0,  1.0);
	
	vec4  one = vec4( 1.0 );
	
	vec4 P = vec4((coords),vec2(scale, scale)); 
	
	vec4 dist = vec4(0.0);
	float inorout = -4.0;
	
	dist.x = dot( P, HS0 );
	dist.y = dot( P, HS1 );
	dist.z = dot( P, HS2 );
	dist.w = dot( P, HS3 );
	
	dist = smoothstep( -feather, feather, dist );
	
	inorout += dot( dist, one );
	
	dist.x = dot( P, HS4 );
	dist.y = HS5.w - abs( P.z );
	
	dist = smoothstep( -feather, feather, dist );
	inorout += dist.x;
	
	return clamp( inorout, 0.0, 1.0 );
}

float bdepth(vec2 coords) //blurring depth
{
	float d = 0.0;
	float kernel[9];
	vec2 offset[9];
	
	vec2 wh = vec2(texel.x, texel.y) * dbsize;
	
	offset[0] = vec2(-wh.x,-wh.y);
	offset[1] = vec2( 0.0, -wh.y);
	offset[2] = vec2( wh.x -wh.y);
	
	offset[3] = vec2(-wh.x,  0.0);
	offset[4] = vec2( 0.0,   0.0);
	offset[5] = vec2( wh.x,  0.0);
	
	offset[6] = vec2(-wh.x, wh.y);
	offset[7] = vec2( 0.0,  wh.y);
	offset[8] = vec2( wh.x, wh.y);
	
	kernel[0] = 1.0/16.0;   kernel[1] = 2.0/16.0;   kernel[2] = 1.0/16.0;
	kernel[3] = 2.0/16.0;   kernel[4] = 4.0/16.0;   kernel[5] = 2.0/16.0;
	kernel[6] = 1.0/16.0;   kernel[7] = 2.0/16.0;   kernel[8] = 1.0/16.0;
	
	
	for( int i=0; i<9; i++ )
	{
		float tmp = texture2D(bgl_DepthTexture, coords + offset[i]).r;
		d += tmp * kernel[i];
	}
	
	return d;
}


vec3 color(vec2 coords,float blur) //processing the sample
{
	vec3 col = vec3(0.0);
	
	col.r = texture2D(bgl_RenderedTexture,coords + vec2(0.0,1.0)*texel*fringe*blur).r;
	col.g = texture2D(bgl_RenderedTexture,coords + vec2(-0.866,-0.5)*texel*fringe*blur).g;
	col.b = texture2D(bgl_RenderedTexture,coords + vec2(0.866,-0.5)*texel*fringe*blur).b;
	
	vec3 lumcoeff = vec3(0.299,0.587,0.114);
	float lum = dot(col.rgb, lumcoeff);
	float thresh = max((lum-threshold)*gain, 0.0);
	return col+mix(vec3(0.0),col,thresh*blur);
}

vec2 rand(vec2 coord) //generating noise/pattern texture for dithering
{
	float noiseX = ((fract(1.0-coord.s*(width/2.0))*0.25)+(fract(coord.t*(height/2.0))*0.75))*2.0-1.0;
	float noiseY = ((fract(1.0-coord.s*(width/2.0))*0.75)+(fract(coord.t*(height/2.0))*0.25))*2.0-1.0;
	
	if (noise)
	{
		noiseX = clamp(fract(sin(dot(coord ,vec2(12.9898,78.233))) * 43758.5453),0.0,1.0)*2.0-1.0;
		noiseY = clamp(fract(sin(dot(coord ,vec2(12.9898,78.233)*2.0)) * 43758.5453),0.0,1.0)*2.0-1.0;
	}
	return vec2(noiseX,noiseY);
}

vec3 debugFocus(vec3 col, float blur, float depth)
{
	float edge = 0.002*depth; //distance based edge smoothing
	float m = clamp(smoothstep(0.0,edge,blur),0.0,1.0);
	float e = clamp(smoothstep(1.0-edge,1.0,blur),0.0,1.0);
	
	col = mix(col,vec3(1.0,0.5,0.0),(1.0-m)*0.6);
	col = mix(col,vec3(0.0,0.5,1.0),((1.0-e)-(1.0-m))*0.2);

	return col;
}

float linearize(float depth)
{
	return -zfar * znear / (depth * (zfar - znear) - zfar);
}

float vignette()
{
	float dist = distance(gl_TexCoord[3].xy, vec2(0.5,0.5));
	dist = smoothstep(vignout+(fstop/vignfade), vignin+(fstop/vignfade), dist);
	return clamp(dist,0.0,1.0);
}

vec4 effect(vec4 colour, Image texture, vec2 texture_coords, vec2 pixel_coords)
{
	//scene depth calculation
	
	float depth = linearize(texture2D(bgl_DepthTexture,gl_TexCoord[0].xy).x);
	
	if (depthblur)
	{
		depth = linearize(bdepth(gl_TexCoord[0].xy));
	}
	
	//focal plane calculation
	
	float fDepth = focalDepth;
	
	if (autofocus)
	{
		fDepth = linearize(texture2D(bgl_DepthTexture,focus).x);
	}
	
	//dof blur factor calculation
	
	float blur = 0.0;
	
	if (manualdof)
	{    
		float a = depth-fDepth; //focal plane
		float b = (a-fdofstart)/fdofdist; //far DoF
		float c = (-a-ndofstart)/ndofdist; //near Dof
		blur = (a>0.0)?b:c;
	}
	
	else
	{
		float f = focalLength; //focal length in mm
		float d = fDepth*1000.0; //focal plane in mm
		float o = depth*1000.0; //depth in mm
		
		float a = (o*f)/(o-f); 
		float b = (d*f)/(d-f); 
		float c = (d-f)/(d*fstop*CoC); 
		
		blur = abs(a-b)*c;
	}
	
	blur = clamp(blur,0.0,1.0);
	
	// calculation of pattern for ditering
	
	vec2 noise = rand(gl_TexCoord[0].xy)*namount*blur;
	
	// getting blur x and y step factor
	
	float w = (1.0/width)*blur*maxblur+noise.x;
	float h = (1.0/height)*blur*maxblur+noise.y;
	
	// calculation of final color
	
	vec3 col = vec3(0.0);
	
	if(blur < 0.05) //some optimization thingy
	{
		col = texture2D(bgl_RenderedTexture, gl_TexCoord[0].xy).rgb;
	}
	
	else
	{
		col = texture2D(bgl_RenderedTexture, gl_TexCoord[0].xy).rgb;
		float s = 1.0;
		int ringsamples;
		
		for (int i = 1; i <= rings; i += 1)
		{   
			ringsamples = i * samples;
			
			for (int j = 0 ; j < ringsamples ; j += 1)   
			{
				float step = PI*2.0 / float(ringsamples);
				float pw = (cos(float(j)*step)*float(i));
				float ph = (sin(float(j)*step)*float(i));
				float p = 1.0;
				if (pentagon)
				{ 
					p = penta(vec2(pw,ph));
				}
				col += color(gl_TexCoord[0].xy + vec2(pw*w,ph*h),blur)*mix(1.0,(float(i))/(float(rings)),bias)*p;  
				s += 1.0*mix(1.0,(float(i))/(float(rings)),bias)*p;   
			}
		}
		col /= s; //divide by sample count
	}
	
	if (showFocus)
	{
		col = debugFocus(col, blur, depth);
	}
	
	if (vignetting)
	{
		col *= vignette();
	}
	return vec4(col, 1.0);
	//gl_FragColor.rgb = col;
	//gl_FragColor.a = 1.0;
}
]]


    
	
	
	
	local fd = 0.5
	local fs = 37
	local fl = 12
	
	effect:send("bgl_RenderedTextureWidth", 800.0)
	effect:send("bgl_RenderedTextureHeight", 600.0)
	
	
	effect:send("focalDepth", 1)
	effect:send("focalLength", 50)
	effect:send("fstop", 5)
	effect:send("showFocus", 1)
	

local depth = love.graphics.newCanvas()
local colours = love.graphics.newCanvas()








local lg = love.graphics
local rand = math.random
local abs = math.abs
local sin = math.sin


local scwidth = 800
local scheight = 600


local balls = {}


local mb = {}


function love.load()
	balls = {}
end

function mb:mobilecollision(nx,ny)
	for i = 1, #balls do
		if i ~= self.index then
		
		end
	end
	return nx, ny
end

function mb:update(dt)
	
	self.counter = self.counter + dt
	local newx, newy

	newx = self.x + self.vx*dt
	newy = self.y + self.vy *dt

	if self.x-self.r < 0 then
		newx = -(newx-self.r) +self.r
		self.vx = -self.vx
	elseif newx+self.r > scwidth then
		newx = scwidth - (newx-scwidth+self.r) -self.r
		self.vx = -self.vx
	end

	if newy-self.r < 0 then
		newy = -(newy-self.r) +self.r
		self.vy = -self.vy
	elseif newy+self.r > scheight then
		newy = scheight - (newy-scheight+self.r) -self.r
		self.vy = -self.vy
	end
	
	


	self.x = newx
	self.y = newy
end

function mb:drawdepth()
	self.depth = sin(self.counter)*127  + 127
	love.graphics.setColor(self.depth, self.depth, self.depth,255)
	love.graphics.circle("fill", self.x, self.y, self.r, 10)
end

function mb:draw()
	love.graphics.setColor(self.color)
	love.graphics.circle("fill", self.x, self.y, self.r, 10)
end


function mb:new()
	local b = {}
	local x, y = love.mouse.getPosition()
	b.x = x
	b.y = y
	b.vx = rand(-50,50)
	b.vy = rand(-50,50)
	b.r = rand(5,10)
	b.color = {rand(0,255), rand(0,255), rand(0,255),255}
	b.counter = rand(1,100)
	b.update = mb.update
	b.draw = mb.draw
	b.drawdepth = mb.drawdepth
	table.insert(balls, b)
	b.index = #balls

end


function love.mousereleased()
	mb:new()
end

function love.update(dt)
	if love.keyboard.isDown("w") then
		fd = fd + 0.1
	elseif love.keyboard.isDown("s") then
		fd = fd - 0.1
	end
	effect:send("focalDepth", fd)
	
	if love.keyboard.isDown("e") then
		fs = fs + 0.1
	elseif love.keyboard.isDown("d") then
		fs = fs - 0.1
	end
	effect:send("fstop", fs)
	
	if love.keyboard.isDown("r") then
		fl = fl + 0.1
	elseif love.keyboard.isDown("f") then
		fl = fl - 0.1
	end
	effect:send("focalLength", fl)


	for i = 1, #balls do
		balls[i]:update(dt)
	end
end

function love.draw()
	
	lg.setColor(0,0,0,255)
	love.graphics.setCanvas(depth)
	depth:clear()
	love.graphics.rectangle("fill", 0,0,800,600)
		for i = 1, #balls do
			balls[i]:drawdepth()
		end
	love.graphics.setCanvas()
	love.graphics.draw(depth, 0, 0)
	effect:send("bgl_DepthTexture", depth)
	
	
	colours:clear()
	love.graphics.setCanvas(colours)
	love.graphics.setColor(0,0,0,255)
	--love.graphics.rectangle("fill", 0, 0, 800, 600)
	for i = 1, #balls do
		balls[i]:draw()
	end
	lg.setColor(255,255,255,255)
	love.graphics.setCanvas()
	love.graphics.setPixelEffect(effect)
	love.graphics.draw(colours, 0,0)
	
	 
	  love.graphics.setPixelEffect()
	lg.print("FPS: "..love.timer.getFPS(), 10 ,10)
	lg.print("Balls: "..#balls, 10 , 30)
	lg.print("Focal depth: "..fd, 10 ,50)
	lg.print("Focal length: "..fl, 10 , 70)
	lg.print("FStop: "..fs, 10, 90)
	 
end






