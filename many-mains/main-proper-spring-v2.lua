-- main-proper-spring-v2

local u = require('external-libs.utility')
local vec2d = require('external-libs.vec2d')

function simulation_reset()
  
  consecutive_a_zero = 0
  t = 0

  a, d = vec2d(), vec2d()
  v = vec2d()
  dv = vec2d()

  dist = vec2d()
  init_vel = vec2d()
end

function love.load()

  dims = {
    x = love.graphics.getWidth(),
    y = love.graphics.getHeight()
  }

  origin = vec2d{
    x = dims.x / 3,
    y = dims.y / 3
  }

  component = {
    d_props = {
      d = vec2d.copy_of(origin),
      width = 100, height = 50,
      rx = 4, ry = 4
    }
  }

  on_component = false
  before_simulate = false
  simulate = false

  m, k = 0.08, 20

  simulation_reset()

  damping_coeff = 0.1
end

function love.update(dt)
  message = string.format(
    [[
      simulate: %s
      consecutive_a_zero: %f
      a: %s
      v: %s
      d: %s
      init_vel: %s
    ]],
    simulate, consecutive_a_zero, a, v, d, init_vel
  )

  if before_simulate then
    before_simulate = false
    init_vel:update(init_vel:s_mul(1 / dt))
    init_vel:clamp{x = 1000, y = 1000}
    v:update(init_vel)
    simulate = true
  end

  if simulate then
    if consecutive_a_zero >= 0.1 then
      simulate = false
      simulation_reset()
    elseif a:near(vec2d.zero, 100) then
      consecutive_a_zero = consecutive_a_zero + dt
    end
  end

  if simulate then

    -- spring effects
    d:update(component.d_props.d - origin)
    a:update(d:s_mul(-k / m))
    dv:update(a:s_mul(dt))
    t = t + dt
    v:update((v + dv):s_mul(math.exp(-t * damping_coeff)))

    -- final update
    component.d_props.d:update(
      (component.d_props.d + v:s_mul(dt))
    )
  end
end

function love.draw()
  love.graphics.print(message, 100, 100)

  love.graphics.circle('fill', 
    origin.x, origin.y, 4
  )

  love.graphics.rectangle('fill',
    component.d_props.d.x,
    component.d_props.d.y,
    component.d_props.width,
    component.d_props.height,
    component.d_props.rx,
    component.d_props.ry
  )
end

function love.mousepressed(x, y)
  on_component = u.collides_d(
    {x = x, y = y},
    component.d_props
  )
  if on_component then
    dist = component.d_props.d - origin
    simulate = false
  end
end

function love.mousemoved(x, y, dx, dy)
  if on_component then
    local delta = vec2d{x = dx, y = dy}
    dist:update(dist + delta)
    component.d_props.d:update(
      -- component.d_props.d + delta:s_mul(0.4) -- *1
      origin + dist
    )
    init_vel:update(delta)
  end
end

function love.mousereleased(x, y)
  if on_component then
    on_component = false
    before_simulate = true
    t = 0
  end
end

-- Additional Notes

--[[

1 (FIXED FIXED FIXED)
  Sadly, math.sqrt based extension mechanics (you pull the thing,
  and it's supposed to behave as if it has a spring attached to it,
  meaning it's supposed to feel like it's harder to pull, the more
  you pull it (ergo, math.sqrt kind of thing)) is not going too well.
  There's a world where this is possible, but because we're using 
  delta to update and ... hang on a second. Fixed it by setting
  initial dist to the distance between component's current position
  and origin. This solved the problem of the component jumping around
  if you grab it mid motion.

]]