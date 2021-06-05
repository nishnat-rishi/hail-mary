local u = require('external-libs.utility')
local vec2d = require('external-libs.vec2d')

function love.load()

  message = ''

  dims = {
    x = love.graphics.getWidth(),
    y = love.graphics.getHeight()
  }

  origin = vec2d({
    x = dims.x / 3,
    y = dims.y / 3
  })

  component = {
    d = vec2d({x = origin.x, y = origin.y}),
    width = 100, height = 50,
    rx = 4, ry = 4
  }
end

function love.update(dt)

end

function love.draw()
  love.graphics.print(message, 100, 100)

  love.graphics.circle('fill', origin.x, origin.y, 4)

  love.graphics.rectangle('fill',
    component.d.x, component.d.y, 
    component.width, component.height,
    component.rx, component.ry
  )
end

function love.mousepressed(x, y)
  on_component = u.collides_d({x = x, y = y}, component)
end

function love.mousemoved(x, y, dx, dy)
  local delta = vec2d({x = dx, y = dy})
  
  if on_component then
    component.d:update(component.d + delta)
  end
end

function love.mousereleased(x, y)
  if on_component then
    on_component = false
    simulate = true
  end
end