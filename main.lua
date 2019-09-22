------------------------------------------------------
local Level = {}

function Level:addTileset (pathStr, idStr, resX, resY)
  local texture = love.graphics.newImage(pathStr)

  local set = {
      colCount = texture:getWidth()  / resX,
      rowCount = texture:getHeight() / resY,
      id = idStr,
      data = texture,
      textures = {}
  }

  local id = 1
  local ox, oy
  local dx = resX
  local dy = resY

  for row = 1, set.rowCount do
    for col = 1, set.colCount do
      ox = (col - 1) * resX
      oy = (row - 1) * resY
      set.textures [id] = love.graphics.newQuad (ox, oy, resX, resY, texture:getWidth(), texture:getHeight() )
      id = id + 1
    end

  end

  table.insert (self.tileSets, set )
  print ("- '"..set.id.."' loaded")
end

function Level:load (pathStr)
  self.tileSets = {}
  self.map = {}
  self.viewSize = {x = 0, y = 0}

  print ("Loading tilesets used by '"..pathStr.."'...")
  self.map =  require(pathStr)

  for i, tileset in ipairs (self.map.tilesets) do
    local imagePath = "res/"..tileset.image
    Level:addTileset (imagePath, tileset.name, tileset.tilewidth, tileset.tileheight)
  end

  self.viewSize.w = self.map.width * self.map.tilewidth
  self.viewSize.h = self.map.height * self.map.tileheight
end

function Level:draw (x, y)
  local col, row
  local ox, oy

  local tileset = self.tileSets[1]

  for i, layer in ipairs (self.map.layers) do
      col, row = 1, 1
      for j, val in ipairs(layer.data) do
        local texQuad = self.tileSets[1].textures[val]
        if texQuad ~= nil then
          -- TODO : handle offset from Tiled layers
          ox = (col-1) * self.map.tilewidth
          oy = (row-1) * self.map.tileheight
          -- TODO : create a  tile drawing function
          love.graphics.draw (self.tileSets[1].data, texQuad, ox + x, oy + y)
        end
        -- go through the row  or ...
        if col < layer.width then
          col = col + 1
        else -- switch to next line
          col = 1
          row = row + 1
        end
      end
  end
end
------------------------------------------------------
Entity = {}
Entity.name = "foo"

function Entity:new(name)
  local instance = {}
  instance.x, instance.y = 0, 0
  instance.name = name
  instance.spritesheet = {}
  instance.spriteSize = {x = 0, y = 0}
  instance.texture = {}
  instance.target = {x = 0, y = 0}
  instance.target.orientation = 0
  instance.target.distance = 0
  -- variables for animation
  instance.currentAnim = ''
  instance.frametime =  0
  instance.deltaS = 0.25
  instance.currentFrame = 1
  self.__index = self
  return setmetatable (instance, self)
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
  local speed = 0

  local topositive = function (number)
    if number > 1 then return number else return 1 end
  end

  local shift = function (speed, theta, moveTarget)
    local way = function ()
      if theta > 180 then return 1 else return -1 end
    end

    local sx = speed * math.cos(theta)
    local sy = speed * math.sin(theta) * way()

    sx = sx * dt * 10
    sy = sy * dt * 10

    x = x + sx
    y = y + sy

    if moveTarget then self:updateTarget (sx, sy) end
  end

  if movement.forward ~= nil then
    speed = movement.forward
    shift (speed, self.target.orientation, false)
  elseif movement.backward ~= nil then
    speed = movement.backward * -1
    shift (speed, self.target.orientation, false)
  end

  if movement.left ~= nil then
    speed = movement.left * -1
    shift (speed, self.target.orientation - math.pi / 2, true)
  elseif movement.right ~= nil then
    speed = movement.right * -1
    shift (speed, self.target.orientation + math.pi / 2, true)
  end

  -- TODO
  --col, row = Level:map()
 --local tileType = Game.map.grid[row][col]
  local tileType = 8

  if tileType == 8 or tileType == 7 then
    self.x = topositive (x)
    self.y = topositive (y)
  end


end

function Entity:draw(offsetx, offsety)
  local animation = self.spritesheet[self.currentAnim]
  local sprite = animation[self.currentFrame]
  local x = self.x + offsetx
  local y = self.y + offsety
  local ox = self.spriteSize.x / 2
  local oy = self.spriteSize.y / 2

  love.graphics.draw (self.texture, sprite, x, y, 0, 1.6, 1.6, ox, oy)
end
------------------------------------------------------
-- GLOBAL OBJECTS
----
local game = {}
game.viewport = {x = 0, y = 0, width = 0, height = 0 }
game.titleHeight = 32
game.showmap = false
local player = Entity:new("alexis")
-- angles at which entity orientation change
player.angles = {
  math.pi / 4,
  math.pi * 3/4,
  math.pi / 4   + math.pi,
  math.pi * 3/4 + math.pi }
------------------------------------------------------
-- GLOBAL FUNCTIONS
----
local function drawCursor ()
  local size = 4
  local x = player.target.x
  local y = player.target.y
  love.graphics.setColor(0.1, 0.3, 1)
  love.graphics.setLineWidth (2)
  love.graphics.line (x, y - size, x - size, y, x, y + size, x + size, y, x, y - size)
  love.graphics.setPointSize(2)
  love.graphics.points (x, y)
end

function player:updateTarget (dx, dy)
  self.target.x = self.target.x + dx
  self.target.y = self.target.y + dy

  local xm = self.target.x - self.x
  local ym = -1 * (self.target.y - self.y)

  self.target.distance = math.sqrt(xm^2 + ym^2)
  local theta = math.acos (xm / self.target.distance)
  if ym < 0 then theta = math.pi * 2 - theta end

  self.target.orientation = theta
end

function player:changeAnimation ()
  local theta = self.target.orientation

  if theta < self.angles[1]
  or theta > self.angles[4] then self.currentAnim = 'right'
  elseif theta < self.angles[2] then self.currentAnim = 'up'
  elseif theta < self.angles[3] then self.currentAnim = 'left'
  else self.currentAnim = 'down'
  end
end
------------------------------------------------------
-- LOVE CALLBACKS
----
function love.update (dt)
  if love.keyboard.isDown("down")   then player:move (dt, { backward = 4 })
  elseif love.keyboard.isDown("up") then player:move (dt, { forward = 8 })
  end

  if     love.keyboard.isDown("right") then player:move (dt, { right =  6 })
  elseif love.keyboard.isDown("left")  then player:move (dt, { left = 6 })
  end

  player:changeAnimation()
  player:update (dt)
end

function love.mousemoved( x, y, dx, dy, istouch )
  player:updateTarget(dx, dy)
end

function love.load ( )
  love.window.setTitle ("Star Trooper - GC GameJam #21")
  love.mouse.setVisible(false)
  love.mouse.setRelativeMode(true)
  love.graphics.setDefaultFilter("nearest")

  game.titleFont = love.graphics.newFont("res/Fox Cavalier.otf", 24)
  game.infoFont = love.graphics.newFont("res/Fox Cavalier.otf", 13)

  Level:load ("res/level1")
  local marginx = 0 --(love.graphics:getWidth() - Level.viewSize.w * 1.25) / 2
  local marginy = 0 -- game.titleHeight
  game.viewport.x = math.floor(marginx)
  game.viewport.y = math.floor(marginy)

  player:loadSprites("res/player.png", 16, 16)
  player:setupAnimation ('left',  4, 2)
  player:setupAnimation ('right', 4, 1)
  player:setupAnimation ('up',    4, 3)
  player:setupAnimation ('down',  4, 4)

  player.x = 16 * 10 + game.viewport.x
  player.y = 16 * 10 + game.viewport.y
  player.target.x = player.x + 32
  player.target.y = player.y
end

function love.draw ( )

  love.graphics.push()
    love.graphics.scale (2, 2)
    Level:draw (game.viewport.x, game.viewport.y)
    -- TODO Level:mapCellCenter(col, row)
    player:draw(0, 0)
    drawCursor ()
  love.graphics.pop()

  love.graphics.setColor (0.21, 0.21, 0.21, 0.85)
  love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), 32)
  love.graphics.setColor (1, 1, 1, 1)

  love.graphics.setColor (0.1, 0.2, 1, 1)
  love.graphics.setFont(game.titleFont)
  love.graphics.print ("Welcome StarTrooper ...", 4, 4)
  love.graphics.setColor (1, 1, 1, 1)

  local yellow = { 1.0, 0.9, 0.7, 1 }
  local red = { 0.9, 0.1, 0.1, 1 }
  local coloredText = {yellow, "/!\\ ", red, "For emergency press 'Escape'", yellow, " /!\\"}
  love.graphics.setFont(game.infoFont)
  love.graphics.print (coloredText, love.graphics.getWidth() - game.infoFont:getWidth("/!\\ For emergency press 'Escape' /!\\") - 18 , 2)
  local mapMsg = "Press m to toggle map view."
  love.graphics.print (mapMsg, love.graphics.getWidth() - game.infoFont:getWidth(mapMsg) - 50 , 17)

  if game.showmap then
    love.graphics.setColor (0.21, 0.21, 0.21, 0.85)
    love.graphics.rectangle('fill', 50, 50, 400, 300)
    love.graphics.setColor (1, 1, 1, 1)
  end
end

function love.keypressed(key)
  if love.keyboard.isDown ('escape') then love.event.quit (0) end

  if love.keyboard.isDown ('m') then game.showmap = not game.showmap end
end