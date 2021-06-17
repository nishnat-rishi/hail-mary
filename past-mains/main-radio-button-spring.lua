-- radio buttons

-- TODO
-- i want the inner part of the active radio button to
-- spring to it's new position, if there is any.
-- component to spring to the point wher

local vec2d = require('external-libs.vec2d')
local u = require('external-libs.utility')
local spring = require('external-libs.spring')

function love.load()

  dims = {
    x = love.graphics.getWidth(),
    y = love.graphics.getHeight()
  }

  origin = vec2d{x = 100, y = 50}

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
    color = {r = 73 / 255, g = 190 / 255, b = 230 / 255},
    -- color = {r = 18 / 255, g = 140 / 255, b = 181 / 255},
  }

  active_component_ghost = {
    d = vec2d{x = dims.x / 2, y = -20},
    width = 20, height = 20,
    color = {r = 18 / 255, g = 140 / 255, b = 181 / 255},
  }

  attach_parent(component)
  attach_absolute_coords(component, origin)

  active_spring_id = spring:attach(
    active_component_ghost.d, {
      k = 20, m = 0.08, damp_coeff = 1,
      velocity_limit = {x = 500, y = 500}
    }
  )

  active_radio_button = { component = nil }
  message = 'active_radio_button: -'
  on_component = false
end

function love.update(dt)
  tree_update_absolute_coords(component, origin)
  spring:update(dt)
end

function love.draw()
  tree_draw(component)

  love.graphics.setColor(
    active_component_ghost.color.r,
    active_component_ghost.color.g,
    active_component_ghost.color.b
  )
  love.graphics.rectangle('fill',
    active_component_ghost.d.x, active_component_ghost.d.y,
    active_component_ghost.width, active_component_ghost.height
  )

  love.graphics.setColor(1, 1, 1)
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
    active_component.parent = active_radio_button.component
    attach_absolute_coords_by_parent(active_component, origin)

    spring:hold(active_spring_id)
    spring:release(active_spring_id, nil, active_component.effective_d)

    message = string.format(
      'active_radio_button: %s',
      active_radio_button.component.id
    )
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

function attach_parent(node)
  if node.children then
    for _, child in pairs(node.children) do
      child.parent = node
      attach_parent(child)
    end
  end
end

function attach_absolute_coords(node, origin)
  local pos = origin + node.d

  node.effective_d = pos
  
  if node.children then
    for _, child_node in pairs(node.children) do
      attach_absolute_coords(child_node, pos)
    end
  end
end

function tree_update_absolute_coords(node, origin)
  local pos = origin + node.d

  node.effective_d = pos
  
  if node.children then
    for _, child_node in pairs(node.children) do
      tree_update_absolute_coords(child_node, pos)
    end
  end
end

function attach_absolute_coords_by_parent(node, origin)
  local chain_node = node
  node.effective_d = vec2d.from(node.d)
  while true do
    chain_node = chain_node.parent
    if chain_node then
      node.effective_d:update(
        node.effective_d + chain_node.d
      )
    else
      node.effective_d:update(
        node.effective_d + origin
      )
      return
    end
  end
end

function tree_draw(node)
  love.graphics.setColor(node.color.r, node.color.g, node.color.b)

  love.graphics.rectangle('fill',
    node.effective_d.x, node.effective_d.y,
    node.width, node.height,
    node.rx
  )
  if node.children then
    for _, child_node in pairs(node.children) do
      tree_draw(child_node)
    end
  end
end

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