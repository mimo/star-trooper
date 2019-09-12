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
-- TODO : rename Player into Entity
local Player = {}

function Player:load  ()
  self.texture = love.graphics.newImage("res/player.png")
  self.textureSize = {x = 16, y = 16}
  self.frametime =  0
  self.deltaS = 0.25
  self.currentSprite = 1
  self.currentAnim = 'left'
  self.animationsOrder = {'right', 'left', 'up', 'down'}

  local animations = {}
  animations['left'] = {}
  animations['right'] = {}
  animations['up'] = {}
  animations['down'] = {}

  for animId = 1, 4 do
    local oy = (animId - 1) * self.textureSize.y
    for frameId = 1, 4 do
      local ox = (frameId - 1) * self.textureSize.x
      local sprite = love.graphics.newQuad (ox, oy, self.textureSize.x, self.textureSize.y, self.texture:getWidth(), self.texture:getHeight() )
      local animationName = self.animationsOrder[animId]
      table.insert (animations[animationName], sprite)
    end
  end

  self.animations = animations
end

function Player:update (dt)
  self.frametime = self.frametime + dt

  local function doswitch()
    local anim = self.animations[self.currentAnim]
    if self.currentSprite < #anim then
      self.currentSprite = self.currentSprite + 1
    else
      self.currentSprite = 1
    end
  end

  if self.frametime > self.deltaS then
    self.frametime = 0
    doswitch()
  end

end

function Player:draw(x, y)
  love.graphics.draw (self.texture, self.animations[self.currentAnim][self.currentSprite], x, y, 0, 1.6, 1.6)
end
------------------------------------------------------
local px, py
local titleHeight = 75

love.graphics.setDefaultFilter("nearest")

function love.update (dt)
  if love.keyboard.isDown ('escape') then love.event.quit (0) end

  Player:update (dt)
end

function love.load ( )
  love.window.setTitle ("Star Trooper - GC GameJam #21")

  Level:load ("res/level1")
  local marginx = (love.graphics:getWidth() - Level.viewSize.w) / 2
  local marginy = (love.graphics:getHeight() - titleHeight - Level.viewSize.h ) / 2
  px = math.floor(marginx)
  py = math.floor(marginy + titleHeight)

  Player:load()
end

function love.draw ( )
  love.graphics.push()
  love.graphics.scale (1.25, 1.25)
  Level:draw (px, py)
  -- TODO Level:mapCellCenter(col, row)
  Player:draw(px + 16 * 10, py + 16 * 10)
  love.graphics.pop()

  love.graphics.setColor (0.1, 0.2, 1, 1)
  love.graphics.print ("Welcome StarTrooper ...", 10, 10)
  love.graphics.setColor (1, 1, 1, 1 )

  local yellow = { 0.9, 0.8, 0.6, 1 }
  local red = { 0.9, 0.1, 0.1, 1 }
  local coloredText = {yellow, "/!\\ ", red, "For emergency press 'Escape'", yellow, " /!\\"}
  love.graphics.print (coloredText, 10, 50)
end
