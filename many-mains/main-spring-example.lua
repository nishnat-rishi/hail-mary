local spring = require('external-libs.spring')
local vec2d = require('external-libs.vec2d')

function love.load()
  spring_to = vec2d{x = 100, y = 100}

  component = {
    pos = vec2d.from(spring_to),
    width = 50, height = 50,
    rx = 4
  }

  spring_id = spring:attach(component.pos)
end

function love.update(dt)
  spring:update(dt)
end

function love.draw()
  love.graphics.rectangle('fill',
    component.pos.x, component.pos.y,
    component.width, component.height,
    component.rx
  )
end

function love.mousereleased(x, y)
  spring:hold(spring_id)
  spring:release(spring_id, nil, {x = x, y = y})
end

function love.keypressed(key)
  if key == 'space' then
    spring:detach(spring_id)
  end
end