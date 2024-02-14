-- title:   game title
-- author:  game developer, email, etc.
-- desc:    short description
-- site:    website link
-- license: MIT License (change this to your license of choice)
-- version: 0.1
-- script:  lua

function kmh_ms60(s)
	return s/216
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

Track={}
function Track:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end
function Track:update(loc)
	if bim.x>200 then 
		reset()
	end
end
function Track:draw(loc)
	loc = bim.x
	circ(20,80,2,12)
	circ(220,80,2,12)
	line(20,80,220,80,12)
	circb(20+loc,80,5-(T//10)%3,12)
	circ(20+loc,80,2,2)
end

Bim={}
function Bim:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end
function Bim:update()
	local max_v = 50
	local drag = 0.5*0.3*1.29*6*self.v^2
	local friction = 10
	local length = 19.7 /10
	local air_resistance = drag / 1000 --0.075
	local mass= self.m*1000
	self.v = self.v + p / 10
	self.v = (self.v - (friction / mass) + (length / mass))
	 * (1 - air_resistance * 1000 / mass )
	print(string.format("drag = %.1f",drag^0.5),240-8*10,22)
	--self.v = (self.v + p)*0.98^2
	self.v = clamp(self.v,0,max_v)
--	trace(self.v)
	self.x = self.x + kmh_ms60(self.v)
end
function Bim:reset()
	bim.x = 0
	bim.v = 0		
end
load=0.5
bim=Bim:new{x=0,v=0,m=22.3+8/load}
p=0
function update()
	if btnp(0,5,5) then p = p + 1 end
	if btnp(1,5,5) then p = p - 1 end
	p = clamp(p,0,10)
	bim:update()
	Track:update(bim.x)
end
T=0
function draw()
	print(string.format("speed = %.1f",bim.v),10,10)
	print(string.format("x = %.1f",bim.x),10,16)
	print(string.format("p = %d",p),10,22)
	Track:draw()
end

function TIC()
	cls(14)
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

