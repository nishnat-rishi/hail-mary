-- redoing this for mouse, also removing anim from this!

-- hear me out, trying to use the composition-v2 model to create the
-- list of items. let's see how this goes ...

-- lots of refactoring needed woop!

--[[
  Agenda:

  > remove all anim:...() references
  > compose the list items instead of using hardcoded stuff

]]

local u = require('external-libs.utility')
local vec2d = require('external-libs.vec2d')

function love.load()
  
  origin = vec2d{
    x = 0, y = 0
  }

  component = {
    d = vec2d{x = 100, y = 100},
    width = 100,
    height = 510,
    rx = 0,
    color = {
      r = 138 / 255,
      g = 189 / 255,
      b = 94 / 255,
      a = 1,
    },
    children = (
      function ()
        local children = {}
        local gap = 10
        local x, y = gap, gap
        local item_props = {
          width = 80,
          height = 40
        }
        for _ = 1, 10 do
          children[#children+1] = {
            d = vec2d{x = x, y = y},
            width = item_props.width,
            height = item_props.height,
            rx = 2,
            collides = false,
            color = {
              r = 170 / 255, 
              g = 232 / 255, 
              b = 155 / 255,
              a = 1,
            }
          }
          y = y + item_props.height + gap
        end
        return children
      end
    )(),
    interpolations = { -- not being used currently
      input_range = {0, 10, 90, 100}, -- percentages
      output_range = {
        color_a = {0.1, 1, 1, 0.1},
        width = {40, 80, 80, 40}
      }
    }
  }

  attach_parent(component)

  scissor_props = {
    d = vec2d.copy_of(component.d),
    width = component.width,
    height = component.height / 3
  }

  on_component = false
  to_move = nil
end

function love.update(dt)

end

function love.draw()

  love.graphics.setScissor(
    scissor_props.d.x, scissor_props.d.y,
    scissor_props.width, scissor_props.height
  )

  love.graphics.rectangle('line',
    scissor_props.d.x, scissor_props.d.y,
    scissor_props.width, scissor_props.height
  )

  component_tree_draw(component, origin)

  -- love.graphics.setScissor()
end

function love.mousepressed(x, y)
  on_component = collision_check(
    {x = x, y = y},
    component,
    origin
  )
end

function love.mousemoved(x, y, dx, dy)
  if on_component then
    local delta = vec2d{x = 0, y = dy}
    tree_move(component)
    local new_pos = to_move.d + delta
    if to_move then
      if to_move.parent then -- *1
        if new_pos.x < 0 and delta.x < 0 then
          delta.x = -to_move.d.x
        elseif new_pos.x > to_move.parent.width - to_move.width and delta.x > 0 then
          delta.x = to_move.parent.width - (to_move.width + to_move.d.x)
        end
        if new_pos.y < 0 and delta.y < 0 then
          delta.y = -to_move.d.y
        elseif new_pos.y > to_move.parent.height - to_move.height and delta.y > 0 then
          delta.y = to_move.parent.height - (to_move.height + to_move.d.y)
        end
      end
      
      to_move.d:update(
        to_move.d + delta
      )
    end
  end
end

function love.mousereleased(x, y)
  to_move = nil
  on_component = false
  collision_reset(component)
end

------------------------------------------

function collision_check(pointer, node, origin)
  local pos = origin + node.d
  if node.collides ~= false then
    node.on_component = u.collides_d(
      pointer,
      {
        d = pos, width = node.width, height = node.height
      }
    )

    local children_collide = false

    if node.children then
      for _, child_node in pairs(node.children) do
        children_collide = children_collide or
          collision_check(pointer, child_node, pos)
      end
    end

    return node.on_component or children_collide
  else 
    return false
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

function component_tree_draw(node, origin)
  local pos = origin + node.d

  love.graphics.setColor(node.color.r, node.color.g, node.color.b)

  love.graphics.rectangle('fill',
    pos.x, pos.y,
    node.width, node.height,
    node.rx
  )
  if node.children then
    for _, child_node in pairs(node.children) do
      component_tree_draw(child_node, pos)
    end
  end
end

function tree_move(node)
  if node.on_component then
    to_move = node
  end
  if node.children then
    for _, child_node in pairs(node.children) do
      tree_move(child_node)
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