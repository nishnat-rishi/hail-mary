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
component:initialize(meta)

function error_handler:handle(event)
  if event == 'TOP_LEVEL_COLOR_NODE' then
    error('template cannot be a color node (i.e. empty or just filled with numbers)')
  end
end

function love.load()
  origin = vec2d{x = 150, y = 50}
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
    tile = {
      size = s(20),
      border = s(1)
    }
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
                rx = s.v.base.inner.token / 2
              }
            end
    
            return val
          end)()
        }
      }
    }
  end
  
  tile_create = function(pos)
    return component:create{
    pos = pos,
    width = s.v.tile.size, height = s.v.tile.size,
    color = color(0, 0, 0),
    children = {
        component:create{
          pos = vec2d{x = s.v.tile.border, y = s.v.tile.border},
          width = s.v.tile.size - 2 * s.v.tile.border,
          height = s.v.tile.size - 2 * s.v.tile.border,
        }
      }
    }
  end

  tile_set = component:create{
    width = 3 * s.v.tile.size,
    height = (3 + 6 + 6) * s.v.tile.size,
    children = (function()
      x_init, y_init = s.v.base.outer.size, 0
      x_end = s.v.base.outer.size + 2 * s.v.tile.size
      y_end = 0 + (3 + 6 + 6 - 1) * s.v.tile.size
      gap = s.v.tile.size
      tiles = {}

      -- meta.debug_message = u.debug_values{
      --   x_init = x_init,
      --   y_init = y_init,
      --   x_end = x_end,
      --   y_end = y_end,
      --   gap = gap
      -- }

      -- tiles[1] = tile_create(vec2d{x = x_init, y = y_init})
      -- tiles[2] = tile_create(vec2d{x = x_init + gap, y = y_init + gap})
      -- tiles[3] = tile_create(vec2d{x = x_init + 2 * gap, y = y_init + 2 * gap})

      -- meta.debug_message = meta.debug_message .. '\n\n'
      -- meta.debug_message = meta.debug_message .. string.format('%p\n', tiles[1])
      -- meta.debug_message = meta.debug_message .. string.format('%p\n\n', tiles[1].children[1])
      -- meta.debug_message = meta.debug_message .. string.format('%p\n', tiles[2])
      -- meta.debug_message = meta.debug_message .. string.format('%p\n\n', tiles[2].children[1])
      -- meta.debug_message = meta.debug_message .. string.format('%p\n', tiles[3])
      -- meta.debug_message = meta.debug_message .. string.format('%p\n\n', tiles[3].children[1])
      
      for y = y_init, y_end, gap do
        for x = x_init, x_end, gap do
          tiles[#tiles+1] = tile_create(vec2d{x = x, y = y})
        end
      end

      return tiles
    end)()
  }

  -- path = component:create{
  -- a 3 x 15 rectangle in which we will place tile() children.
  --}

  centre_structure = function (pos)
    return component:create{
      pos = pos,
      children = {
        component:create_triangle{ -- left
          p1 = vec2d(), 
          p2 = vec2d{x = s(30), y = s(30)}, 
          p3 = vec2d{y = s(60)},
          color = color.s.red.deep
        },
        component:create_triangle{
          p1 = vec2d(), 
          p2 = vec2d{x = s(30), y = s(30)}, 
          p3 = vec2d{x = s(60)},
          color = color.s.blue.deep
        },
        component:create_triangle{
          pos = vec2d{x = s(60), y = s(60)},
          p1 = vec2d(), 
          p2 = vec2d{x = s(-30), y = s(-30)}, 
          p3 = vec2d{y = s(-60)},
          color = color(0, 0, 0),
          children = {
            component:create_triangle{
              pos = vec2d{x = s(-1), y = s(-1)},
              p1 = vec2d(),
              p2 = vec2d{x = s(-28), y = s(-28)},
              p3 = vec2d{y = s(-56)},
              color = color.s.yellow.deep
            }
          }
        },
        component:create_triangle{
          pos = vec2d{x = s(60), y = s(60)},
          p1 = vec2d(), 
          p2 = vec2d{x = s(-30), y = s(-30)}, 
          p3 = vec2d{x = s(-60)},
          color = color.s.green.deep,
          children = {

          }
        },
      }
    }
  end
  
  board = component:create{
    pos = vec2d(),
    width = s(300), height = s(300),
    children = {
      tile_set,
      base_create(vec2d{x = s(0), y = s(0)}, color.s.red),
      base_create(vec2d{x = s(180), y = s(0)}, color.s.blue),
      base_create(vec2d{x = s(0), y = s(180)}, color.s.green),
      base_create(vec2d{x = s(180), y = s(180)}, color.s.yellow),
      centre_structure(vec2d{x = s.v.base.outer.size, y = s.v.base.outer.size}),
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