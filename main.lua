function love.load()
  component_root = {
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

  attach_parent(component_root)
end

function love.update(dt)
end

function love.draw()
  tree_draw(component_root)
end

-----------------------

function tree_draw(node)
  love.graphics.rectangle('fill',
    node:x(), node:y(),
    node:width(), node:height(),
    node:rx()
  )
  if node.children then
    for _, child_node in pairs(node.children) do
      tree_draw(child_node)
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