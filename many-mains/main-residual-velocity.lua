-- THIS IS NOW A NORMAL VELOCITY
-- BASED ANIMATION AFTER MOUSERELEASED
-- THINGY

-- NOT A ((new anim:move(...) mode test 
-- (anim:move({obj, init_vel, dec}))
-- initial velocity and deceleration))

u = require('external-libs.utility')
anim = require('external-libs.anim')
lume = require('external-libs.lume')

function love.load()
  message = ''

  dims = {
    x = love.graphics.getWidth(),
    y = love.graphics.getHeight()
  }

  component = {
    d_props = {
      x = 100, y = 100,
      width = 100,
      height = 50,
      rx = 2, ry = 2
    }
  }

  on_component = false
  v = {
    x = 0, y = 0
  }

  g_dt = 0

end

function love.update(dt)
  anim:update(dt)
  g_dt = dt
  if not on_component then
    component.d_props.x,
    component.d_props.y = 
    lume.clamp(
      component.d_props.x + 5 * v.x * dt, 
      0, dims.x - component.d_props.width
    ),
    lume.clamp(
      component.d_props.y + 5 * v.y * dt, 
      0, dims.y - component.d_props.height
    )
  end
end

function love.draw()
  love.graphics.rectangle('fill',
    component.d_props.x,
    component.d_props.y,
    component.d_props.width,
    component.d_props.height,
    component.d_props.rx,
    component.d_props.ry
  )

  love.graphics.print(message, 200, 200)
  -- love.graphics.print(string.format(
  --   '%s, %s', v.x, v.y
  -- ), 200, 220)

end

function love.mousepressed(x, y)
  on_component = u.collides(
    {x = x, y = y},
    component.d_props
  )
end

function love.mousemoved(x, y, dx, dy)
  if on_component then

    component.d_props.x, component.d_props.y = 
    lume.clamp(
      component.d_props.x + dx,
      0, dims.x - component.d_props.width
    ),
    lume.clamp(
      component.d_props.y + dy,
      0, dims.y - component.d_props.height
    )

    v.x, v.y = 
    lume.clamp(dx / g_dt, -200, 200),
     lume.clamp(dy / g_dt, -200, 200)
  end
end

function love.mousereleased(x, y)
  on_component = false
  anim:move({
    obj = v,
    to = {
      x = 0,
      y = 0
    },
    seconds = 0.7
  })
end