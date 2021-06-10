-- radio buttons

-- TODO
-- i want the inner part of the active radio button to
-- spring to it's new position, if there is any.
-- component to spring to the point wher

local vec2d = require('external-libs.vec2d')
local u = require('external-libs.utility')

function love.load()

  origin = vec2d{x = 100, y = 100}

  component = {
    d = vec2d.copy_of(origin),
    width = 300, height = 100,
    color = {r = 18 / 255, g = 140 / 255, b = 181 / 255},
    collides = false,
    children = (function ()
      local buttons = {}
      local x = 30

      for i = 1, 3 do
        buttons[#buttons+1] = {
          id = i,
          d = vec2d{x = x, y = 30},
          width = 40, height = 40,
          color = {r = 73 / 255, g = 190 / 255, b = 230 / 255},
        }
        x = x + 100
      end
      return buttons
    end)()
  }

  active_component = {
    d = vec2d{x = 10, y = 10},
    width = 20, height = 20,
    color = {r = 18 / 255, g = 140 / 255, b = 181 / 255},
  }

  active_radio_button = { component = nil }
  message = '---'
  on_component = false
end

function love.update(dt)

end

function love.draw()
  tree_draw(component, origin)

  love.graphics.print(message, 50, 50)
end

function love.mousepressed(x, y)
  on_component = collision_check(
    {x = x, y = y},
    component,
    origin
  )
  if on_component then
    if active_radio_button.component then
      active_radio_button.component.children = nil
    end
    collision_component_detect(component, active_radio_button)
    active_radio_button.component.children = {
      active_component
    }
  end
end

function love.mousemoved(x, y, dx, dy)
  
end

function love.mousereleased(x, y)
  if on_component then
    on_component = false
  end
  collision_reset(component)
end

--------


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