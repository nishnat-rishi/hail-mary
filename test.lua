-- make it so that a new tree is created with position changes,
-- or is it sufficient to do this in place?

local u = require('external-libs.utility')

local function position(node, parent)
  local new_node = {}

  for k, v in pairs(node) do
    if type(v) == 'function' then
      new_node[k] = v(parent)
    else
      new_node[k] = v
    end
  end

  return new_node
end

local function attach_parent(node)
  if node.children then
    for _, child in pairs(node.children) do
      child.parent = node
      attach_parent(child)
    end
  end
end

function tree_draw(node)
  -- love.graphics.rectangle('fill',
  --   node:x(), node:y(),
  --   node:width(), node:height(),
  --   node:rx()
  -- )
  print(string.format('drawing rectangle{x = %d, y = %d, width = %d, height = %d}', node:x(), node:y(), node:width(), node:height()))
  if node.children then
    for _, child_node in pairs(node.children) do
      tree_draw(child_node)
    end
  end
end

------------------------

local component_root = {
  x = function (self) return 10 end,
  y = function (self) return 20 end,
  width = function (self) return 300 end,
  height = function (self) return 400 end,
  rx = function (self) return 4 end,
  children = {
    {
      x = function(self) return self.parent:x() end,
      y = function(self) return self.parent:y() + 10 end,
      width = function(self) return self.parent:width() + 20 end, 
      height = function (self) return 10 end,
      rx = function (self) return 4 end
    },
    {
      x = function(self) return self.parent:x() + 20 end,
      y = function(self) return self.parent:y() end,
      width = function(self) return self.parent:width() / 3 end, 
      height = function (self) return 10 end,
      rx = function (self) return 4 end,
      children = {
        {
          x = function (self) return self.parent:x() + 20 end,
          y = function (self) return self.parent:y() + 30 end,
          width = function (self) return 400 end, 
          height = function (self) return 20 end,
          rx = function (self) return 4 end
        }
      }
    },
  }  
}

-- local tree = position(component_root)
-- local tree = process(component_root, {})
attach_parent(component_root)
tree_draw(component_root)

local LOL
-- print(u.table_string(component_root))

