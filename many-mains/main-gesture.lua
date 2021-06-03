-- gesture responder system

local u = require('external-libs.utility')

function love.load()
  message = '---'
  touches = {}
  dims = {
    x = love.graphics.getWidth(),
    y = love.graphics.getHeight() 
  }

  init_touch_dist = nil

  prev_scale = 1
  scale = 1

  init_slope = nil

  prev_rotation = 0
  rotation = 0

  component = {
    d_props = {
      x = dims.x / 2 - 50, 
      y = dims.y / 2 - 50,
      width = 100,
      height = 100,
      rx = 2,
      ry = 2
    }
  }
end

function love.update(dt)

  if next(touches) then
    local id_1 = next(touches)
    if next(touches, id_1) then
      -- stuff with two fingers!!
      local t_info_1 = touches[id_1]
      local id2, t_info_2 = next(touches, id_1)

      if init_touch_dist == nil then
        init_touch_dist = dist(t_info_1, t_info_2)
      end

      if init_slope == nil then
        init_slope = slope(t_info_1, t_info_2)
      end

      rotation = prev_rotation + math.atan(slope(t_info_1, t_info_2)) -
      math.atan(init_slope)

      scale = math.max(0.2, 
        prev_scale + 0.02 * (
          dist(t_info_1, t_info_2) - init_touch_dist
        )
      )

    else
    -- stuff with one finger only!!

      local t_info = touches[id_1]
      if t_info.on_component then
        component.d_props.x, component.d_props.y = 
        component.d_props.x + t_info.dx,
        component.d_props.y + t_info.dy
      end

      prev_scale = scale
      init_touch_dist = nil

      prev_rotation = math.atan(math.tan(rotation))
      init_slope = nil
    end
  else
    -- on release stuff (if anything)!
    -- no touches present!

    prev_scale = scale
    init_touch_dist = nil

    prev_rotation = math.atan(math.tan(rotation))
    init_slope = nil
  end

end

function love.draw()
  -- let this be present for feedback
  for id, touch_info in pairs(touches) do
    local x, y = touch_info.x, touch_info.y
    love.graphics.circle("fill", x, y, 20)
  end

  love.graphics.print(message, 50, 50)

  -- set to middle of component
  love.graphics.translate(
    component.d_props.x + component.d_props.width / 2,
    component.d_props.y + component.d_props.height / 2
  )
  -- transforms
  love.graphics.rotate(rotation)
  love.graphics.scale(scale)

  -- reset
  love.graphics.translate(
    -(component.d_props.x + component.d_props.width / 2),
    -(component.d_props.y + component.d_props.height / 2)
  )
  -- the thing to move
  love.graphics.rectangle(
      'fill',
      component.d_props.x,
      component.d_props.y,
      component.d_props.width,
      component.d_props.height,
      component.d_props.rx,
      component.d_props.ry
    )
end

function collides(pointer, object, scale) 
  -- uses scale as well hopefully,
  -- rotate is too hard though :( (can be done with line formulas)
  object = object.d_props
  local x, y = pointer.x ,pointer.y
  local obj = {
    x = object.x + ((1 - scale) * object.width) / 2,
    y = object.y + ((1 - scale) * object.height) / 2,
    width = scale * object.width,
    height = scale * object.height
  }
  
  return (x >= obj.x and x <= obj.x + obj.width) and
    (y >= obj.y and y <= obj.y + obj.height)
end

function dist(point_a, point_b)
  return math.sqrt(
    (point_b.y - point_a.y)^2 + 
    (point_b.x - point_a.x)^2
  )
end

function slope(point_a, point_b)
  return (point_a.y - point_b.y) / (point_a.x - point_b.x)
end

----------------

function love.touchpressed(id, x, y, dx, dy)
  touches[id] = {x = x, y = y, dx = dx, dy = dy, 
    on_component = collides({x = x, y = y}, component, scale)
  }
end

function love.touchmoved(id, x, y, dx, dy)
  touch_info = touches[id]
  touch_info.x, touch_info.y, touch_info.dx, touch_info.dy =
    x, y, dx, dy
end

function love.touchreleased(id, x, y, dx, dy)
  touches[id] = nil
end
