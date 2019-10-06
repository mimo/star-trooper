require 'helpers'
------------------------------------------------------
local Entity = {}
------------------------------------------------------
function Entity:initialize(name)
  --local instance = {}
  self.x, self.y = 0, 0
  self.name = name
  self.spritesheet = {}

  self.spriteSize = {x = 0, y = 0}
  self.texture = {}
  self.target = {x = 0, y = 0}
  self.target.orientation = 0
  self.target.distance = 0
  -- variables for animation
  self.currentAnim = ''
  self.frametime =  0
  self.deltaS = 0.25
  self.currentFrame = 1
end

function Entity:new(name)
  local instance = {}

  self.__index = self
  setmetatable (instance, self)

  instance:initialize (name)
  return instance
end

function Entity:loadSprites (file, sizeX, sizeY)
  self.texture = love.graphics.newImage(file)
  self.spriteSize = {x = sizeX, y = sizeY}
end

function Entity:setupAnimation (name, count, row)
  self.spritesheet[name] = {}
  local oy = (row - 1) * self.spriteSize.y
  for frameId = 1, count do
      local ox = (frameId - 1) * self.spriteSize.x
      local sprite = love.graphics.newQuad (ox, oy, self.spriteSize.x, self.spriteSize.y, self.texture:getWidth(), self.texture:getHeight() )
      table.insert (self.spritesheet[name], sprite)
    end
end

function Entity:update(dt)
  local function doswitch()
    local anim = self.spritesheet[self.currentAnim]
    if self.currentFrame < #anim then
      self.currentFrame = self.currentFrame + 1
    else
      self.currentFrame = 1
    end
  end

  self.frametime = self.frametime + dt
  if self.frametime > self.deltaS then
    self.frametime = 0
    doswitch()
  end
end

function Entity:move (dt, movement)
  local x = self.x
  local y = self.y
  local speed = 1
  local sx = 0
  local sy = 0

  local shift = function ()
    x = x + sx
    y = y + sy
  end

  local move = function (speed, theta, moveTarget)
    sx = speed * math.cos(theta)
    sy = -speed * math.sin(theta)

    sx = sx * dt * 10
    sy = sy * dt * 10
  end

  -- reverse strafe when player is downward
  local strafeHack = function()
    if self.target.orientation > math.pi then
      sx = sx * -1
      sy = sy * -1
    end
  end

  if movement.up then
    --sy = dt * -10 * speed
    move (7, self.target.orientation, false)
    shift()
  elseif movement.down then
    --sy = dt * 10 * speed
    move (-2.5, self.target.orientation, false)
    shift()
  end

  if movement.left then
    move (-4, self.target.orientation - math.pi / 2, true)
    shift()
  elseif movement.right then sx = dt * 10 * speed
    move (-4, self.target.orientation + math.pi / 2, true)
    shift()
  end

  local col, row = Level:getMapCell(x, y)
  local tileType = Level:getCellType (col, row)

  if tileType == 8 or tileType == 7 or tileType == 21 then
    self.x = topositive (x)
    self.y = topositive (y)
    self:updateTarget (sx, sy)
  end

end

function Entity:draw(x, y)
  local scale = 1.5
  local animation = self.spritesheet[self.currentAnim]
  local sprite = animation[self.currentFrame]
  local ox = self.spriteSize.x / 2
  local oy = self.spriteSize.y - 1

  love.graphics.draw (self.texture, sprite, x, y, 0, scale, scale, ox, oy)
end

return Entity
