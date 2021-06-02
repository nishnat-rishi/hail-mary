-- shared element transitions implementation
-- 2 pages of elements. some elements from each share an identity.
-- make the first go to the second. figure out the transformation
-- to make the first go to the second. need animations for this.

local u = require('external-libs.utility')
local anim = require('external-libs.anim')

function love.load()

  love.window.setTitle('Hail Mary')

  g_key = 'nil'

  current = 2
  unlocked = true

  component = {}

  component[1] = {
    id = 'first',
    d_props = {
      x = 200, y = 100,
      width = 250,
      height = 80,
      rx = 20,
      ry = 20,
      color_r = 130 / 255,
      color_g = 232 / 255,
      color_b = 157 / 255,
      color_a = 255 / 255
    }
  }

  component[2] = { 
    id = 'first',
    d_props = {
      x = 100, 
      y = 100,
      width = 56,
      height = 90,
      rx = 5,
      ry = 5,
      color_r = 244 / 255,
      color_g = 126 / 255,
      color_b = 222 / 255,
      color_a = 100 / 255
    },
  }

  transitory_object = { d_props = {} }

  for prop_name, prop_value in pairs(component[current].d_props) do
    transitory_object.d_props[prop_name] = prop_value
  end

end

function love.update(dt)
  anim:update(dt)
end

function love.draw()

  love.graphics.setColor(0, 0, 0)
  love.graphics.print(current, 400, 400)
  love.graphics.print(
    u.table_string_dumb(anim._change_list),
    400,
    420
  )

  -- drawing transitory_object
  love.graphics.setColor(
      transitory_object.d_props.color_r,
      transitory_object.d_props.color_g,
      transitory_object.d_props.color_b,
      transitory_object.d_props.color_a
    )
    love.graphics.rectangle(
      'fill',
      transitory_object.d_props.x,
      transitory_object.d_props.y,
      transitory_object.d_props.width,
      transitory_object.d_props.height,
      transitory_object.d_props.rx,
      transitory_object.d_props.ry
    )
    love.graphics.setBackgroundColor(1, 1, 1)

end

function love.keypressed(key)
  if unlocked and key == 'left' then
    current = 1
    unlocked = false
    anim:move({
      obj = transitory_object,
      to = component[1].d_props,
      fn = anim.fn.COS,
      on_end = function(self)
        unlocked = true
      end
    })
  end
  if current == 1 and unlocked and key == 'right' then
    current = 2
    unlocked = false
    anim:move({
      obj = transitory_object,
      to = component[2].d_props,
      fn = anim.fn.COS,
      on_end = function(self) 
        unlocked = true
      end
    })
  end
end
