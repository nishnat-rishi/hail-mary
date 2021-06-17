local vec2d = require('external-libs.vec2d')

local component = { utils = {} }
component.__index = component
component.__tostring = function (c) return c.id end

------------------------------------------------------------

local function collides_vector(pointer, obj)
  return (
    (pointer.x >= obj.pos.x and pointer.x <= obj.pos.x + obj.width) and
    (pointer.y >= obj.pos.y and pointer.y <= obj.pos.y + obj.height)
  )
end
component.utils.collides = collides_vector

------------------------------------------------------------
-- node level function
function component:create(params)
  params.color = params.color or {r = 1, g = 1, b = 1, a = 1}
  return setmetatable({ -- as of now, no real use of setmetatable here
    id = params.id or 'no_id',
    pos = params.pos or vec2d(),
    effective_pos = params.effective_pos or vec2d(),
    width = params.width or 0,
    height = params.height or 0,
    rx = params.rx or 0,
    ry = params.ry or params.rx or 0,
    collides = params.collides == nil and true or false,
    color = params.color,
    children = params.children
  }, component)
end

-- node level function
function component.switch_parent(node, new_parent)
  if node.parent then
    for index, child_node in pairs(node.parent.children) do
      if node == child_node then
        table.remove(node.parent.children, index)
        if not next(node.parent.children) then
          node.parent.children = nil
        end
        break
      end
    end
  end
  node.parent = new_parent
  if node.parent then
    if not node.parent.children then
    node.parent.children = {}
    end
    table.insert(node.parent.children, node)
  end
end

-- node level function
-- use this on the colliding component
--   (found with collision_component_find)
function component.parental_clamp(node, delta)
  local new_pos = node.pos + delta
  if node.parent then -- *1
    if new_pos.x < 0 and delta.x < 0 then
      delta.x = -node.pos.x
    elseif new_pos.x > node.parent.width - node.width and delta.x > 0 then
      delta.x = node.parent.width - (node.width + node.pos.x)
    end
    if new_pos.y < 0 and delta.y < 0 then
      delta.y = -node.pos.y
    elseif new_pos.y > node.parent.height - node.height and delta.y > 0 then
      delta.y = node.parent.height - (node.height + node.pos.y)
    end
  end
  
  node.pos:update(
    node.pos + delta
  )
end

-- root level function
local function attach_parents(node)
  if node.children then
    for _, child in pairs(node.children) do
      child.parent = node
      attach_parents(child)
    end
  end
end
component.attach_parents = attach_parents

-- root level function
local function update_effectives(node, origin)
  local pos = origin + node.pos

  node.effective_pos:update(pos)
  
  if node.children then
    for _, child_node in pairs(node.children) do
      update_effectives(child_node, pos)
    end
  end
end
component.update_effectives = update_effectives

-- node level function (only updates one node)
local function attach_effectives_by_parent(node, origin)
  local chain_node = node
  node.effective_pos = vec2d.from(node.pos)
  while true do
    chain_node = chain_node.parent
    if chain_node then
      node.effective_pos:update(
        node.effective_pos + chain_node.pos
      )
    else
      node.effective_pos:update(
        node.effective_pos + origin
      )
      return
    end
  end
end
component.attach_effectives_by_parent = attach_effectives_by_parent

-- root/node level function (prereq: update_effectives/attach_effectives)
local function collision_tag(node, pointer)
  local pos = node.effective_pos
  if node.collides then
    node.contains_pointer = collides_vector(
      pointer,
      {
        pos = pos, width = node.width, height = node.height
      }
    )
  end
  local children_contain_pointer = false

  if node.children then
    for _, child_node in pairs(node.children) do
      children_contain_pointer = children_contain_pointer or
        collision_tag(child_node, pointer)
    end
  end

  return children_contain_pointer or node.contains_pointer
end
component.collision_tag = collision_tag

-- root/node level function
local function collision_reset(node)
  node.contains_pointer = false
  if node.children then
    for _, child_node in pairs(node.children) do
      collision_reset(child_node)
    end
  end
end
component.collision_reset = collision_reset

-- root/node level function (prereq: collision_tag)
local function collision_component_find(node, component_wrapper)
  if node.contains_pointer then
    component_wrapper.component = node
  end
  if node.children then
    for _, child_node in pairs(node.children) do
      collision_component_find(child_node, component_wrapper)
    end
  end
end
component.collision_component_find = collision_component_find

------------------------------------------------------------------
-- sensible defaults

-- root level function
function component.load(node, origin)
  node:attach_parents()
  node:update_effectives(origin)
end

-- root level function
function component.update(node, origin)
  node:update_effectives(origin)
end

-- root level function (prereq: attach_effectives)
local function draw(node)
  love.graphics.setColor(node.color.r, node.color.g, node.color.b)

  love.graphics.rectangle('fill',
    node.effective_pos.x, node.effective_pos.y,
    node.width, node.height,
    node.rx
  )
  if node.children then
    for _, child_node in pairs(node.children) do
      draw(child_node)
    end
  end
end
component.draw = draw

------------------------------------------------------------------

return component