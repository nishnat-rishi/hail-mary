-- we want to drag and make sure the box resists

local vec2d = require('external-libs.vec2d')
local u = require('external-libs.utility')

function love.load()

  love.graphics.setPointSize(2)

  dims = {
    x = love.graphics.getWidth(),
    y = love.graphics.getHeight()
  }

  origin = vec2d{
    x = dims.x / 3, y = dims.y / 3
  }

  component = {
    d = vec2d{x = origin.x, y = origin.y},
    width = 100, height = 50,
    rx = 4
  }

  k, m = 1, 1

  mouse_delta = vec2d()

  v, dv, a, r = vec2d(), vec2d(), vec2d(), vec2d()

end

function love.update(dt)
  message = string.format(
    'r: %s\non_component: %s\n',
    r,
    on_component
  )
end

function love.draw()
  love.graphics.print(message, 75, 75)

  love.graphics.points(origin.x, origin.y)

  love.graphics.rectangle('fill',
    component.d.x, component.d.y,
    component.width, component.height,
    component.rx
  )
end

function love.mousepressed(x, y)
  on_component = u.collides_d({x = x, y = y}, component)
end

function love.mousemoved(x, y, dx, dy)
  mouse_delta:update{x = dx, y = dy}

  if on_component then
    component.d:update(component.d + mouse_delta:s_mul(0.2))
    r:update(origin - component.d)
  end
end

function love.mousereleased(x, y)
  on_component = false
end