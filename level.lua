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

return Level
