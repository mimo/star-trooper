local topositive = function (number)
  if number > 1 then return number else return 1 end
end
local constrain = function (number, min, max)
  if number < min then return min
  elseif number > max then return max
  else return number
  end
end
------------------------------------------------------
local game = {}
game.view = {x = 0, y = 0, width = 0, height = 0, scalex = 1, scaley = 1 }
game.titleHeight = 32
game.showmap = false
game.showdebug = false
game.debug = { messages = {} , lines = {} }


local Level = {}
Level.rooms = {}

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

function Level:computeRowCol (index)
  local row = math.ceil(index / self.map.width)
  local col = self.map.width + index - (row * self.map.width)
  return col, row
end

function Level:load (pathStr)
  self.tileSets = {}
  self.map = {}

  print ("Loading tilesets used by '"..pathStr.."'...")
  self.map =  require(pathStr)

  for i, tileset in ipairs (self.map.tilesets) do
    local imagePath = "res/"..tileset.image
    Level:addTileset (imagePath, tileset.name, tileset.tilewidth, tileset.tileheight)
  end

  local upLeftCorner = 25
  local upRightCorner = 26
  local downLeftCorner = 27
  local downRightCorner = 28

  local shiftLeft = -1
  local shiftRight = 1
  local shiftUp = -self.map.width
  local shiftDown = self.map.width

  local roomIndex = 3
  local currentRoomLayer = {}

  local index = 0
  local row, col = 1, 1
  local computeRowCol = function ()
    row = math.ceil(index / self.map.width)
    col = self.map.width + index - (row * self.map.width)
  end

  local count = self.map.width * self.map.height
  local countCall = 0
  local edges = {}
  local lines = {}

  lookEdges = function (shift)

    if index > count then return end

    index = index + shift
    local tileId = currentRoomLayer.data[index]

    if tileId ~= 0 then
      computeRowCol ()
      if #edges >= 1 then
        table.insert (lines, {edges[#edges][1], edges[#edges][2], col, row} )
      end

      if #edges > 3 then
        if col == edges[1][1] and row == edges[1][2] then
          table.insert(self.rooms, {e = edges, l = lines})
          return
        end
      end

      table.insert (edges, {col, row})

      if tileId == upLeftCorner    then
        if shift == shiftRight or shift == shiftUp
        then shift = shiftRight
        else shift = shiftDown
        end
      elseif tileId == upRightCorner   then
         if shift == shiftRight
         then shift = shiftDown
         else shift = shiftLeft
         end
      elseif tileId == downRightCorner then
        if shift == shiftDown
        then shift = shiftLeft
        else shift = shiftUp
        end
      elseif tileId == downLeftCorner  then
        if shift == shiftLeft
        then shift = shiftUp
        else shift = shiftRight
        end
      end
    end

    lookEdges (shift)
  end

  roomIndex = 3
  repeat
    currentRoomLayer = self.map.layers[roomIndex]
    index = 0
    edges = {}
    lines = {}
    lookEdges (1)
    roomIndex = roomIndex + 1
  until roomIndex > #self.map.layers
end

function Level:draw (view)
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
        love.graphics.draw (self.tileSets[1].data, texQuad, ox - view.x, oy - view.y)
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

function Level:getMapCell (x, y)
  return math.ceil (x / self.map.tilewidth), math.ceil (y / self.map.tileheight) - 1
end

function Level:getCellType (col, row)
  local i = row * self.map.width + col
  return self.map.layers[1].data[i]
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

  local shift = function (speed, theta, moveTarget)
    local sx = speed * math.cos(theta)
    local sy = -speed * math.sin(theta)

    sx = sx * dt * 10
    sy = sy * dt * 10

    -- strafe hack, reverse when player is downward
    if moveTarget and self.target.orientation > math.pi then
        sx = sx * -1
        sy = sy * -1
    end

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

  local col, row = Level:getMapCell(x, y)
  local tileType = Level:getCellType (col, row)

  if tileType == 8 or tileType == 7 or tileType == 21 then
    self.x = topositive (x)
    self.y = topositive (y)
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
------------------------------------------------------
-- GLOBAL OBJECTS
----

local player = Entity:new("alexis")
local bandit = Entity:new("croman")
-- angles at which entity's sprite anim change
player.angles = {
  math.pi / 4,
  math.pi * 3/4,
  math.pi / 4   + math.pi,
  math.pi * 3/4 + math.pi }
------------------------------------------------------
-- GLOBAL FUNCTIONS
----
local function drawCursor (view)
  local size = 4
  local x = player.target.x - view.x
  local y = player.target.y - view.y
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

function game:debugLine (x1, y1,  x2, y2)
  local l = { p1 ={}, p2= {}}
  l.p1.x = x1
  l.p1.y = y1
  l.p2.x = x2
  l.p2.y = y2

  table.insert (self.debug.lines, l)
end
function game:debugMessage (str)
  table.insert (self.debug.messages, str)
end
function game:mapToScreen (x, y)
  return x - self.view.x, y - self.view.y
end
function game:updateView()
  self.px, self.py = game:mapToScreen (player.x, player.y)
  local shift = {x = 0, y = 0}

  if self.px < self.view.marginLeft then
    shift.x = self.px - self.view.marginLeft
  elseif self.px > self.view.marginRight then
    shift.x = self.px - self.view.marginRight
  end

  if self.py < self.view.marginTop then
    shift.y = self.py - self.view.marginTop
  elseif self.py > self.view.marginBottom then
    shift.y = self.py - self.view.marginBottom
  end

  local lvlWidth = Level.map.width * Level.map.tilewidth
  local lvlHeight = Level.map.height * Level.map.tileheight
  self.view.x = constrain (self.view.x + shift.x, 0, lvlWidth - self.view.width)
  self.view.y = constrain (self.view.y + shift.y, 0, lvlHeight - self.view.height)
  self.view.firstCol, self.view.firstRow = Level:getMapCell (self.view.x, self.view.y)
end
------------------------------------------------------
-- LOVE CALLBACKS
----
function love.update (dt)
  game.debug.lines = {}
  game.debug.messages = {}

  if love.keyboard.isDown("s") or love.keyboard.isDown("down")  then player:move (dt, { backward = 4 })
  elseif love.keyboard.isDown("z") or love.keyboard.isDown("up") then player:move (dt, { forward = 8 })
  end

  if     love.keyboard.isDown("d") or love.keyboard.isDown("right") then player:move (dt, { right =  6 })
  elseif love.keyboard.isDown("q") or love.keyboard.isDown("left") then player:move (dt, { left = 6 })
  end

  player:changeAnimation()
  player:update (dt)

  game:updateView()
end

function love.mousemoved( x, y, dx, dy, istouch )
  player:updateTarget(dx, dy)
end

function love.load ( )
  love.window.setTitle ("Star Trooper - GC GameJam #21")
  love.mouse.setRelativeMode(true)
  love.graphics.setDefaultFilter("nearest")

  UI.initialize ()

  Level:load ("res/level1")

  player:loadSprites("res/player.png", 16, 16)
  player:setupAnimation ('left',  4, 2)
  player:setupAnimation ('right', 4, 1)
  player:setupAnimation ('up',    4, 3)
  player:setupAnimation ('down',  4, 4)

  player.x = 16 * 18
  player.y = 16 * 17 - 8
  player:updateTarget(player.x, player.y - 50)

  game.view.scalex = 2
  game.view.scaley = 2
  game.view.width = love.graphics.getWidth() / game.view.scalex
  game.view.height = love.graphics.getHeight() / game.view.scaley
  game.view.x = math.floor(player.x) - game.view.width / 2
  game.view.y = math.floor(player.y) - game.view.height / 2
  local scrollBorderW = math.ceil (game.view.width / 3)
  local scrollBorderH = math.ceil (game.view.height / 3)
  game.view.marginLeft = scrollBorderW
  game.view.marginRight = game.view.width - scrollBorderW
  game.view.marginTop = scrollBorderH
  game.view.marginBottom = game.view.height - scrollBorderH
  game.view.firstCol, game.view.firstRow = Level:getMapCell (game.view.x, game.view.y)
  print ("firstcol "..game.view.firstCol.."x"..game.view.firstRow.." ; coord : "..game.view.x.." x "..game.view.y)
end

function love.draw ( )

  love.graphics.push()
    love.graphics.scale (game.view.scalex, game.view.scaley)
    Level:draw (game.view)
    -- TODO Level:mapCellCenter(col, row)
    local x, y = game:mapToScreen (player.x, player.y)
    player:draw(x, y)
    drawCursor (game.view)
  love.graphics.pop()

  if game.showdebug then
    love.graphics.push()
    love.graphics.scale (game.view.scalex, game.view.scaley)

    love.graphics.setColor (0.4, 0.4, 1, 1)
    for i, l in ipairs (game.debug.lines) do
      love.graphics.line (l.p1.x, l.p1.y, l.p2.x, l.p2.y)
    end

    love.graphics.pop()

    love.graphics.setColor (1, 1, 1, 0.85)
    love.graphics.rectangle('fill', 10, 10, love.graphics.getWidth() * 0.4, love.graphics.getHeight() *0.4)
    love.graphics.setColor (0, 0, 0, 1)
    love.graphics.setFont(UI.infoFont)
    for i, m in ipairs (game.debug.messages) do
      love.graphics.print (m, 12, 12 + i * 15)
    end
    love.graphics.setColor (1, 1, 1, 1)

  else
    UI.showTitle ()


  end

  if game.showmap then
    scale = (game.view.height - 50) / Level.map.height

    love.graphics.setColor (0.21, 0.21, 0.21, 0.85)
    love.graphics.rectangle('fill', 50, 50, - 4 + Level.map.width * scale, 4 + Level.map.height*scale)

    for i, room in ipairs(Level.rooms) do
      love.graphics.setColor (0, 0, 1, 1)
      for i, val in ipairs(room.l) do
        love.graphics.line (51 + (val[1]-0.0) * scale, 51 + (val[2]-0.0) * scale, 51 + (val[3]-0.0) * scale, 51 + (val[4]-0.0) * scale)
      end
    end

    local px, py  = Level:getMapCell (player.x, player.y)

    love.graphics.setColor (1, 0, 0, 1)
    love.graphics.points (51 + (px + 0.5) * scale, 51 + (py + 0.5) * scale)
    love.graphics.setColor (1, 1, 1, 1)
  end
end

function love.keypressed(key)
  if love.keyboard.isDown ('escape') then love.event.quit (0) end

  if love.keyboard.isDown ('m') then game.showmap = not game.showmap end

  if love.keyboard.isDown (')') then game.showdebug = not game.showdebug end
end
