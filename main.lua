local component = require('external-libs.component')
local vec2d = require('external-libs.vec2d')
local color = require('external-libs.color')
local error_handler = require('external-libs.event')

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
  origin = vec2d{x = 100, y = 100}

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

  part_creator = function(pos, color)
    return component:create{
      pos = pos,
      width = 140, height = 140,
      color = color.deep,
      children = {
        component:create{
          pos = vec2d{x = 20, y = 20},
          width = 100, height = 100,
          color = color.shallow,
          children = (function()
            local val = {}
            local coords = {
              vec2d{x = 20, y = 20},
              vec2d{x = 20, y = 60},
              vec2d{x = 60, y = 20},
              vec2d{x = 60, y = 60},
            }
    
            for i, vec in ipairs(coords) do
              val[i] = component:create{
                pos = vec,
                width = 20, height = 20,
                color = color.deep,
                rx = 10
              }
            end
    
            return val
          end)()
        }
      }
    }
  end

  board = component:create{
    pos = vec2d(),
    width = 280, height = 280,
    children = {
      part_creator(vec2d{x = 0, y = 0}, color.s.red),
      part_creator(vec2d{x = 140, y = 0}, color.s.blue),
      part_creator(vec2d{x = 0, y = 140}, color.s.green),
      part_creator(vec2d{x = 140, y = 140}, color.s.yellow),
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