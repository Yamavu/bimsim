-- title:   game title
-- author:  game developer, email, etc.
-- desc:    short description
-- site:    website link
-- license: MIT License (change this to your license of choice)
-- version: 0.1
-- script:  lua

local vectmt = {} vectmt.__index = vectmt local function vect(x, y, z) return setmetatable({ x = tonumber(x) or 0, y = tonumber(y) or 0, z = tonumber(z) or 0 }, vectmt) end function vectmt.__add(self, other) return vect(self.x + other.x, self.y + other.y, self.z + other.z) end function vectmt.__sub(self, other) return vect(self.x - other.x, self.y - other.y, self.z - other.z) end function vectmt.__mul(self, num) return vect(self.x*num, self.y*num, self.z*num) end function vectmt.__div(self, num) return vect(self.x/num, self.y/num, self.z/num) end function vectmt.__unm(self) return vect(-self.x, -self.y, -self.z) end function vectmt.__tostring(self) return ('(%i, %i, %i)'):format(x, Bim.acc, z) end function vectmt.dot(self, other) return self.x*other.x + self.y*other.y + self.z*other.z end function vectmt.cross(self, other) return vect( self.y*other.z - self.z*other.y, self.z*other.x - self.x*other.z, self.x*other.y - self.y*other.x ) end function vectmt.len(self) return math.sqrt(self.x*self.x + self.y*self.y + self.z*self.z) end function vectmt.len2(self) return self.x*self.x + self.y*self.y + self.z*self.z end function vectmt.norm(self) return self:__div(self:len()) end function vectmt.round(self, t) t = t or 1 return vect( math.floor((self.x + t * 0.5) / t) * t, math.floor((self.y + t * 0.5) / t) * t, math.floor((self.z + t * 0.5) / t) * t ) end
Vec3 = vect
Res = vect(240,136)
HalfRes = Res / 2
sound_played = 0
T=0

Friction = 0.98^2

Level= {"S:Station1","S:Station2"}

Bim={}
function Bim:new(o, pos, weight)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.pos = pos or 0
  self.weight = weight or 0
  self.acc = 0
  self.speed = 0
  self.maxspeed = 28
  return o
end
Bim.speedup = function (self)
  self.acc=self.acc+1
  if self.acc > 10 then self.acc = 10 end
end
Bim.speeddown = function (self)
  self.acc=self.acc-1
  if self.acc < 0 then self.acc = 0 end
end
Bim.brake = function (self)
  if self.acc > 0 then
    self.acc = -1
  else
    self.acc = self.acc-1
  end
    
  if self.acc < -10 then self.acc = -10 end
end
Bim.brakeup = function (self)
  self.acc = self.acc+1
  if self.acc > 0 then self.acc = 0 end
end
Bim.update = function (self)
  if self.speed <= 0 and self.acc <= 0 then 
    self.speed = 0
  else 
    self.speed = self.speed + (self.acc / (self.weight/2000))
  end
  if self.speed > self.maxspeed then self.speed = self.maxspeed end
  self.speed = self.speed * Friction
  self.pos = self.pos + self.speed
end
bim = Bim:new(nil,0,30000)


Minimap={
  draw = function ()
    w = 64
    clip(240-w, 136-w,w,w)
    rect(240-w, 136-w,w,w,0)
    print("Station 1", 240-w-80, 136-w, 12, false, 1, true)
    h=10
    for i=0, 10, 2 do
      local y = 136+(bim.pos-(h*i))%(2*w)-w
      rectb(240-w+8,y,w-16,6,12)
      print(string.format("% 3.0f",y), 240-w/2-8, y-3, 10, false, 1, true)
    end
    rect(240-w+14,136-w,4,w,15)
    rect(240-18,136-w,4,w,15)
    rectb(240-w, 136-w,w,w,12)
    line(240-4, 136-32,240-w+4, 136-32,3) -- red
    clip()
    local info = string.format("pos: %.1f, speed: %.1f",bim.pos, bim.speed)
    local info2 = string.format("acc: %.0f",bim.acc)
    print(info, 240-w-100, 136-w+16, 12, false, 1, true)
    print(info2, 240-w-100, 136-w+32, 12)
  end,
}

Cockpit={
  draw = function ()
    
    q = function (c, ... )
      local arg = {...}
      local p1,p2,p3 = nil,nil,nil
      for i = 1, #arg, 2 do
        p1 = p2
        p2 = p3
        p3 = vect(arg[i],arg[i+1],0)
        if p2 ~= nil and p1 ~= nil then
          tri(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, c)
          --print(string.format("tri(%.1f, %.1f, %.1f, %.1f, %.1f, %.1f, %d)",p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, c),10,10*i,12)
        end
      end
      --local center = vect(x3+x2,y3+y2,0)/2
      --local p1 = vect(x1,y1,0)
      --p4 = p1+(center-p1)*2
      --tri(p4.x, p4.y, x2, y2, x3, y3, c)
    end
    q2 = function (c, cx,cy, ... )
      local arg = {...}
      local p1x = nil 
      local p1y = nil
      local p2x = nil
      local p2y = nil
      for i = 3, #arg, 2 do
        p1x, p1y = p2x, p2y
        p2x, p2y = arg[i],arg[i+1]
        if p1x ~= nil and p1y ~= nil then
          tri(p1x, p1y, p2x, p2y, cx, cy, c)
        end
        trace(p1x, p1y, p2x, p2y, cx, cy, c)
      end
    end
    --q(15,15,0,5,0,15,100,25,100,0,120,0,136,60,136,15,0)

    q2(1, 18,40, 26,0, 5,0, 15,100, 32,64, 27,46, 26,5, 26,0, 5,0)
    q2(1,44,100, 32,64, 15,100, 7,110, 0,114, 0,130, 35,108, 63,98, 98,93, 82,90, 50,85, 32,64, 15,100)
    q2(1, 120,90, 98,93, 50,85, 139,88, 146,88, 185,92, 50,85)

  end
}
ran_setup = false

local p1x, p1y, p2x,p2y = nil,1,nil,nil
print(p1x, p1y, p2x,p2y )

function draw()
  if not ran_setup then 
    cls(13)
    Cockpit.draw()
    ran_setup = true
  end
  --Minimap.draw()
end

function update()
  bim.update(bim)
  
end

function sound()
  local pos = math.floor(bim.pos)%10
  if pos == sound_played then return end
  if  pos == 0 and bim.speed > 0 then
    sfx(16,"D-3",5,0,15,4)
  end
  if pos == 2 and bim.speed > 0 then
    sfx(16,"D-3",4,0,15,5)
  end
  sound_played = pos
end

function TIC()

	if btnp(0,20,10) then bim:speedup() end
	if btnp(1,20,10) then bim:speeddown() end
  if btnp(4,20,10) then bim:brake() end
	if btnp(5,20,10) then bim:brakeup() end
	
  update()
  --sound()
	draw()
  
	T=(T+1)%1024
end

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- 016:13c053a09380d360e340f310f300f300f300f300f300f300f300f300f300f300f300f300f300f300f300f300f300f300f300f300f300f300f300f300282000000000
-- </SFX>

-- <TRACKS>
-- 000:100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

