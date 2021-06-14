-- main-composition-v3

local component = require('external-libs.component')
local vec2d = require('external-libs.vec2d')

function love.load()
  origin = vec2d{
    x = 0, y = 0
  }

  component_root = component:create{
    id = 'big green one',
    pos = vec2d{x = 100, y = 100},
    width = 300,
    height = 300,
    rx = 4,
    color = { -- green
      r = 125 / 255,
      g = 186 / 255,
      b = 131 / 255
    },
    children = {
      component:create{
        id = 'medium red one',
        pos = vec2d{x = 0, y = 0},
        width = 100,
        height = 100,
        rx = 4,
        -- color = { -- light blue
        --   r = 111 / 255,
        --   g = 175 / 255,
        --   b = 191 / 255
        -- },
        color = { -- light red
          r = 219 / 255,
          g = 121 / 255,
          b = 110 / 255
        },
      },
      component:create{
        id = 'medium purple one',
        collides = false,
        pos = vec2d{x = 120, y = 0},
        width = 100,
        height = 100,
        rx = 4,
        color = { -- purple
          r = 109 / 255,
          g = 113 / 255,
          b = 189 / 255
        },
        children = {
          component:create{
            id = 'small pink one',
            pos = vec2d{x = 30, y = 30},
            width = 40,
            height = 20,
            rx = 4,
            color = { -- magenta
              r = 217 / 255,
              g = 115 / 255,
              b = 215 / 255
            }
          }
        }
      },
    }  
  }

  component_root:load(origin)

  on_component = false
  to_move = { component = nil }
end

function love.update(dt)
  if on_component then
    component_root:update(origin)
  end
end

function love.draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.print(string.format('%s', to_move.component), 50, 50)

  component_root:draw()
end

--------------------------------------

function love.mousepressed(x, y)
  on_component = component_root:collision_tag{x = x, y = y}
  if on_component then
    component_root:collision_component_find(to_move)
  end
end

function love.mousemoved(x, y, dx, dy)
  if on_component then
    local delta = vec2d{x = dx, y = dy}
    to_move.component:parental_clamp(delta)
  end
end

function love.mousereleased(x, y)
  if on_component then
    to_move.component = nil
    on_component = false
    component_root:collision_reset()
  end
end