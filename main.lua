local component = require('external-libs.component')
local vec2d = require('external-libs.vec2d')
local color = require('external-libs.color')
local error_handler = require('external-libs.event')
local s = require('external-libs.size')

local u = require('external-libs.utility')

local meta = {
  error_handler = error_handler,
  u = u,
  debug_message = ''
}

color:initialize(meta)

function error_handler:handle(event)
  if event == 'TOP_LEVEL_COLOR_NODE' then
    error('template cannot be a color node (i.e. empty or just filled with numbers)')
  end
end

function love.load()
  origin = vec2d{x = 120, y = 50}
  s.factor = 2

  color:set_template{
    red = {
      deep = {245, 90, 66},
      shallow = {255, 187, 176},
    },
    green = {
      deep = {34, 212, 75},
      shallow = {145, 255, 172},
    },
    blue = {
      deep = {56, 112, 255},
      shallow = {173, 196, 255},
    },
    yellow = {
      deep = {222, 218, 11},
      shallow = {255, 252, 135}
    }
  }

  s:set_variables{
    base = {
      inner = {
        gap = s(16),
        token = s(16),
        size = s(80)
      },
      outer = {
        gap = s(20),
        size = s(20 * 6)
      }
    },
    tile = s(20)
  }

  base_create = function(pos, color)
    return component:create{
      pos = pos,
      width = s.v.base.outer.size, 
      height = s.v.base.outer.size,
      color = color.deep,
      children = {
        component:create{
          pos = vec2d{
            x = s.v.base.outer.gap,
            y = s.v.base.outer.gap
          },
          width = s.v.base.inner.size,
          height = s.v.base.inner.size,
          color = color.shallow,
          children = (function()
            local val = {}
            local coords = {
              vec2d{
                x = s.v.base.inner.gap,
                y = s.v.base.inner.gap
              },
              vec2d{
                x = s.v.base.inner.gap,
                y = s.v.base.inner.token + 2 * s.v.base.inner.gap
              },
              vec2d{
                x = s.v.base.inner.token + 2 * s.v.base.inner.gap,
                y = s.v.base.inner.gap
              },
              vec2d{
                x = s.v.base.inner.token + 2 * s.v.base.inner.gap,
                y = s.v.base.inner.token + 2 * s.v.base.inner.gap
              },
            }
    
            for i, vec in ipairs(coords) do
              val[i] = component:create{
                pos = vec,
                width = s.v.base.inner.token,
                height = s.v.base.inner.token,
                color = color.deep,
                rx = s(16 / 2)
              }
            end
    
            return val
          end)()
        }
      }
    }
  end
  
  tile = component:creator{
    width = s(20), height = s(20),
    color = color(0, 0, 0),
    children = {
      component:create{
        pos = vec2d{x = s(1), y = s(1)},
        width = s(18), height = s(18),
      }
    }
  }

  -- path = component:create{
  -- a 3 x 15 rectangle in which we will place tile() children.
  --}

  board = component:create{
    pos = vec2d(),
    width = s(300), height = s(300),
    children = {
      tile(vec2d{x = s(140)}),
      base_create(vec2d{x = s(0), y = s(0)}, color.s.red),
      base_create(vec2d{x = s(180), y = s(0)}, color.s.blue),
      base_create(vec2d{x = s(0), y = s(180)}, color.s.green),
      base_create(vec2d{x = s(180), y = s(180)}, color.s.yellow),
    }
  }

  board:load(origin)
end

function love.update(dt)
  error_handler:update(dt)
end

function love.draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.printf(meta.debug_message, 20, 20, 400)
  
  board:draw()
end