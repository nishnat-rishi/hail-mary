-- gravity simulation

local u = require('external-libs.utility')
local vec2d = require('external-libs.vec2d')
local timer = require('external-libs.timer')

function reset()
  G, M, m, r = 10000, 10, 10, vec2d()
  dv = vec2d()
  v = vec2d()
  init_vel = vec2d()

  before_simulate = false
  simulate = false
  on_component = false

  component.d = vec2d{x = origin.x, y = origin.y}

  points = {}
end

function love.load()

  message = ''

  dims = {
    x = love.graphics.getWidth(),
    y = love.graphics.getHeight()
  }

  origin = vec2d{
    x = dims.x / 3,
    y = dims.y / 3
  }

  -- component = {
  --   d = vec2d{x = origin.x, y = origin.y},
  --   width = 100, height = 50,
  --   rx = 4, ry = 4
  -- }

  component = {
    d = vec2d{x = origin.x, y = origin.y},
    r = 20
  }

  reset()
end

function love.update(dt)
  timer:update(dt)

  message = string.format(
    'simulate: %s\nr: %s\ndv: %s\nv: %s\ninit_vel: %s', 
    simulate,
    r,
    dv,
    v,
    init_vel
  )

  if before_simulate then
    before_simulate = false
    init_vel:update(init_vel:s_mul(1 / dt)) -- complete the init_vel update
    init_vel:clamp{x = 500, y = 500}
    v:update(init_vel)
    simulate = true
    timer:register{
      id = 'ticker',
      duration = 0.05,
      callback = function() 
        points[#points + 1], points[#points + 2] =
          component.d.x, component.d.y
      end,
      periodic = true
    }
  end

  if simulate then
    r:update(origin - component.d)
    dv:update(r:unit():s_mul(G * M  * dt/ (r:mag())))
    v:update(v + dv)
    component.d:update(component.d + v:s_mul(dt))
  end
end

function love.draw()
  love.graphics.print(message, 100, 100)
  
  love.graphics.points(points)

  love.graphics.circle('fill', origin.x, origin.y, 4)

  -- love.graphics.rectangle('fill',
  --   component.d.x, component.d.y,
  --   component.width, component.height,
  --   component.rx, component.ry
  -- )

  love.graphics.circle('line',
    component.d.x, component.d.y,
    component.r
  )
end

function love.mousepressed(x, y)
  timer:deregister('ticker')
  simulate = false
  on_component = u.collides_d_circle({x = x, y = y}, component)
end

function love.mousemoved(x, y, dx, dy)
  local delta = vec2d{x = dx, y = dy}

  if on_component then
    component.d:update(component.d + delta)
    r:update(origin - component.d)
    init_vel:update(delta) -- incomplete init_vel update
  end
end

function love.mousereleased(x, y)
  if on_component then
    on_component = false
    before_simulate = true
  end
end

function love.keypressed(key)
  if key == 'space' then
    reset()
  end
end