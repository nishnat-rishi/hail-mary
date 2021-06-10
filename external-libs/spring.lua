-- new library for organic interactions with gestures
-- clamping objects to random stuff and so on depending on
-- active touches

-- (NOPE) uses gestures as input on every frame as opposed to
-- dt with anim:update(dt)

-- ARE YOU WONDERING WHY...
--[[
  ...when you move the origin of the spring, the component sort 
  of dances around and circles around the origin before coming
  to a natural halt? 
  
  it's because the velocity is absolutely clamped between 1000 u/s
  on either axes. which means asymmetric limit violations make the
  simulation pathway weird :) YOU CAN CHANGE THIS AT YOUR PERIL using

]]

-- ROADBLOCK ALERT

--[[
  (FIXED)
  Soooo, this is a very normal wrapper for the spring functionality.
  But we are stuck at a point. We need to include 'init_vel'!!
  I have theorized 'config' to not contain moving parts, so the user
  cannot give 'init_vel' via 'config'. BUT how else is he supposed to
  provide 'init_vel' value?? Well, we can return a spring_wrapper object
  containing 'dest' and 'simulate' and 'init_vel', setting which via
  spring:simulate(component_pos, spring_wrapper) might make simulation 
  happen, but this is too convoluted :(

  (FIXED HOW?)
  just added :hold and :release functions to spring. now we can give
  'init_vel' when :release is called!

]]

local vec2d = require('external-libs.vec2d')

local spring = {
  simulations = {},
  current_pos = nil,
  _pending_removal = {}
}

function spring:attach(component_pos, config)
  config = config or {}
  config.k = config.k or 20
  config.m = config.m or 0.08
  config.damp_coeff = config.damp_coeff or 0.1
  config.velocity_limit = config.velocity_limit or {x = 1000, y = 1000}
  spring.simulations[component_pos] = {
    config = config,
    dest = config.dest or vec2d()
  }
  spring:reset_simulation(component_pos)

  return component_pos
end

function spring:detach(component_pos)
  if spring.current_pos == component_pos then -- is it the current one?
    spring._pending_removal[spring._pending_removal + 1] = component_pos
  elseif spring.simulations[component_pos] then -- is it even in our list?
    spring.simulations[component_pos] = nil
  end
end

function spring:hold(component_pos)
  if spring.simulations[component_pos] then
    spring:reset_simulation(component_pos)
  end
end

function spring:release(component_pos, velocity, updated_dest)
  local item = spring.simulations[component_pos]
  if item then
    item.dest = updated_dest or item.dest
    item.simulate = true
    item.v = vec2d.from(velocity or vec2d.zero)
  end
end

function spring:cleanup()
  for _, component_pos in pairs(spring._pending_removal) do
    spring.simulations[component_pos] = nil
  end
end

function spring:update(dt)
  
  while next(spring.simulations, spring.current_pos) do
    local item
    spring.current_pos, item = next(spring.simulations, spring.current_pos)

    if item.simulate then
      if item.zero_accumulator >= 5 then
        item.simulate = false
        spring:reset_simulation(spring.current_pos)
      elseif item.v:near{x = 1, y = 1} then
        item.zero_accumulator = item.zero_accumulator + dt
      end
    end

    if item.simulate then
      item.r:update(spring.current_pos - item.dest)
      item.a:update(item.r:s_mul(-item.config.k / item.config.m))
      item.dv:update(item.a:s_mul(dt))
      item.t = item.t + dt
      item.v:update(  -- (v + dv) * e^(-t * damping)
        (item.v + item.dv):s_mul(
          math.exp(-item.t * item.config.damp_coeff)
        )
      )
      item.v:clamp(item.config.velocity_limit)

      spring.current_pos:update(
        spring.current_pos + item.v:s_mul(dt)
      )
    end
  end
  spring.current_pos = nil

  spring:cleanup()
end

function spring:reset_simulation(component_pos)
  local item = spring.simulations[component_pos]
  item.simulate = false
  item.r = vec2d()
  item.a = vec2d()
  item.v = vec2d()
  item.dv = vec2d()
  item.t = 0
  item.zero_accumulator = 0
end

return spring