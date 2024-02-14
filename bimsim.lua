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
  ngon = function (c, b, cx,cy, ... )
    local arg = {...}
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
        --trace(string.format("(%.0f, %.0f) (%.0f, %.0f) (%.0f, %.0f)",cx, cy, p1x, p1y, p2x, p2y))
      end
    end
    tri(cx, cy, p2x, p2y, arg[1], arg[2],  c)
    --trace(string.format("(%.0f, %.0f) (%.0f, %.0f) (%.0f, %.0f)",cx, cy, p2x, p2y,arg[1], arg[2]))
  end,
  tachometer = function (t_x,t_y, bimspeed)
    rect(t_x,t_y,15,15,15)
    circ(t_x,t_y,14,12)
    circb(t_x,t_y,14,15)
    a=bimspeed/8-4
    tri(t_x-math.cos(a-math.pi/2), t_y-math.sin(a-math.pi/2), t_x+math.cos(a-math.pi/2), t_y+math.sin(a-math.pi/2), t_x+10*math.cos(a), t_y+10*math.sin(a),3)
    trib(t_x-math.cos(a-math.pi/2), t_y-math.sin(a-math.pi/2), t_x+math.cos(a-math.pi/2), t_y+math.sin(a-math.pi/2), t_x+10*math.cos(a), t_y+10*math.sin(a),2)
  end,
  draw = function ()
    Cockpit.ngon(15,0, 20,100, 
      20,-1, 23,58, 27,70, 35,86, 43,94, 55,100, 70,104, 
      70,136, -1,136,
      -1,104, 8,98, 12,90, 13,-1
    )
    Cockpit.ngon( 15,0, 145,50,
      139,104, 151,0, 156,0, 142,104
    )
    spr(259,88,96,11,1,0,0,4,3)
    Cockpit.tachometer(224,98,bim.speed)
  end,
  setup = function ()
    rect(210,104,30,13,15)
    rect(61,117,179,19,4)
    Cockpit.ngon( 7,0, 185,110,
      77,104, 209,104, 240,116, 200,136, 172,130, 162,117, 77,117)
    Cockpit.ngon( 7,0, 44,110,
      77,104,
      70,104, 0,112, 0,136, 61,136, 
      77,117)
    spr(259,88,96,11,1,0,0,4,3)
    spr(320,78,117,11,1,0,0,8,3)


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

cls(15)
Cockpit.setup()

function draw()
  
  clip(0,0,240,104)
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
-- 002:000000ff00000000000000000000000000000000000000000000000000000000
-- 003:ffffffff00000000000000000005544400045555000f0fff0000000000000000
-- 004:ffffffff000000000000000044c400004444000011f000000000000000000000
-- 005:ffffffff0000000000000000ee0df0eddd0dd0ddff0ff0ffdd0dd0ddde0ee0ee
-- 006:fffe0bbb00000bbb00000bbb00000bbb00000bbb00000bbb00000bbb00f00bbb
-- 018:000000ff000000f0000000000000000000000000000000000000000000000000
-- 019:00ddfdde00ddfddd0000000000ddfdde00d20dde0000000000eede0000eeeeee
-- 020:dedd0dd04dd4fd3000000000cdd6ed60ddd7ed700000000000000f00eeee00fe
-- 021:dd0dd0dddd0dc0dd00000000dc0cc0cccc0cc0cc0000000000000000eeeeeeee
-- 022:00e00bbb00000bbb00000bbb00000bbb00000bbb00000bbb00000bbbd0000bbb
-- 032:fffffffffeeeeeeefe332ee4fe332ee4fe222ee3feeeeeeefecc5ee5fecc5ee5
-- 033:ffffffffeeeeeeee43eecc4e43eecc4e33ee444eeeeeeeee56eebbae56eebbae
-- 034:ffffff00eeeeeffeeaa9efefeaa9ef00e999ef00eeeeef00eaadef00eaadef00
-- 035:b00fffffbb000fffbbb00000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 036:ffee00feffeef0ee00000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 037:eeeeeee0eeeeef0b0000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 038:00bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 048:fe555ee6feeeeeeefeeeeeff0000000000000000000000000000000000000000
-- 049:66eeaaaeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
-- 050:edddef00eeeeef00eeeeefee0000000000000000000000000000000000000000
-- 051:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 052:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 053:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 054:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 064:f0000fff0f0000000000000000000000000000000000000e000000fd000000fe
-- 065:ffffffff00000000000000000000000000000000ede00000dde000eeddd00fee
-- 066:ffffffff000000000000666000006660000000000f0000f007f70077f7f7f077
-- 067:ffffffff00000000000000fc000000fd000000000000aca0070bccc9770cccc9
-- 068:eeeeeeee00000000ce000000de0000000000000009c900229ccc903cdcccb04c
-- 069:eeeeeeee0000000000000000000000000000000022300000cc401111cc402111
-- 070:eeeeeeee00000f0000000000000000000e0000000f0001000f0000000e000000
-- 071:eeefffff0000000000000000000ff00000ee0e0000e0000000e0000000011e00
-- 072:f11ee11100000000000000000000000000000000000000000000000000000000
-- 073:ffffffff000000ff0000000f0000000f00e0000f0243000f0132000f00220000
-- 074:5555555555555555555555555555555555555555555555555555555555555555
-- 080:000000000000000000000000000000000000eddd0000dede0000ed000000dd00
-- 081:00000fdf000000000000000000000000edddf000fdddf00000fdf0ff000df000
-- 082:0ff7f07f00000000000000000000000000000000000000000ede000d0edef0ed
-- 083:f70dccb00000db0000000000000000000000000000000000d000ed00de0f22d0
-- 084:0ccc80cc00c800030000000000000000000000000000000008d8000d0e9900e0
-- 085:cc30111133f00000000000000000000000000000000000f0dd0000f000f000f0
-- 086:0e00000000000000000000000000000000000000000000000000000000000000
-- 087:000000000000000000000000000000000000f0000f00000f000ffdd000000cce
-- 088:00000000000000000000fe000000000000f0000000f0000000f0000000e00000
-- 089:000000000fff0000000000000000000000000000000000000000000000000000
-- 090:5555555555555555555555555555555555555555555555555555555555555555
-- 096:0000d1000000100000000000000000ee00000000000000000000000055555555
-- 097:000d000f00fd000000ee0000eeee0efe00000000000000000000000055555555
-- 098:0dd700f600f0000000000000e000000000000000000000000000000055555555
-- 099:d00022f000000000000000000000fef000000000000000000000000055555555
-- 100:099900e000800000000000000ffee00f00000000000000000000000055555555
-- 101:000000000000000000000000f000000000000000000000000000000055555555
-- 102:0000000000000000000000000000000000000f00000000000000000055555555
-- 103:00000cce00000000000000000000000000000000000000000000000055555555
-- 104:00ef000f00ee00ff00ff00ff000000000000ff00000000000000000055555555
-- 105:0000000000000000ff0000000000000000000000000000000000000055555555
-- 106:5555555555555555555555555555555555555555555555555555555555555555
-- 112:5555555555555555555555555555555555555555555555555555555555555555
-- 113:5555555555555555555555555555555555555555555555555555555555555555
-- 114:5555555555555555555555555555555555555555555555555555555555555555
-- 115:5555555555555555555555555555555555555555555555555555555555555555
-- 116:5555555555555555555555555555555555555555555555555555555555555555
-- 117:5555555555555555555555555555555555555555555555555555555555555555
-- 118:5555555555555555555555555555555555555555555555555555555555555555
-- 119:5555555555555555555555555555555555555555555555555555555555555555
-- 120:5555555555555555555555555555555555555555555555555555555555555555
-- 121:5555555555555555555555555555555555555555555555555555555555555555
-- 122:5555555555555555555555555555555555555555555555555555555555555555
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

