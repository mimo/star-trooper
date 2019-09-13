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
  instance.orientation = 0
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

function Entity:move (movement)
  local newposx = self.x 
  local newposy = self.y

  local dx, dy = 0, 0
  local way = function ()
    if self.orientation > 180 then return 1 else return -1 end
  end
  local topositive = function (number)
    if number > 1 then return number else return 1 end
  end

  local speed = 0

  if movement.forward ~= nil then speed = movement.forward
  elseif movement.backward ~= nil then speed = movement.backward * -1
  end

  dx = speed * math.cos(self.orientation)
  dy = speed * math.sin(self.orientation) * way ()

  if movement.left ~= nil then
    speed = movement.left
    local theta = self.orientation - math.pi / 2
  elseif movement.right ~= nil then
    speed = movement.right
    local theta = self.orientation + math.pi / 2
  end

  newposx = newposx + dx
  newposy = newposy + dy

  -- TODO
  --col, row = Level:map()
 --local tileType = Game.map.grid[row][col]
  local tileType = 8

  if tileType == 8 or tileType == 7 then
    self.x = topositive (newposx)
    self.y = topositive (newposy)
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
game.titleHeight = 75
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
function drawCursor ()
  local size = 4
  local x = love.mouse.getX()
  local y = love.mouse.getY()
  love.graphics.setColor(0.1, 0.3, 1)
  love.graphics.setLineWidth (2)
  love.graphics.line (x, y - size, x - size, y, x, y + size, x + size, y, x, y - size)
  love.graphics.setPointSize(2)
  love.graphics.points (x, y)
end

function player:changeAnimation ()
  self.xm = love.mouse.getX() - self.x
  self.ym = -1 *(love.mouse.getY() - self.y)
  local xy = math.sqrt(self.xm^2 + self.ym^2)
  local theta = math.acos (self.xm / xy)
  if self.ym < 0 then theta = math.pi * 2 - theta end

  if theta < self.angles[1]
  or theta > self.angles[4] then self.currentAnim = 'right'
  elseif theta < self.angles[2] then self.currentAnim = 'up'
  elseif theta < self.angles[3] then self.currentAnim = 'left'
  else self.currentAnim = 'down'
  end
  self.orientation = theta
end
------------------------------------------------------
-- LOVE CALLBACKS
----
function love.update (dt)
  if love.keyboard.isDown("down")   then player:move ({ backward =  1 })
  elseif love.keyboard.isDown("up") then player:move ({ forward = 2 })
  end

  if     love.keyboard.isDown("right") then player:move ({ right =  1.5 })
  elseif love.keyboard.isDown("left")  then player:move ({ left = 1.5 })
  end

  player:changeAnimation()
  player:update (dt)
end

function love.load ( )
  love.window.setTitle ("Star Trooper - GC GameJam #21")
  love.mouse.setVisible(false)
  love.graphics.setDefaultFilter("nearest")

  Level:load ("res/level1")
  local marginx = (love.graphics:getWidth() - Level.viewSize.w) / 2
  local marginy = (love.graphics:getHeight() - game.titleHeight - Level.viewSize.h ) / 2
  game.viewport.x = math.floor(marginx)
  game.viewport.y = math.floor(marginy + game.titleHeight)

  player:loadSprites("res/player.png", 16, 16)
  player:setupAnimation ('left',  4, 2)
  player:setupAnimation ('right', 4, 1)
  player:setupAnimation ('up',    4, 3)
  player:setupAnimation ('down',  4, 4)

  player.x = 16 * 10 + game.viewport.x
  player.y = 16 * 10 + game.viewport.y
end

function love.draw ( )

  love.graphics.push()
    love.graphics.scale (1.25, 1.25)
    Level:draw (game.viewport.x, game.viewport.y)
    -- TODO Level:mapCellCenter(col, row)
    player:draw(0, 0)
    drawCursor ()
  love.graphics.pop()

  love.graphics.setColor (0.1, 0.2, 1, 1)
  love.graphics.print ("Welcome StarTrooper ...", 10, 10)
  love.graphics.setColor (1, 1, 1, 1 )

  local yellow = { 0.9, 0.8, 0.6, 1 }
  local red = { 0.9, 0.1, 0.1, 1 }
  local coloredText = {yellow, "/!\\ ", red, "For emergency press 'Escape'", yellow, " /!\\"}
  love.graphics.print (coloredText, 10, 50)
end

function love.keypressed(key)
  if love.keyboard.isDown ('escape') then love.event.quit (0) end
end