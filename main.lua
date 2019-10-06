------------------------------------------------------
UI = require 'ui'
Level = require 'level'
Entity = require 'entity'
require 'helpers'
------------------------------------------------------
-- GLOBAL OBJECTS
----
local game = {}
game.view = {x = 0, y = 0, width = 0, height = 0, scalex = 1, scaley = 1 }
game.titleHeight = 32
game.showmap = false
game.showdebug = false
game.debug = { messages = {} , lines = {} }
------------------------------------------------------
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

  local direction = {
    up = false,
    down = false,
    left = false,
    right = false
  }
  if     love.keyboard.isDown("s") or love.keyboard.isDown("down") then direction.down = true
  elseif love.keyboard.isDown("z") or love.keyboard.isDown("up") then direction.up = true
  end

  if     love.keyboard.isDown("d") or love.keyboard.isDown("right") then direction.right = true
  elseif love.keyboard.isDown("q") or love.keyboard.isDown("left") then direction.left = true
  end

  player:move (dt, direction)

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
    UI.drawCursor (player.target.x - game.view.x, player.target.y - game.view.y, 4)
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
