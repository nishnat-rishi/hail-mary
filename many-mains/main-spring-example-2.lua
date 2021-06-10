local spring = require('external-libs.spring')
local vec2d = require('external-libs.vec2d')

function love.load()
  spring_to = vec2d{x = 100, y = 100}

  component = {
    pos = vec2d.from(spring_to),
    width = 50, height = 50,
    rx = 4
  }

  spring_id = spring:attach(
    component.pos, {dest = spring_to,}
  )

  init_vel = vec2d()

  message = ''
end

function love.update(dt)
  spring:update(dt)
  message = string.format('%s', init_vel)

  if on_component then
    init_vel:update(init_vel:s_mul(1 / dt))
    init_vel:clamp{x = 1000, y = 1000}
  end
end

function love.draw()
  love.graphics.print(message, 50, 50)

  love.graphics.rectangle('fill',
    component.pos.x, component.pos.y,
    component.width, component.height,
    component.rx
  )
end

function love.mousepressed(x, y)
  on_component = collides(
    {x = x, y = y},
    component.pos,
    component
  )

  if on_component then
    spring:hold(spring_id)
  end
end

function love.mousemoved(x, y, dx, dy)
  if on_component then
    local delta = vec2d{x = dx, y = dy}
    component.pos:update(
      component.pos + delta
    )
    init_vel:update(delta)
  end
end

function love.mousereleased(x, y)
  if on_component then
    on_component = false
    spring:release(spring_id, init_vel)
  end
end

function collides(pointer, obj_pos, obj_dim)
  local x, y = pointer.x, pointer.y
  return (x >= obj_pos.x and x <= obj_pos.x + obj_dim.width) and
    (y >= obj_pos.y and y <= obj_pos.y + obj_dim.height)
end