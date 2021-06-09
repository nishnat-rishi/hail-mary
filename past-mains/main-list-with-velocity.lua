-- lists with scrolling, maybe even
-- adding/removing items with reconciliation??

-- continuing on this after residual-velocity
-- work

local anim = require('external-libs.anim')
local lume = require('external-libs.lume')

function love.load()
  -- -- android stuff
  -- love.window.setMode(360, 640, {resizable=false})
  message = 0

  touches = {}
  last_touched = false

  list_blueprint = {
    list_props = {
      x = 100, y = 100,
      height = 200,
      width = 100,
      gap = 10,
      count = 5,
      orientation = 'vertical'
    },
    d_props = {
      height = 40,
      width = 80,
      rx = 2, ry = 2,
      color_r = 126 / 255, 
      color_g = 201 / 255, 
      color_b = 60 / 255,
      color_a = 1,
    },
    interpolations = {
      input_range = {0, 10, 90, 100}, -- percentages
      output_range = {
        color_a = {0.1, 1, 1, 0.1},
        width = {40, 80, 80, 40}
      }
    }
  }

  prev_list_props = {
    x = list_blueprint.list_props.x,
    y = list_blueprint.list_props.y,
    width = list_blueprint.list_props.width,
    height = list_blueprint.list_props.height
  }

  temporary_objects = {}

  construct_list(list_blueprint, temporary_objects)
  
  scissor_props = {
    x = list_blueprint.list_props.x,
    y = list_blueprint.list_props.y,
    width = list_blueprint.list_props.width,
    height = list_blueprint.list_props.height
  }

  v = {
    y = 0
  }

  g_dt = 0

end

function love.update(dt)
  anim:update(dt)

  message = #anim._change_list

  g_dt = dt

  keep_flush(
    temporary_objects, 
    list_blueprint.list_props,
    prev_list_props
  )

  if next(touches) then
    local id_1, touch_info_1 = next(touches)
    -- at least one touch
    if next(touches, id_1) then
      local id_2, touch_info_2 = next(touches, id_1)
      -- two touches
    else
      -- just one touch
      last_touched = true
      if touch_info_1.on_component then
        list_blueprint.list_props.x,
        list_blueprint.list_props.y = 
        list_blueprint.list_props.x + touch_info_1.dx,
        list_blueprint.list_props.y + touch_info_1.dy

        -- v.y = touch_info_1.dy / dt

        v.y = lume.clamp(
          touch_info_1.dy / dt,
          -200, 200
        )
      end
    end
  else
    -- NO TOUCHES!
    if last_touched then
      last_touched = false
      -- do on_release stuff for 1 finger
      anim:move({
        obj = v,
        to = {
          -- x = 0,
          y = 0
        },
        seconds = 0.7
      })
    end
    -- generic no_touch stuff
    for i, obj in ipairs(temporary_objects) do
      obj.d_props.y = obj.d_props.y + 5 * v.y * dt
    end
  end
end

function love.draw()

  love.graphics.setColor(1, 1, 1)

  love.graphics.print(message, 240, 200)

  love.graphics.setScissor(
    scissor_props.x, scissor_props.y,
    scissor_props.width, scissor_props.height
  )

  for k, v in ipairs(temporary_objects) do
    love.graphics.rectangle(
      'fill',
      v.d_props.x, 
      v.d_props.y,
      v.d_props.width,
      v.d_props.height,
      v.d_props.rx, 
      v.d_props.ry
    )
  end

  love.graphics.setColor(0.2, 1, 0.2, 0.5)
  love.graphics.rectangle('fill',
    scissor_props.x, scissor_props.y,
    scissor_props.width, scissor_props.height
  )

  love.graphics.setScissor()
end

function collides(pointer, d_props, scale) 
  -- uses scale as well hopefully,
  -- rotate is too hard though :( (can be done with line formulas)
  local object = d_props
  scale = scale or 1
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

function construct_list(list_blueprint, temporary_objects)
  local list_props, object = 
    list_blueprint.list_props, list_blueprint.d_props

  local x, y = list_props.x, list_props.y

  for i = 1, list_props.count do
    temporary_objects[i] = { d_props = {} }
    for k, v in pairs(object) do
      temporary_objects[i].d_props[k] = v
    end
    temporary_objects[i].d_props.x,
    temporary_objects[i].d_props.y =
      x, y
    
    if list_props.orientation == 'vertical' then
      y = y + object.height + list_props.gap
    end
  end
end

function keep_flush(
  temporary_objects, 
  list_props, 
  prev_list_props
)

  -- local dx, dy = 0, 0
  local dy = 0

  -- if list_props.x ~= prev_list_props.x then
  --   dx = list_props.x - prev_list_props.x
  --   prev_list_props.x = list_props.x
  -- end

  if list_props.y ~= prev_list_props.y then
    dy = list_props.y - prev_list_props.y
    prev_list_props.y = list_props.y
  end

  for i, obj in ipairs(temporary_objects) do
    -- obj.d_props.x, 
    -- obj.d_props.y = 
    -- obj.d_props.x + dx, obj.d_props.y + dy

    obj.d_props.y = obj.d_props.y + dy
  end
end

function love.touchpressed(id, x, y, dx, dy)
  touches[id] = {x = x, y = y, dx = dx, dy = dy, 
    on_component = collides(
      {x = x, y = y},
      scissor_props
    )
  }
end

function love.touchmoved(id, x, y, dx, dy)
  local touch_info = touches[id]
  touch_info.x, touch_info.y, touch_info.dx, touch_info.dy =
    x, y, dx, dy
end

function love.touchreleased(id, x, y, dx, dy)
  touches[id] = nil
end


function love.keypressed(key)
  if key == 'left' then
    for i, v in ipairs(temporary_objects) do
      anim:move({
        obj = v.d_props,
        to = {
          y = v.d_props.y + 20
        }
      })
    end
  elseif key == 'right' then
    for i, v in ipairs(temporary_objects) do
      anim:move({
        obj = v.d_props,
        to = {
          y = v.d_props.y - 20
        }
      })
    end
  end
end