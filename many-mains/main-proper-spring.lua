local u = require('external-libs.utility')
local vec2d = require('external-libs.vec2d')

function simulation_reset()
  consecutive_a_zero = 0
  t = 0

  a, d = vec2d(), vec2d()
  v = vec2d()
  dv = vec2d()

  init_vel = vec2d()
end

function love.load()

  dims = {
    x = love.graphics.getWidth(),
    y = love.graphics.getHeight()
  }

  origin = vec2d({
    x = dims.x / 3,
    y = dims.y / 3
  })

  component = {
    d_props = {
      d = vec2d({x = origin.x, y = origin.y}),
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
    'simulate: %s\nconsecutive_a_zero: %f\na: %s\nv: %s\nd: %s',
    simulate, consecutive_a_zero, a, v, d
  )

  if before_simulate then
    before_simulate = false
    init_vel:update(init_vel:s_mul(1 / dt))
    init_vel:clamp{x = 200, y = 200}
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
    simulate = false
  end
end

function love.mousemoved(x, y, dx, dy)
  local delta = vec2d({x = dx, y = dy})
  if on_component then
    component.d_props.d:update(
      component.d_props.d + delta
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