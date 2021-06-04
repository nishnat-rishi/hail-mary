-- composition test

function love.load()
  component_tree = { -- root element
    d_props = {
      x = 100, 100,
      width = 100, height = 50,
    },
    children = {
      { -- child #1
        d_props = {
          x = 0, y = 0,
          width = 20, height = 20,
        }
      },
      { -- child #2
        d_props = {
          x = 20, y = 0,
          width = 20, height = 20
        }
      },
      { -- child #3
        d_props = {
          x = 40, y = 0,
          width = 20, height = 20
        }
      }
    }
  }
end

function love.update(dt)
  
end

function love.draw()
  -- love.graphics.rectangle()
end