local spring = require "external-libs.spring"
-- redoing this for mouse, also removing anim from this!

-- hear me out, trying to use the composition-v2 model to create the
-- list of items. let's see how this goes ...

-- lots of refactoring needed woop!

--[[
  Agenda:

  > (DONE) remove all anim:...() references
  > (DONE) compose the list items instead of using hardcoded stuff

]]

local u = require('external-libs.utility')
local vec2d = require('external-libs.vec2d')


function simulation_reset()
  init_vel = vec2d()
  v, dv = vec2d(), vec2d()
  mouse_acc = vec2d()

  spring_acc, r = vec2d(), vec2d()

  consecutive_nearness = 0
  simulate = false
  underflow = false
  t = 0

  before_simulate = false
  simulate = false

  underflow, overflow = false, false

end

function love.load()
  
  origin = vec2d{
    x = 0, y = 0
  }

  component = {
    d = vec2d{x = 100, y = 100},
    width = 100,
    height = 510,
    rx = 0,
    color = { -- blue
      r = 66 / 255, 
      g = 155 / 255, 
      b = 245 / 255
    },
    -- color = { -- green
    --   r = 138 / 255,
    --   g = 189 / 255,
    --   b = 94 / 255,
    --   a = 1,
    -- },
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
            color = { -- light blue
              r = 117 / 255, 
              g = 186 / 255, 
              b = 255 / 255
            }
            -- color = { -- light green
            --   r = 170 / 255, 
            --   g = 232 / 255, 
            --   b = 155 / 255,
            --   a = 1,
            -- }
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

  scissor_props = {
    d = vec2d.copy_of(component.d),
    width = component.width,
    height = component.height / 3
  }

  k, m = 1000, 15
  damping_coeff = 0.1

  on_component = false

  simulation_reset()

  message = ''
end

function love.update(dt)
  message = string.format(
    [[
      on_component: %s
      before_simulate: %s
      simulate: %s
      underflow: %s
      overflow: %s
      r: %s
      spring_acc: %s
      v: %s
      dv: %s
      component.d: %s
      t: %f
    ]], 
    on_component,
    before_simulate,
    simulate, 
    underflow, 
    overflow, 
    r, 
    spring_acc, 
    v, 
    dv, 
    component.d, 
    t
  )

  if before_simulate then
    before_simulate = false
    init_vel:update(init_vel:s_mul(1 / dt))
    init_vel:clamp{y = 1000}
    v:update(init_vel)
    mouse_acc:update(-init_vel)
    simulate = true
  end

  if simulate then
    local delta

    if underflow then
      -- spring stuff
      r:update(component.d - scissor_props.d)
      spring_acc:update(r:s_mul(-k / m))
      dv:update(spring_acc:s_mul(dt))
      t = t + dt
      v:update((v + dv):s_mul(math.exp(-t * damping_coeff)))

      if v:near{y = 0.1} then
        consecutive_nearness = consecutive_nearness + dt
      end

      if consecutive_nearness >= 0.5 then
        simulation_reset()
      end

      delta = v:s_mul(dt)

    elseif overflow then
      -- spring stuff
      r:update{x = 0, y = (component.d.y + component.height) - (scissor_props.d.y + scissor_props.height)}
      spring_acc:update(r:s_mul(-k / m))
      dv:update(spring_acc:s_mul(dt))
      t = t + dt
      v:update((v + dv):s_mul(math.exp(-t * damping_coeff)))

      if v:near{y = 0.1} then
        consecutive_nearness = consecutive_nearness + dt
      end

      if consecutive_nearness >= 0.5 then
        simulation_reset()
      end

      delta = v:s_mul(dt)

    else
      dv:update(mouse_acc:s_mul(dt))
      v:update(v + dv)

      delta = v:s_mul(dt)

      -- stop when you touch the walls
      local new_pos = component.d + delta

      local scroll_offset = scissor_props.d.y - new_pos.y
      local edge_delta = scissor_props.d.y - component.d.y
      local scroll_limit = component.height - scissor_props.height
      
      if scroll_offset < 0 then
        -- underflow = true
        delta.y = edge_delta
      elseif scroll_offset > scroll_limit then
        -- overflow = true
        delta.y = edge_delta - scroll_limit
      else
        -- underflow, overflow = false, false
      end

      if v:near{y = 10} then
        v = vec2d()
        simulate = false
        t = 0
      end

    end

    component.d:update(
      component.d + delta
    )
  end
end

function love.draw()
  love.graphics.print(message, 300, 100)

  love.graphics.setScissor(
    scissor_props.d.x, scissor_props.d.y,
    scissor_props.width, scissor_props.height
  )

  love.graphics.rectangle('line',
    scissor_props.d.x, scissor_props.d.y,
    scissor_props.width, scissor_props.height
  )

  component_tree_draw(component, origin)

  love.graphics.setScissor()

  love.graphics.setColor(1, 1, 1)
  love.graphics.print(message, 300, 100)
end

function love.mousepressed(x, y)
  on_component = u.collides_d(
    {x = x, y = y},
    scissor_props
  )
  if on_component then
    simulation_reset()
  end
end

function love.mousemoved(x, y, dx, dy)

  if on_component then
    local delta = vec2d{x = 0, y = dy}

    local new_pos = component.d + delta

    local scroll_offset = scissor_props.d.y - new_pos.y
    -- local edge_delta = scissor_props.d.y - component.d.y
    local scroll_limit = component.height - scissor_props.height
    
    if scroll_offset < 0 then
      underflow = true
      delta.y = delta.y * 0.3
      -- delta.y = edge_delta
    elseif scroll_offset > scroll_limit then
      overflow = true
      delta.y = delta. y * 0.3
      -- delta.y = edge_delta - scroll_limit
    else
      underflow, overflow = false, false
    end

    component.d:update(
      component.d + delta
    )

    init_vel:update(delta)
  end
end

function love.mousereleased(x, y)
  if on_component then
    on_component = false
    before_simulate = true
  end
end

------------------------------------------

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