-- title:   game title
-- author:  game developer, email, etc.
-- desc:    short description
-- site:    website link
-- license: MIT License (change this to your license of choice)
-- version: 0.1
-- script:  lua

function ms_kmh(s)
	return 3.6*s
end

function clamp(x,x_min,x_max)
	if x>x_max then
		return x_max
	elseif x<x_min then
		return x_min
	else
	 return x
	end
end

trace(clamp(10,0,50))
trace(clamp(0,0,50))
trace(clamp(100,0,50))

Track={
	airResistance = 0.0, -- 1.161 = (0.5)*0.3*1.29*6
	friction = 2
}
function Track:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end
function Track:update(loc)
	
end
function Track:draw(loc,y)
	loc = 2* loc
	circ(20,80,2,12)
	circ(220,80,2,12)
	line(20,80,220,80,12)
	circb(20+loc,80,5-(T//10)%3,12)
	circ(20+loc,80,2,2)
	y=y/2
	line(20+loc,70,20+loc,70-y,4)
end

load=0.5
throttle = 0-- Acceleration/braking input, range: [-1, 1]

local Bim = {
 weight = 22300+8000/load, -- kg
 length = 19.7, -- meters
 maxSpeed = 20, -- m/s
 acceleration = 2, -- m/s^2
 brakeDeceleration = 4, -- m/s^2
 
 position = 0,
 velocity = 0,
}
function Bim:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end


function Bim:update()
	local acceleration = 0
	if throttle > 0 then
		acceleration = throttle * Bim.acceleration
	elseif throttle < 0 then
		acceleration = throttle * Bim.brakeDeceleration
	end
	local airResistanceForce = Track.airResistance * self.velocity^2  / self.weight
	local frictionForce = Track.friction 
	local newAcceleration = (acceleration - Track.friction) - airResistanceForce
	print(string.format("(%.1f - %.1f ) - %.1f = %.1f",acceleration,frictionForce, airResistanceForce,newAcceleration),10,32)
	self.velocity = self.velocity + newAcceleration / 60
	self.velocity = 
		math.min(
			math.max(
				self.velocity,
				-self.maxSpeed
			),
			self.maxSpeed
		)
	self.position = self.position + self.velocity / 60
	if self.position>200 then 
		self:reset()
	end
end
function Bim:reset()
	self.position = 0
	self.velocity = 0
end
function update()
	if btnp(0,5,5) then throttle = throttle + 1 end
	if btnp(1,5,5) then throttle = throttle - 1 end
	throttle = clamp(throttle,-10,10)
	Bim:update()
	Track:update(Bim.position)
end
T=0
function draw()
	print(string.format("speed = %.1f",ms_kmh(Bim.velocity)),10,10)
	print(string.format("x = %.1f",Bim.position),10,16)
	print(string.format("p = %d",throttle),10,22)
	Track:draw(Bim.position,Bim.velocity)
end

cls(0)
function TIC()
	clip(0,0,240,40)
	cls(14)
	clip(0,74,240,136)
	cls(14)
	clip()
	update()
	draw()
	T=T+1
end

-- <TILES>
-- 001:eccccccccc888888caaaaaaaca888888cacccccccacc0ccccacc0ccccacc0ccc
-- 002:ccccceee8888cceeaaaa0cee888a0ceeccca0ccc0cca0c0c0cca0c0c0cca0c0c
-- 003:eccccccccc888888caaaaaaaca888888cacccccccacccccccacc0ccccacc0ccc
-- 004:ccccceee8888cceeaaaa0cee888a0ceeccca0cccccca0c0c0cca0c0c0cca0c0c
-- 017:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 018:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- 019:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 020:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- </TILES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <TRACKS>
-- 000:100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

