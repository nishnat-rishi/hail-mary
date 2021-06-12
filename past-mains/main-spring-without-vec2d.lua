local u = require('external-libs.utility')

function love.load()

  dims = {
    x = love.graphics.getWidth(),
    y = love.graphics.getHeight()
  }

  origin = {
    x = dims.x / 3,
    y = dims.y / 3
  }

  component = {
    d_props = {
      x = origin.x, y = origin.y,
      width = 100, height = 50,
      rx = 4, ry = 4
    }
  }

  on_component = false
  simulate = false

  m, k = 1, 20
  a, d = {x = 0, y = 0}, {x = 0, y = 0}
  v = {x = 0, y = 0}
  dv = {x = 0, y = 0}
  t = 0
  damping_coeff = 0.1
end

function love.update(dt)

  if simulate then
    d.x, d.y = 
      component.d_props.x - origin.x,
      component.d_props.y - origin.y
    a.x, a.y = -k * d.x / m, -k * d.y / m
    dv.x, dv.y = a.x * dt, a.y * dt
    t = t + dt
    v.x, v.y =
      math.exp(-t * damping_coeff) * (v.x + dv.x),
      math.exp(-t * damping_coeff) * (v.y + dv.y)

    component.d_props.x,
    component.d_props.y =
      component.d_props.x + v.x * dt,
      component.d_props.y + v.y * dt
  end
end

function love.draw()

  love.graphics.circle('fill', 
    origin.x, origin.y, 4
  )

  love.graphics.rectangle('fill',
    component.d_props.x,
    component.d_props.y,
    component.d_props.width,
    component.d_props.height,
    component.d_props.rx,
    component.d_props.ry
  )
end

function love.mousepressed(x, y)
  on_component = u.collides(
    {x = x, y = y},
    component.d_props
  )
  if on_component then
    simulate = false
  end
end

function love.mousemoved(x, y, dx, dy)
  if on_component then
    component.d_props.x,
     component.d_props.y = 
     component.d_props.x + dx,
     component.d_props.y + dy
  end
end

function love.mousereleased(x, y)
  on_component = false
  simulate = true
  t = 0
end