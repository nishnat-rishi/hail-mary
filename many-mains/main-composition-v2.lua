-- main-composition-v2

--[[
  SEPARATE out tree_draw's effective_x and effective_y calculations
  into a tree_calculate_effectives function which will be in
  love.update().
  
  This allows us to access the effectives and easily do some cool
  springy simulations
]]

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
    color = { -- green
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
        collides = false,
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
      {
        d = vec2d{x = 120, y = 0},
        width = 100,
        height = 100,
        rx = 4,
        color = { -- purple
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

  attach_parent(component_root)

  on_component = false
  to_move = { component = nil }
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
  on_component = collision_check(
    {x = x, y = y},
    component_root,
    origin
  )
end

function love.mousemoved(x, y, dx, dy)
  if on_component then
    local delta = vec2d{x = dx, y = dy}
    collision_component_detect(component_root, to_move)
    local new_pos = to_move.component.d + delta
    if to_move.component then
      if to_move.component.parent then -- *1
        if new_pos.x < 0 and delta.x < 0 then
          delta.x = -to_move.component.d.x
        elseif new_pos.x > to_move.component.parent.width - to_move.component.width and delta.x > 0 then
          delta.x = to_move.component.parent.width - (to_move.component.width + to_move.component.d.x)
        end
        if new_pos.y < 0 and delta.y < 0 then
          delta.y = -to_move.component.d.y
        elseif new_pos.y > to_move.component.parent.height - to_move.component.height and delta.y > 0 then
          delta.y = to_move.component.parent.height - (to_move.component.height + to_move.component.d.y)
        end
      end
      
      to_move.component.d:update(
        to_move.component.d + delta
      )
    end
  end
end

function love.mousereleased(x, y)
  if to_move.component then
    parental_clamp(to_move.component)
  end
  to_move.component = nil
  on_component = false
  collision_reset(component_root)
end

-----------------------------

function collision_check(pointer, node, origin)
  local pos = origin + node.d
  if node.collides ~= false then
    node.on_component = u.collides_d(
      pointer,
      {
        d = pos, width = node.width, height = node.height
      }
    )
    return node.on_component
  else 
    local children_collide = false

    if node.children then
      for _, child_node in pairs(node.children) do
        children_collide = children_collide or
          collision_check(pointer, child_node, pos)
      end
    end

    return children_collide
  end
end

function parental_clamp(node)
  if node.parent then
    if node.d.x < 0 then
      node.d.x = 0
    elseif node.d.x > node.parent.width - node.width then
      node.d.x = node.parent.width - node.width
    end
    if node.d.y < 0 then
      node.d.y = 0
    elseif node.d.y > node.parent.height - node.height then
      node.d.y = node.parent.height - node.height
    end
  end
end

function collision_reset(node)
  node.on_component = false
  if node.children then
    for _, child_node in pairs(node.children) do
      collision_reset(child_node)
    end
  end
end

function collision_component_detect(node, component_wrapper)
  if node.on_component then
    component_wrapper.component = node
  end
  if node.children then
    for _, child_node in pairs(node.children) do
      collision_component_detect(child_node, component_wrapper)
    end
  end
end

function attach_parent(node)
  if node.children then
    for _, child in pairs(node.children) do
      child.parent = node
      attach_parent(child)
    end
  end
end

-- Additional Comments
--[[

1.  (FIXED FIXED FIXED)
    This is supposed to clamp our item inside the parent's dimensions
    and it happens!! But unfortunately, after our item reaches the 
    parent's limits, it gets stuck there!!

    Solution: Fixed this and a bunch of following bugs with cute tricks.
    Precalculating the next position was key to ensure that the item
    doesn't get stuck on the walls and also doesn't keep spazzing out
    due to multiple collisions with the walls. After solving this, there
    was the problem of really fast mouse movements, in which case setting
    delta to zero would make the item get stuck somewhat before the wall,
    not flush to it. This was annoying. Fixed this by shortening the delta
    to make sure the item become flush with parent's walls.

]]