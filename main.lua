local u = require('external-libs.utility')
local vec2d = require('external-libs.vec2d')

function love.load()
  origin = vec2d{
    x = 0, y = 0
  }

  component_root = {
    d = vec2d{x = 20, y = 20},
    width = 300,
    height = 300,
    rx = 4,
    color = {
      r = 125 / 255, 
      g = 186 / 255, 
      b = 131 / 255
    },
    children = {
      {
        d = vec2d{x = 0, y = 0},
        width = 100,
        height = 100,
        rx = 4,
        color = {
          r = 111 / 255, 
          g = 175 / 255, 
          b = 191 / 255
        }
      },
      {
        d = vec2d{x = 120, y = 0},
        width = 100,
        height = 100,
        rx = 4,
        color = {
          r = 109 / 255,
          g = 113 / 255,
          b = 189 / 255
        },
        children = {
          {
            d = vec2d{x = 30, y = 30},
            width = 40,
            height = 20,
            rx = 4,
            color = {
              r = 217 / 255,
              g = 115 / 255,
              b = 215 / 255
            }
          }
        }
      },
    }  
  }

  on_component = false
end

function love.update(dt)
end

function love.draw()
  tree_draw(component_root, origin)
end

-----------------------

function tree_draw(node, origin)
  local pos = origin + node.d

  love.graphics.setColor(node.color.r, node.color.g, node.color.b)

  love.graphics.rectangle('fill',
    pos.x, pos.y,
    node.width, node.height,
    node.rx
  )
  if node.children then
    for _, child_node in pairs(node.children) do
      tree_draw(child_node, pos)
    end
  end
end

-----------------------

function love.mousepressed(x, y)
  on_component = u.collides_d(
    {x = x, y = y}, component_root
  )
end

function love.mousemoved(x, y, dx, dy)
  if on_component then
    local delta = vec2d{x = dx, y = dy}
    component_root.d:update(
      component_root.d + delta
    )
  end
end

function love.mousereleased(x, y)
  on_component = false
end