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
local px, py
local titleHeight = 75

function love.update ( )
  if love.keyboard.isDown ('escape') then love.event.quit (0) end
end

function love.load ( )
  Level:load ("res/level1")
  local marginx = (love.graphics:getWidth() - Level.viewSize.w) / 2
  local marginy = (love.graphics:getHeight() - titleHeight - Level.viewSize.h ) / 2
  px = math.floor(marginx)
  py = math.floor(marginy + titleHeight)
  print ("px,py = "..tostring(px)..", "..tostring(py))
end

function love.draw ( )
  Level:draw (px, py)

  love.graphics.setColor (0.1, 0.2, 1, 1)
  love.graphics.print ("Welcome StarTrooper ...", 10, 10)
  love.graphics.setColor (1, 1, 1, 1 )

  local yellow = { 0.9, 0.8, 0.6, 1 }
  local red = { 0.9, 0.1, 0.1, 1 }
  local coloredText = {yellow, "/!\\ ", red, "For emergency press 'Escape'", yellow, " /!\\"}
  love.graphics.print (coloredText, 10, 50)

end
