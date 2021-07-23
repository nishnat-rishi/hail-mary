local vec2d = require('external-libs.vec2d')

------------------------------------------------------------
--[[ TRIANGLE related updates

  > collision_tag
  > > collides_vector


  TEXTURE related updates

  > lots of stuff idk

  > but also, make sure scaling works for textures automagically like this->
  image:height() should be scaled down to node.height and so on
  (love.graphics.scale(node.height / image:height())?)
--]]
------------------------------------------------------------

local component = { utils = {}, meta = {} }
component.__index = component
component.__tostring = function (c) return c.id end

function component:initialize(meta)
  self.meta = meta
end

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
    type = 'rect',
    pos = params.pos or vec2d(),
    effective_pos = params.effective_pos or vec2d(),
    width = params.width or 10,
    height = params.height or 10,
    rx = params.rx or 0,
    ry = params.ry or params.rx or 0,
    collides = params.collides == nil and true or false,
    color = params.color,
    children = params.children,
    draw_fn = component.draw_rectangle
  }, component)
end

function component:create_texture(params)
  params.color = params.color or {r = 1, g = 1, b = 1, a = 1}
  return setmetatable({
    id = params.id or 'no_id',
    type = 'texture',
    pos = params.pos or vec2d(),
    effective_pos = params.effective_pos or vec2d(),
    width = params.width or 10,
    height = params.height or 10,
    texture = params.texture,
    collides = params.collides == nil and true or false,
    color = params.color,
    children = params.children,
    draw_fn = component.draw_texture
  }, component)
end

function component:create_triangle(params)
  params.color = params.color or {r = 1, g = 1, b = 1, a = 1}
  return setmetatable({
    id = params.id or 'no_id',
    type = 'triangle',
    pos = params.pos or vec2d(),
    effective_pos = params.effective_pos or vec2d(),
    width = params.width or 10,
    height = params.height or 10,
    p1 = params.p1 or vec2d(),
    p2 = params.p2 or vec2d{x = 10},
    p3 = params.p3 or vec2d{y = 10},
    collides = params.collides == nil and true or false,
    color = params.color,
    children = params.children,
    draw_fn = component.draw_triangle
  }, component)
end

local function copy_component_elements(node)
  if node.children then
    for i, v in ipairs(node.children) do
      node.children[i] = copy_component_elements(v)
    end
  end
  local r = component:create(node)
  return r
end

function component:creator(params)
  return function(pos)
    params.pos = pos
    return copy_component_elements(params)
  end
end

-- we NEED stuff like this to have good defaults
-- function component:arrange_grid(items, cols)

-- end

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

------------------------------------------------------------------

function component.draw_rectangle(node)
  love.graphics.rectangle('fill',
  node.effective_pos.x, node.effective_pos.y,
  node.width, node.height,
  node.rx
)
end

function component.draw_triangle(node)
  love.graphics.polygon('fill',
    node.effective_pos.x + node.p1.x, node.effective_pos.y + node.p1.y,
    node.effective_pos.x + node.p2.x, node.effective_pos.y + node.p2.y,
    node.effective_pos.x + node.p3.x, node.effective_pos.y + node.p3.y
  )
end

function component.draw_texture(node)
  love.graphics.draw(node.texture, node.effective_pos.x, node.effective_pos.y)
end

------------------------------------------------------------------

-- root level function (prereq: attach_effectives)
local function draw(node)
  love.graphics.setColor(node.color.r, node.color.g, node.color.b)

  node:draw_fn()
  
  if node.children then
    for _, child_node in pairs(node.children) do
      draw(child_node)
    end
  end
end
component.draw = draw

------------------------------------------------------------------

return component