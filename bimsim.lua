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
    
    q = function (c, b, cx,cy, ... )
      local arg = {...}
      trace(#arg)
      local p1x = nil 
      local p1y = nil
      local p2x = nil
      local p2y = nil
      for i = 1, #arg, 2 do
        p1x, p1y = p2x, p2y
        p2x, p2y = arg[i],arg[i+1]
        if p1x ~= nil and p1y ~= nil then
          tri(cx, cy, p1x, p1y, p2x, p2y,  c)
          line(p1x, p1y, p2x, p2y, b)
          trace(string.format("(%.0f, %.0f) (%.0f, %.0f) (%.0f, %.0f)",cx, cy, p1x, p1y, p2x, p2y))
        end
      end
      tri(cx, cy, p2x, p2y, arg[1], arg[2],  c)
      trace(string.format("(%.0f, %.0f) (%.0f, %.0f) (%.0f, %.0f)",cx, cy, p2x, p2y,arg[1], arg[2]))
    end
	q(15, 0, 214,130,
      0,136, 0,115, 98,92, 238,92, 240,94, 240,136
    )
    q( 14, 15, 
       25,100, 5,0, 14,94, 10,104, -1,110, 
      -1,124, 21,112, 44,105,  108,93, 108,90, 
      50,85, 32,64, 27,46, 26,0
    )
    q(12,15, 145,45, 145,0, 140,90, 145,90, 155,0)
    q(14, 15, 214,90,
      220,85, 174,86, 108,90, 108,93, 160,100,
      171, 115, 192,126, 227,115, 238,92, 225,85, 224,91, 220,85
      
    )
    
    
    spr(288,100,80, 0, 2,0,0,3,2)
    rect(86,105,72,24,14)
    t_x,t_y = 211,74
    rect(t_x,t_y,14,18,15)
    elli(t_x,t_y,14,18,12)
    ellib(t_x,t_y,14,18,15)
    a=bim.speed/8-4
    tri(t_x-math.cos(a-math.pi/2), t_y-math.sin(a-math.pi/2), t_x+math.cos(a-math.pi/2), t_y+math.sin(a-math.pi/2), 211+10*math.cos(a), 74+10*math.sin(a),3)
    trib(t_x-math.cos(a-math.pi/2), t_y-math.sin(a-math.pi/2), t_x+math.cos(a-math.pi/2), t_y+math.sin(a-math.pi/2), 211+10*math.cos(a), 74+10*math.sin(a),2)
    --line(t_x,t_y,211+10*math.cos(a), 74+10*math.sin(a),3)
    
    --q2(1, 0, 20,112, 14,100, -1,114, -1,124, 21,112, 44,105,  108,93, 108,90, 50,85)--,0,130)
    --q2(3, 0, 44,105, 32,64, 63,98, 98,93, 98,90, 50,85)
    --q2(1, 0, 120,90, 98,93, 98,90, 139,88, 139,91)
    --q2(12,0, 100,60, 139,88, 139,91, 146,88, 185,92)

  end
}

local p1x, p1y, p2x,p2y = nil,1,nil,nil
print(p1x, p1y, p2x,p2y )

function drawpt(x,y)
  circb(x,y,3,4)
  if x > 200 then
    print(string.format("(%d, %d)",x,y),x-40,y, 4, false, 1, true)
  else
    print(string.format("(%d, %d)",x,y),x+8,y, 4, false, 1, true)
  end
end

pts = {}
function draw()
  cls(13)
  Cockpit.draw()
  local x,y,click = mouse()
  drawpt(x,y)
  for i=1,#pts,2 do
    drawpt(pts[i],pts[i+1])
  end
  if click then
    table.insert(pts, x)
    table.insert(pts, y)
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

-- <SPRITES>
-- 032:fffffffffeeeeeeefe332ee4fe332ee4fe222ee3feeeeeeefecc5ee5fecc5ee5
-- 033:ffffffffeeeeeeee43eecc4e43eecc4e33ee444eeeeeeeee56eebbae56eebbae
-- 034:ffffff00eeeeef00eaa9ef00eaa9ef00e999ef00eeeeef00eaadef00eaadef00
-- 048:fe555ee6feeeeeeefeeeeeffffffffff00000000000000000000000000000000
-- 049:66eeaaaeeeeeeeeeeeeeeeeeffffffff00000000000000000000000000000000
-- 050:edddef00eeeeef00eeeeef00ffffff0000000000000000000000000000000000
-- </SPRITES>

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

