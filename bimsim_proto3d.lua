-- title:   game title
-- author:  game developer, email, etc.
-- desc:    short description
-- site:    website link
-- license: MIT License (change this to your license of choice)
-- version: 0.1
-- script:  lua

function projectPointToScreen(x, y, z, screenWidth, screenHeight, fov)
    -- Convert degrees to radians
    local fovRadians = fov * math.pi / 180

    -- Calculate the aspect ratio
    local aspectRatio = screenWidth / screenHeight

    -- Calculate the distance from the camera to the screen
    local distanceToScreen = (screenWidth / 2) / math.tan(fovRadians / 2)

    -- Calculate the projected x and y coordinates
    local projectedX = (x * distanceToScreen) / z
    local projectedY = (y * distanceToScreen) / z

    -- Map the projected coordinates to the screen space
    local screenX = (projectedX + (screenWidth / 2))
    local screenY = (projectedY + (screenHeight / 2))

    -- Return the screen coordinates
    return screenX, screenY
end

-- Example usage


local x = 0
local y = 1.5
local z = 13

--[[local screenX, screenY = projectPointToScreen(x, y, z, screenWidth, screenHeight, fov)
trace(screenX)
trace(screenY)
trace(string.format("Screen coordinates: (%f, %f)",screenX, screenY))
]]

t=0

r=3

Projection = {}
function Projection:new (o,screenWidth,screenHeight,fov)
   o = o or {}
   setmetatable(o, self)
   self.__index = self
	self.screenWidth = 240 or screenWidth
	self.screenHeight = 136 or screenHeight
	self.fov = 60 or fov
   self.fovRadians = self.fov * math.pi / 180
	self.aspectRatio = self.screenWidth / self.screenHeight
	self.distanceToScreen = (self.screenWidth / 2) / math.tan(self.fovRadians / 2)
   return o
end
function Projection:circ (x,y,z,r,color,border)
	local border = border or false
	local color = color or -1
	local projectedX = (x * self.distanceToScreen) / z
	local projectedY = (y * self.distanceToScreen) / z
	local projectedR = (r * self.distanceToScreen) / z
	local screenX = (projectedX + (self.screenWidth / 2))
	local screenY = (projectedY + (self.screenHeight / 2))
	--print(string.format("(%3.1f %3.1f %3.1f) -> (%3.1f %3.1f) ",x,y,z,screenX, screenY),4,120)
	if border
	then circb(screenX,screenY,projectedR,color)
	else circ(screenX,screenY,projectedR,color) end
end
function Projection:line(x0, y0, z0, x1, y1, z1, color)
	local color = color or -1
	local projectedX0 = (x0 * self.distanceToScreen) / z0
	local projectedY0 = (y0 * self.distanceToScreen) / z0
	local screenX0 = (projectedX0 + (self.screenWidth / 2))
	local screenY0 = (projectedY0 + (self.screenHeight / 2))
	local projectedX1 = (x1 * self.distanceToScreen) / z1
	local projectedY1 = (y1 * self.distanceToScreen) / z1
	local screenX1 = (projectedX1 + (self.screenWidth / 2))
	local screenY1 = (projectedY1 + (self.screenHeight / 2))
	print(string.format("Line from (%3.1f %3.1f %3.1f) -> (%3.1f %3.1f) ",x0,y0,z0,screenX0, screenY0),4,120)
	print(string.format("Line to   (%3.1f %3.1f %3.1f) -> (%3.1f %3.1f) ",x1,y1,z1,screenX1, screenY1),4,128)
	line(screenX0,screenY0,screenX1,screenY1,color)
	
end
function Projection:tri(x0, y0, z0, x1, y1, z1, x2, y2, z2, color,border)
	local border = border or false
	local color = color or -1
	local projectedX0 = (x0 * self.distanceToScreen) / z0
	local projectedY0 = (y0 * self.distanceToScreen) / z0
	local screenX0 = (projectedX0 + (self.screenWidth / 2))
	local screenY0 = (projectedY0 + (self.screenHeight / 2))
	local projectedX1 = (x1 * self.distanceToScreen) / z1
	local projectedY1 = (y1 * self.distanceToScreen) / z1
	local screenX1 = (projectedX1 + (self.screenWidth / 2))
	local screenY1 = (projectedY1 + (self.screenHeight / 2))
	local projectedX2 = (x2 * self.distanceToScreen) / z2
	local projectedY2 = (y2 * self.distanceToScreen) / z2
	local screenX2 = (projectedX2 + (self.screenWidth / 2))
	local screenY2 = (projectedY2 + (self.screenHeight / 2))
	print(string.format("Tri from (%3.1f %3.1f %3.1f) -> (%3.1f %3.1f) ",x0,y0,z0,screenX0, screenY0),4,112)
	print(string.format("    to   (%3.1f %3.1f %3.1f) -> (%3.1f %3.1f) ",x1,y1,z1,screenX1, screenY1),4,120)
	print(string.format("    to   (%3.1f %3.1f %3.1f) -> (%3.1f %3.1f) ",x2,y2,z2,screenX2, screenY2),4,128)
	if border
	then trib(screenX0,screenY0,screenX1,screenY1,screenX2,screenY2,color)
	else tri (screenX0,screenY0,screenX1,screenY1,screenX2,screenY2,color) end
end

function Projection:ttri(x1, y1, z1, x2, y2, z2, x3, y3, z3, u1, v1, u2, v2, u3, v3, texsrc, chromakey)
	local border = border or false
	local texsrc= texsrc or 0
	local chromakey= chromakey or -1
	local color = color or -1
	local projectedX1 = (x1 * self.distanceToScreen) / z1
	local projectedY1 = (y1 * self.distanceToScreen) / z1
	local screenX1 = (projectedX1 + (self.screenWidth / 2))
	local screenY1 = (projectedY1 + (self.screenHeight / 2))
	local projectedX2 = (x2 * self.distanceToScreen) / z2
	local projectedY2 = (y2 * self.distanceToScreen) / z2
	local screenX2 = (projectedX2 + (self.screenWidth / 2))
	local screenY2 = (projectedY2 + (self.screenHeight / 2))
	local projectedX3 = (x3 * self.distanceToScreen) / z3
	local projectedY3 = (y3 * self.distanceToScreen) / z3
	local screenX3 = (projectedX3 + (self.screenWidth / 2))
	local screenY3 = (projectedY3 + (self.screenHeight / 2))
	ttri(screenX1, screenY1, screenX2, screenY2, screenX3, screenY3, u1, v1, u2, v2, u3, v3, texsrc, chromakey, z1, z2, z3)
	--print(string.format("Tri from (%3.1f %3.1f %3.1f) -> (%3.1f %3.1f) ",x1,y1,z1,screenX1, screenY1),4,118)
	--print(string.format("     to   (%3.1f %3.1f %3.1f) -> (%3.1f %3.1f) ",x2,y2,z2,screenX2, screenY2),4,124)
	--print(string.format("     to   (%3.1f %3.1f %3.1f) -> (%3.1f %3.1f) ",x3,y3,z3,screenX3, screenY3),4,130)
	--print(string.format("z_scale = %3.1f",z_scale), 160,6,3)
end

function Projection:tquad(x,y,z,size)
	local size = size or 1
	local x0, y0, z0 = 0.5,2,0.5
	p:ttri( x-x0-size, y+y0, z+z0, x+x0, y+y0, z+z0, x-x0-size, y+y0, z-z0-size, 0,0, 8,0, 0,8,  0,5)
	p:ttri( x+x0, y+y0, z+z0, x+x0, y+y0, z-z0-size, x-x0-size, y+y0, z-z0-size, 8,0, 8,8,  0,8,  0,5)
end

function Projection:tspr()
	
end

function Projection:house(x,y,z,scale)
	x=x-6
	y=y-0
	local uv_x = 0
	local uv_y = 0

	self:ttri(x+scale,y-scale,z-scale, x+scale,y-scale,z+scale, x+scale,y+scale,z+scale, uv_x+2,uv_y+3, uv_x+8,uv_y+3, uv_x+8,uv_y+8, 2)
	self:ttri(x+scale,y-scale,z-scale, x+scale,y+scale,z-scale, x+scale,y+scale,z+scale, uv_x+2,uv_y+3, uv_x+2,uv_y+8, uv_x+8,uv_y+8, 2)
	self:ttri(x+scale,y-scale,z-scale, x+scale,y+scale,z-scale, x-scale,y+scale,z-scale, uv_x+3,uv_y+3, uv_x+3,uv_y+8, uv_x+0,uv_y+8, 2)
	self:ttri(x+scale,y-scale,z-scale, x-scale,y-scale,z-scale, x-scale,y+scale,z-scale, uv_x+3,uv_y+3, uv_x+0,uv_y+3, uv_x+0,uv_y+8, 2)
	--self:ttri(x+scale,y-scale,z-scale, x+scale,y-scale,z+scale, x,y-2*scale,z+scale, uv_x+0,3, uv_x+8,3, uv_x+8,0)
	--self:ttri(x+scale,y-scale,z-scale, x,y-2*scale,z-scale, x,y-2*scale,z+scale, uv_x+0,3, uv_x+0,0, uv_x+8,0)
	--self:ttri(x-scale,y-scale,z-scale, x-scale,y-scale,z+scale, x,y-2*scale,z+scale, uv_x+0,3, uv_x+8,3, uv_x+8,0)
	--self:ttri(x-scale,y-scale,z-scale, x,y-2*scale,z-scale, x,y-2*scale,z+scale, uv_x+0,3, uv_x+0,0, uv_x+8,0)
	
end



p = Projection:new ()
--[[function draw_pts()
	local pts = {{1,2,12,4}, {2,1,12,3}}
	for i,v in ipairs(pts) do
		x,y,z,c = table.unpack(v)
		p:circ(x,y,z,z,c)
		
	end
end]]

scale = 2
function TIC()

	if btn(0) then z=z-0.1 end
	if btn(1) then z=z+0.1 end
	if btn(2) then x=x-0.1 end
	if btn(3) then x=x+0.1 end
	if btn(4) then y=y+0.1 end
	if btn(6) then y=y-0.1 end
	if btn(5) then scale=scale+1 end
	if btn(7) then scale=scale-1 end
	cls(13)
	--spr(1+t%60//30*2,x,y,14,3,0,0,2,2)
	--p:circ(x,y,z,0.5,12,true)
	--p:tri(-1,1,2,1,1,2,x,y,z,4,true)
	local size = scale
	local x0, y0, z0 = 2,2,1
	p:tquad( x, y, z)
	p:tquad( x+2, y, z)
	p:tquad( x, y, z+2)
	p:tquad( x+2, y, z+2)
--[[	p:ttri( x+x0, y+y0, z+z0, x+x0, y+y0, z-z0, x-x0, y+y0, z-z0, size,0, size,size,  0,size, 0,2,scale)
	local x0, y0, z0 = -2,2,1
	p:ttri( x-x0, y+y0, z+z0, x+x0, y+y0, z+z0, x-x0, y+y0, z-z0, 0,0, size,0, 0,size, 0,2,scale)
	p:ttri( x+x0, y+y0, z+z0, x+x0, y+y0, z-z0, x-x0, y+y0, z-z0, size,0, size,size,  0,size, 0,2,scale)
	]]
	--[[local x0, y0, z0 = 1,2,2
	p:ttri(-x0+x,y+y0,z0+z, x0+x,y+y0,z0+z, x-x0,y+y0,z, 0,0, size,0, 0,size, 0,2,z_scale)
	p:ttri( x0+x,y+y0,z0+z, x+1,y+y0,z, x-x0,y+y0,z, size,0, size,size,  0,size, 0,2,z_scale)
	local x0, y0, z0 = 2,2,2
	p:ttri(-x0+x,y+y0,z0+z, x0+x,y+y0,z0+z, x-x0,y+y0,z, 0,0, size,0, 0,size, 0,2,z_scale)
	p:ttri( x0+x,y+y0,z0+z, x+1,y+y0,z, x-x0,y+y0,z, size,0, size,size,  0,size, 0,2,z_scale)
	]]
	--p:house(x,y,z,260,z_scale)
	--print(string.format("(%3.1f %3.1f %3.1f)",x,y,z),4,120)
	t=t+1
end

-- <TILES>
-- 000:00dcfd0000dcfd0000dcfd0000dcfd0000dcfd0000dcfd0000dcfd0000dcfd00
-- 002:eccccccccc333333c4444444c4333333c4ccccccc4ccccccc4cc0cccc4cc0ccc
-- 003:ccccceee3333ccee44440cee33340ceeccc40cccccc40c0c0cc40c0c0cc40c0c
-- 004:222222223323323322222222444444444d4dd4d4444444444d4dd4f4444444f4
-- 018:c4ccccccc4444444c444c444c4444cccc4444444c3333333cc000cccecccccec
-- 019:ccc400cc44440ccec4440cee44440cee44440cee3333ccee000cceeecccceeee
-- 032:eccccccccc777777c6666666c6777777c6ccccccc6cc0cccc6cc0cccc6cc0ccc
-- 033:ccccceee7777ccee66660cee77760ceeccc60ccc0cc60c0c0cc60c0c0cc60c0c
-- 034:eccccccccc888888caaaaaaaca888888cacccccccacccccccacc0ccccacc0ccc
-- 035:ccccceee8888cceeaaaa0cee888a0ceeccca0cccccca0c0c0cca0c0c0cca0c0c
-- 048:c6ccccccc6666666c666c666c6666cccc6666666c7777777cc000cccecccccec
-- 049:ccc600cc66660ccec6660cee66660cee66660cee7777ccee000cceeecccceeee
-- 050:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 051:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- </TILES>

-- <SPRITES>
-- 000:eedcfdeeeedcfdeeeedcfdeeeedcfdeeeedcfdeeeedcfdeeeedcfdeeeedcfdee
-- 004:222222223323323322222222444444444d4dd4d4444444444d4dd4f4444444f4
-- 018:000000ff00000000000000000000000000000000000000000000000000000000
-- 019:ffffffff00000000000000000000000000044cc4000c4444000e8fee00000008
-- 020:ffffffff000000000000000000000000cccc0000cccc0000eef0000000080000
-- 021:ffffffff000000000000000000000000ee0de0eddd0dd0ddff0ff0fedd0dd0dd
-- 022:fffe999900009999000099990000999900009999000099990000999900009999
-- 023:99999999999999999999ddcd999ddccc999ddccc999dddcd999edddd9999eddd
-- 024:9999999999999999d9999999dd999999dd999999dd999999dd999999d9999999
-- 025:9999999999999999999999999999999999999999999999999999999999999999
-- 032:00000000fffffffffeeeeeeefe332ee4fe332ee4fe222ee3feeeeeeefecc5ee5
-- 033:00000000ffffffffeeeeeeee43eecc4e43eecc4e33ee444eeeeeeeee56eebbae
-- 034:000000fffffffff0eeeeef00eaa9ef00eaa9ef00e999ef00eeeeef00eaadef00
-- 035:0000000000ddfdde08ddeddd000000000033f4de00328dde0000000000eede00
-- 036:00000000dedd0dd04dd4fdd0000000004d46ed60dd47ed700000000000000e00
-- 037:de0ee0eedd0dd0ddd40d4044000000004404404c4c0cc0cc0000000000000000
-- 038:00e0999900e0999900009999000099990000999900009999000899fe000899fe
-- 039:99999eee999990f099999000999f00009fe00000eef00000fef80000ffff0000
-- 040:9999999999999999ff00eeee0000feff0000efee0000eeee000ffeefffffee99
-- 041:999999999999999999999999e9999999e9999999e99999999999999999999999
-- 048:fecc5ee5fe555ee6feeeeeeefeeeeefff8008fff0f00000f0000000000000000
-- 049:56eebbae66eeaaaeeeeeeeeeeeeeeeeeffffffff000000000000000000000000
-- 050:eaadef00edddefeeeeeeefeeeeeeefeeffffffff000000000000666000006660
-- 051:00eeeeee000feeeeee0009e9eee00000fffffffe00800000000000f4000000fd
-- 052:eeee00feeeee00fe9eeee0ee00000000eeeeeeee000000004e000000de000000
-- 053:eeeeeeeeeeeeeee0eeeeef800000000eeeeeeeee000000000000000000000000
-- 054:d0809fff00ee99efeddd9999eeee9999eeeeeeee00000e00000ff00000f00000
-- 055:fffffffffffeffff88f8999999999999eeeeffff0000000000000000000ee000
-- 056:ffff9999f99999999999999999999999eeeeeeee000000000000000000000000
-- 057:99999999999999999999999999999999ffffffff000000ff0000000f0000000f
-- 064:000000000000000e000000fd000000fe00000000000000000000000000000000
-- 065:00000000ede00000dde008eeddd00fde00000fde000000000000000000000000
-- 066:000000000f8000f807f70077f777f07707f7f07f000000000000000000000000
-- 067:000000000000a5a0070dccc97705ccc9770dccb00000dd080000000000000000
-- 068:000000000ec700329ccce034dcccb0340cc5f04c005800030000000000000000
-- 069:00000000223000084430111144301111c430111133f000100000000000000000
-- 070:0e0010000f0111000e0000000e0000000e000000000000000000000000000000
-- 071:00ee1d0000e1010000e11100000e1e0000000000000000000000000000000000
-- 072:00000000000000000000000000000000000000000000000000008e0000000000
-- 073:00e8000e0e33000f0132100f00110008000000080fff00080000000800000008
-- 080:0000eddd0000ddde0000dd000000dd000000de800000e00000000000000000ee
-- 081:edddf000fdddf00008fdf0ef000df000000d800f00fd000000ee8000eeee0eee
-- 082:00000000000000000ed9000d0ed790ed06d700e600f0000800000000e8000000
-- 083:0000000000000000d000ed006e0f12d0d00022f000000000000000000000fee0
-- 084:00000000000000000fdf008d0e9900e00e9900e000f00000000000000feee00f
-- 085:00000000000000f0de0000f000f00080000000000000000000000000f0000000
-- 086:0000800000000000000000000000000000000000000000000000000000000000
-- 087:0000f0000e00000e000f94d000000c4e0000044e000000000000000000000000
-- 088:00e0000000f0000000e0000000e0000f00ee000f00ee00ff00ee00ff00000000
-- 089:000000000000000000000000000000000000000000000000ef00000000800000
-- 096:0f00000000000000000000000000000000000000000000000000000000000000
-- 099:00e0000000000000000000000000000000000000000000000000000000000000
-- 102:00000f0000000000000000000000000000000000000000000000000000000000
-- 104:0000ff0000000000000000000000000000000000000000000000000000000000
-- 105:0000000800000000000000000000000000000000000000000000000000000000
-- </SPRITES>

-- <MAP>
-- 000:400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </MAP>

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

