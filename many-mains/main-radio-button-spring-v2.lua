local vec2d = require('external-libs.vec2d')
local component = require('external-libs.component')
local spring = require('external-libs.spring')

function love.load()

  dims = {
    x = love.graphics.getWidth(),
    y = love.graphics.getHeight()
  }

  origin = vec2d{x = 100, y = 50}

  component_root = component:create{
    pos = vec2d.copy_of(origin),
    width = 300, height = 100,
    color = {r = 18 / 255, g = 140 / 255, b = 181 / 255},
    collides = false,
    children = (function ()
      local buttons = {}
      local x = 30

      for i = 1, 3 do
        buttons[#buttons+1] = component:create{
          id = i,
          pos = vec2d{x = x, y = 30},
          width = 40, height = 40,
          color = {r = 73 / 255, g = 190 / 255, b = 230 / 255},
        }
        x = x + 100
      end
      return buttons
    end)()
  }

  active_component = component:create{
    pos = vec2d{x = 10, y = 10},
    width = 20, height = 20,
    color = {r = 73 / 255, g = 190 / 255, b = 230 / 255},
    collides = false
    -- color = {r = 18 / 255, g = 140 / 255, b = 181 / 255},
  }

  component_root:load(origin)

  active_component_ghost = component:create{
    effective_pos = vec2d.from(component_root.effective_pos),
    width = 20, height = 20,
    color = {r = 18 / 255, g = 140 / 255, b = 181 / 255},
  }

  active_spring_id = spring:attach(
    active_component_ghost.effective_pos, {
      k = 20, m = 0.08, damp_coeff = 1,
      velocity_limit = {x = 500, y = 500}
    }
  )

  active_radio_button = { component = nil }
  message = 'active_radio_button: -'
  on_component = false
end

function love.update(dt)
  if on_component then
    component_root:update(origin)
  end
  spring:update(dt)
end

function love.draw()
  component_root:draw()
  active_component_ghost:draw()

  love.graphics.setColor(1, 1, 1)
  love.graphics.print(message, 50, 50)
end

function love.mousepressed(x, y)
  on_component = component_root:collision_tag{x = x, y = y}
  if on_component then
    component_root:collision_component_find(active_radio_button)
    active_component:switch_parent(active_radio_button.component)
    active_component:attach_effectives_by_parent(origin)
    message = string.format(
      'active_radio_button: %s', active_radio_button.component
    )

    spring:hold(active_spring_id)
    spring:release(
      active_spring_id,
      nil,
      active_component.effective_pos
    )
  end
end

function love.mousereleased(x, y)
  if on_component then
    on_component = false
  end
  component_root:collision_reset()
end