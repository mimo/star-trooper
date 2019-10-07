local Mechanics = {}

Mechanics.messages = {}
Mechanics.lines = {}
Mechanics.show = false

function Mechanics:toggle()
  self.show = not self.show
end

function Mechanics:clear()
  self.lines = {}
end

function Mechanics:clearMessages ()
  self.messages = {}
end

function Mechanics:showLine (x1, y1,  x2, y2)
  local l = { p1 ={}, p2= {}}
  l.p1.x = x1
  l.p1.y = y1
  l.p2.x = x2
  l.p2.y = y2

  table.insert (self.lines, l)
end
function Mechanics:showMessage (str)
  table.insert (self.messages, str)
  if #self.messages > 10 then
    table.remove (self.messages, 1)
  end
end

function Mechanics:display ()
  love.graphics.setColor (1, 1, 1, 0.85)
  love.graphics.rectangle('fill', 10, 10, love.graphics.getWidth() * 0.4, love.graphics.getHeight() *0.4)
  love.graphics.setColor (0, 0, 0, 1)
  love.graphics.setFont(UI.infoFont)
  for i, m in ipairs (self.messages) do
    love.graphics.print (m, 12, 12 + i * 15)
  end

  love.graphics.setColor (0.4, 0.4, 1, 1)
  for i, l in ipairs (self.lines) do
    love.graphics.line (l.p1.x, l.p1.y, l.p2.x, l.p2.y)
  end
  love.graphics.setColor (1, 1, 1, 1)
end

return Mechanics
