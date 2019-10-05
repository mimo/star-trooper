
UI = {
  yellow = { 1.0, 0.9, 0.7, 1 },
  red = { 0.9, 0.1, 0.1, 1 }
}

function UI.drawCursor (x, y, size)
  love.graphics.setColor(0.1, 0.3, 1)
  love.graphics.setLineWidth (2)
  love.graphics.line (x, y - size, x - size, y, x, y + size, x + size, y, x, y - size)
  love.graphics.setPointSize(2)
  love.graphics.points (x, y)
end

function UI.initialize ()
    UI.titleFont = love.graphics.newFont("res/Fox Cavalier.otf", 24)
    UI.infoFont = love.graphics.newFont("res/Fox Cavalier.otf", 12)
end

function UI.showTitle ()
  local gameTitle = "Welcome StarTrooper ..."
  local coloredExitInfo = {UI.yellow, "/!\\ ", UI.red, "For emergency press 'Escape'", UI.yellow, " /!\\"}
  local exitInfo = "/!\\ For emergency press 'Escape' /!\\"
  local mapInfo  = "Press m to toggle map view."
  local mapInfoWidth  = UI.infoFont:getWidth (mapInfo)
  local exitInfoWidth = UI.infoFont:getWidth(exitInfo)

  love.graphics.setColor (0.21, 0.21, 0.21, 0.85)
  love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), 32)
  love.graphics.setColor (1, 1, 1, 1)

  love.graphics.setColor (0.1, 0.2, 1, 1)
  love.graphics.setFont(UI.titleFont)
  love.graphics.print (gameTitle, 4, 4)
  love.graphics.setColor (1, 1, 1, 1)

  love.graphics.setFont (UI.infoFont)
  love.graphics.print (coloredExitInfo, love.graphics.getWidth() - exitInfoWidth - 18 , 2)
  love.graphics.print (mapInfo, love.graphics.getWidth() - mapInfoWidth - 50 , 17)
end

return UI
