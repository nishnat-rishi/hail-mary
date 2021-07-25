local component = require("external-libs.component")
local color = require("external-libs.color")

function love.load()
  local origin = {x = 100, y = 100}

  color:set_template{
    red = {
      deep = {245, 90, 66},
      shallow = {255, 187, 176},
    },
    green = {
      deep = {34, 212, 75},
      shallow = {145, 255, 172},
    },
    blue = {
      deep = {56, 112, 255},
      shallow = {173, 196, 255},
    },
    yellow = {
      deep = {222, 218, 11},
      shallow = {255, 252, 135}
    }
  }

  c = component:create_texture{
    texture = "assets/star.png",
    -- quad = {x = 140, y = 20, width = 1140, height = 820},
    width = 100, height = 100,
    -- scale = {x = 1, y = 1}
    color = color.s.green.shallow
  }

  c:load(origin)
end

function love.draw()
  c:draw()
end