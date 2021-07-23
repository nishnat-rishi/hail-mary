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
  love.graphics.setBackgroundColor(1, 1, 1)
  love.window.setMode(700, 700)

  origin = vec2d{x = 50, y = 50}
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
      border = s(0.5)
    }
  }

  base_create = function(pos, base_color)
    return component:create{
      pos = pos,
      color = color(0, 0, 0),
      width = s.v.base.outer.size,
      height = s.v.base.outer.size,
      children = {
        component:create{
          pos = vec2d{x = s.v.tile.border, y = s.v.tile.border},
          width = s.v.base.outer.size - 2 * s.v.tile.border,
          height = s.v.base.outer.size - 2 * s.v.tile.border,
          color = base_color.deep,
          children = {
            component:create{
              pos = vec2d{
                x = s.v.base.outer.gap,
                y = s.v.base.outer.gap
              },
              width = s.v.base.inner.size,
              height = s.v.base.inner.size,
              color = base_color.shallow,
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
                    color = base_color.deep,
                    rx = s.v.base.inner.token / 2
                  }
                end
        
                return val
              end)()
            }
          }
        }
      }
    }
  end
  
  tile_create = function(pos, base_color)
    return component:create{
    pos = pos,
    width = s.v.tile.size, height = s.v.tile.size,
    color = color(0, 0, 0),
    children = {
        component:create{
          pos = vec2d{x = s.v.tile.border, y = s.v.tile.border},
          width = s.v.tile.size - 2 * s.v.tile.border,
          height = s.v.tile.size - 2 * s.v.tile.border,
          color = base_color
        }
      }
    }
  end

  tile_set_vertical_top_create = function (pos, base_color)
    return component:create{
      pos = pos,
      width = 3 * s.v.tile.size,
      height = 6 * s.v.tile.size,
      children = (function()
        local tiles = {}
        local gap = s.v.tile.size
        local tile_color

        for y = 0, 6-1 do
          for x = 0, 3-1 do
            if (y >= 1 and x == 1) or (x == 2 and y == 1) then
              tile_color = base_color
            else
              tile_color = color(255, 255, 255)
            end
            tiles[#tiles+1] = tile_create(vec2d{x = x * gap, y = y * gap}, tile_color)
          end
        end

        return tiles
      end)()
    }
  end

  tile_set_vertical_bottom_create = function (pos, base_color)
    return component:create{
      pos = pos,
      width = 3 * s.v.tile.size,
      height = 6 * s.v.tile.size,
      children = (function()
        local tiles = {}
        local gap = s.v.tile.size
        local tile_color

        for y = 0, 6-1 do
          for x = 0, 3-1 do
            if (y <= 4 and x == 1) or (x == 0 and y == 4) then
              tile_color = base_color
            else
              tile_color = color(255, 255, 255)
            end
            tiles[#tiles+1] = tile_create(vec2d{x = x * gap, y = y * gap}, tile_color)
          end
        end

        return tiles
      end)()
    }
  end

  tile_set_horizontal_left_create = function (pos, base_color)
    return component:create{
      pos = pos,
      width = 6 * s.v.tile.size,
      height = 3 * s.v.tile.size,
      children = (function()
        local tiles = {}
        local gap = s.v.tile.size
        local tile_color

        for y = 0, 3-1 do
          for x = 0, 6-1 do
            if (x >= 1 and y == 1) or (x == 1 and y == 0) then
              tile_color = base_color
            else
              tile_color = color(255, 255, 255)
            end
            tiles[#tiles+1] = tile_create(vec2d{x = x * gap, y = y * gap}, tile_color)
          end
        end

        return tiles
      end)()
    }
  end

  tile_set_horizontal_right_create = function (pos, base_color)
    return component:create{
      pos = pos,
      width = 6 * s.v.tile.size,
      height = 3 * s.v.tile.size,
      children = (function()
        local tiles = {}
        local gap = s.v.tile.size
        local tile_color

        for y = 0, 3-1 do
          for x = 0, 6-1 do
            if (x  <= 4 and y == 1) or (x == 4 and y == 2) then
              tile_color = base_color
            else
              tile_color = color(255, 255, 255)
            end
            tiles[#tiles+1] = tile_create(vec2d{x = x * gap, y = y * gap}, tile_color)
          end
        end

        return tiles
      end)()
    }
  end

  centre_structure = function (pos)
    return component:create{
      pos = pos,
      children = {
        component:create_triangle{ -- left
          p1 = vec2d(), 
          p2 = vec2d{x = s(30), y = s(30)}, 
          p3 = vec2d{y = s(60)},
          color = color(0, 0, 0),
          children = {
            component:create_triangle{
              p1 = vec2d{x = s.v.tile.border, y = 2 * s.v.tile.border},
              p2 = vec2d{x = s(30) - 1.5 * s.v.tile.border, y = s(30)},
              p3 = vec2d{x = 1.5 * s.v.tile.border, y = s(60) - 3 * s.v.tile.border},
              color = color.s.red.deep
            }
          }
        },
        component:create_triangle{
          p1 = vec2d(), 
          p2 = vec2d{x = s(30), y = s(30)}, 
          p3 = vec2d{x = s(60)},
          color = color(0, 0, 0),
          children = {
            component:create_triangle{
              p1 = vec2d{x = 2 * s.v.tile.border, y = s.v.tile.border},
              p2 = vec2d{x = s(30), y = s(30) - 1.5 * s.v.tile.border},
              p3 = vec2d{x = s(60) - 3 * s.v.tile.border, y = 1.5 * s.v.tile.border},
              color = color.s.blue.deep
            }
          }
        },
        component:create_triangle{
          pos = vec2d{x = s(60), y = s(60)},
          p1 = vec2d(), 
          p2 = vec2d{x = s(-30), y = s(-30)}, 
          p3 = vec2d{y = s(-60)},
          color = color(0, 0, 0),
          children = {
            component:create_triangle{
              p1 = vec2d{x = -s.v.tile.border, y = - 2 * s.v.tile.border},
              p2 = vec2d{x = -(s(30) - 1.5 * s.v.tile.border), y = -s(30)},
              p3 = vec2d{x = -1.5 * s.v.tile.border, y = -(s(60) - 3 * s.v.tile.border)},
              color = color.s.yellow.deep
            }
          }
        },
        component:create_triangle{
          pos = vec2d{x = s(60), y = s(60)},
          p1 = vec2d(), 
          p2 = vec2d{x = s(-30), y = s(-30)}, 
          p3 = vec2d{x = s(-60)},
          color = color(0, 0, 0),
          children = {
            component:create_triangle{
              p1 = vec2d{x = -2 * s.v.tile.border, y = -s.v.tile.border},
              p2 = vec2d{x = -s(30), y = -(s(30) - 1.5 * s.v.tile.border)},
              p3 = vec2d{x = -(s(60) - 3 * s.v.tile.border), y = -1.5 * s.v.tile.border},
              color = color.s.green.deep
            }
          }
        },
      }
    }
  end
  
  board = component:create{
    width = s(301), height = s(301),
    color = color(0, 0, 0),
    children = {
      component:create{
        pos = vec2d{x = s.v.tile.border, y = s.v.tile.border},
        color = color(0, 0, 0),
        children = {
          tile_set_vertical_top_create(vec2d{x = s.v.base.outer.size}, color.s.blue.deep),
          tile_set_vertical_bottom_create(vec2d{x = s.v.base.outer.size, y = s.v.base.outer.size + 3 * s.v.tile.size}, color.s.green.deep),
          tile_set_horizontal_left_create(vec2d{y = s.v.base.outer.size}, color.s.red.deep),
          tile_set_horizontal_right_create(vec2d{x = s.v.base.outer.size + 3 * s.v.tile.size, y = s.v.base.outer.size},color.s.yellow.deep),
          base_create(vec2d{x = s(0), y = s(0)}, color.s.red),
          base_create(vec2d{x = s(180), y = s(0)}, color.s.blue),
          base_create(vec2d{x = s(0), y = s(180)}, color.s.green),
          base_create(vec2d{x = s(180), y = s(180)}, color.s.yellow),
          centre_structure(vec2d{x = s.v.base.outer.size, y = s.v.base.outer.size})
        }
      }
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