-- title:   game title
-- author:  game developer, email, etc.
-- desc:    short description
-- site:    website link
-- license: MIT License (change this to your license of choice)
-- version: 0.1
-- script:  lua

local vectmt = {}
vectmt.__index = vectmt
local function vect(x, y, z)
  return setmetatable({ x = tonumber(x) or 0, y = tonumber(y) or 0, z = tonumber(z) or 0 },
    vectmt)
end
function vectmt.__add(self, other) return vect(self.x + other.x, self.y + other.y, self.z + other.z) end

function vectmt.__sub(self, other) return vect(self.x - other.x, self.y - other.y, self.z - other.z) end

function vectmt.__mul(self, num) return vect(self.x * num, self.y * num, self.z * num) end

function vectmt.__div(self, num) return vect(self.x / num, self.y / num, self.z / num) end

function vectmt.__unm(self) return vect(-self.x, -self.y, -self.z) end

function vectmt.__tostring(self) return string.format("(%i, %i, %i)", self.x, self.y, self.z) end

function vectmt.dot(self, other) return self.x * other.x + self.y * other.y + self.z * other.z end

function vectmt.cross(self, other)
  return vect(self.y * other.z - self.z * other.y, self.z * other.x - self.x * other.z,
    self.x * other.y - self.y * other.x)
end

function vectmt.len(self) return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z) end

function vectmt.len2(self) return self.x * self.x + self.y * self.y + self.z * self.z end

function vectmt.norm(self) return self:__div(self:len()) end

function vectmt.round(self, t)
  t = t or 1
  return vect(math.floor((self.x + t * 0.5) / t) * t, math.floor((self.y + t * 0.5) / t) * t,
    math.floor((self.z + t * 0.5) / t) * t)
end

Vec = vect
Res = Vec(240, 136)
T = 0

function clamp(x, x_min, x_max)
  return math.min(math.max(x, x_min), x_max)
end

function bezier(t, p0X, p0Y, p1X, p1Y, p2X, p2Y, p3X, p3Y)
  local cX = 3 * (p1X - p0X)
  local bX = 3 * (p2X - p1X) - cX
  local aX = p3X - p0X - cX - bX

  local cY = 3 * (p1Y - p0Y)
  local bY = 3 * (p2Y - p1Y) - cY
  local aY = p3Y - p0Y - cY - bY

  return ((aX * t ^ 3) + (bX * (t ^ 2)) + (cX * t) + p0X),
      ((aY * (t ^ 3)) + (bY * (t ^ 2)) + (cY * t) + p0Y)
end

Perspective = {}
function Perspective:new(o, focal_length, aspect_ratio)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.f = focal_length or 1
  self.a = aspect_ratio or 1
  self.R = { -- rotation matrix
    { 1, 0, 0 },
    { 0, 1, 0 },
    { 0, 0, 1 }
  }
  self.t = { 0, 0, -5 } -- translation vector
  return o
end

-- Define the camera parameters
local f = 1 -- focal length
local a = 1 -- aspect ratio
local R = { -- rotation matrix
  { 1, 0, 0 },
  { 0, 1, 0 },
  { 0, 0, 1 }
}
local t = { 0, 0, -5 } -- translation vector

-- Define the screen parameters
local w = Res.x -- screen width
local h = Res.y -- screen height
-- Define a function to build the 1-point perspective transform matrix
local function build_matrix()
  -- Compute the inverse of the camera transformation matrix
  local C = { { R[1][1], R[1][2], R[1][3], -R[1][1] * t[1] - R[1][2] * t[2] - R[1][3] * t[3] },
    { R[2][1], R[2][2], R[2][3], -R[2][1] * t[1] - R[2][2] * t[2] - R[2][3] * t[3] },
    { R[3][1], R[3][2], R[3][3], -R[3][1] * t[1] - R[3][2] * t[2] - R[3][3] * t[3] },
    { 0,       0,       0,       1 } }
  -- Compute the projection matrix
  local P = {
    { f, 0,     0, 0 },
    { 0, a * f, 0, 0 },
    { 0, 0,     1, 0 },
    { 0, 0,     1, 0 }
  }
  -- Compute the scaling and translation matrix
  local S = {
    { w / 2, 0,      0, w / 2 },
    { 0,     -h / 2, 0, h / 2 },
    { 0,     0,      1, 0 },
    { 0,     0,      0, 1 }
  }

  -- Compute the 1-point perspective transform matrix
  local M = { { 0, 0, 0, 0 }, { 0, 0, 0, 0 }, { 0, 0, 0, 0 }, { 0, 0, 0, 0 } }

  for i = 1, 3 do
    for j = 1, 3 do
      for k = 1, 4 do
        M[i][j] = M[i][j] + S[i][k] * P[k][j]
      end
      for k = 1, 4 do
        M[i][j] = M[i][j] + M[i][k] * C[k][j]
      end
    end
  end
  -- Return the matrix
  return M
end
function print_matrix(a)
  local m_str = ""
  for _, v in ipairs(a) do
    local s = ""
    for _, w in ipairs(v) do
      s = s .. string.format("%d ", w)
    end
    m_str = m_str .. s .. "\n"
  end
  return (m_str)
end

-- Define a function to apply the matrix to a 3D point
local function transform_point(p, M)
  trace(print_matrix(M))

  -- Convert the point to a homogeneous vector
  local q = { p.x, p.y, p.z, 1 }
  -- Multiply the vector by the matrix
  local r = { 0, 0, 0, 0 }
  for i = 1, 4 do
    for j = 1, 4 do
      r[i] = r[i] + q[j] * M[j][i]
    end
    trace(string.format("r[%d] = %f",i,r[i]))
  end
  -- Discard the last element and return the 2D point
  return Vec(r[1] / r[3], r[2] / r[3], 0)
end

-- Build the matrix
local M = build_matrix()

-- Define a 3D point
local p = Vec(2, 3, 4)

-- Apply the matrix to the point
local s = transform_point(p, M)

-- Print the result
trace(string.format("The 3D point %s is projected", p))
trace(string.format("The 2D point %s is displayed", s))




Level = {
  from = "S:Station1",
  to = "S:Station2",
  track = "00000000"
}

function Level:draw()
  local bez = function(...)
    local pathPoints = { ... }
  end
  --draw in clipped area 240,104
  cls(14)

  rect(0, 60, 240, 60, 13)

  spr(14, 200, 50, 8, 1, 0, 0, 2, 2)
end

Bim = {
  pos = 0
}

function update()
end

function draw()
  Level:draw()
end

function TIC()
  update()
  draw()
  T = (T + 1) % 1024
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

