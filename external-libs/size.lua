local size = {
  factor = 1,
  base = 100,
  v = {}
}
local some_stuff = {
  __call = function(size, val)
    return size.factor * val
  end
}
setmetatable(size, some_stuff)

size.f = function(fraction)
  return size.base * fraction
end

size.p = function(percentage)
  return size.base * percentage
end

local function update_vars_raw(v_node, vars_node)
  for k, v in pairs(vars_node) do
    if type(v) == 'number' then
      v_node[k] = v
    else
      v_node[k] = {}
      update_vars_raw(v_node[k], v)
    end
  end
end

function size:set_variables(vars)
  size.v = {}
  update_vars_raw(size, {v = vars})
end

return size

--[[ # More things that the user should be able to do

> Make relative sizes (s.p('100%')). Here the s.p() is better than
  s() in the sense that you can define a simple implementation, thus
  allowing us to use each form intensively. As opposed to having
  multiple conditionals inside a single s() defining each 
  implementation, which would be costly if called repeatedly.

  For this, there can be a base like s.base = 100, and then all %
  values will follow from that base. If we do this, and if we have
  s.p(), we can even make it very simple and have s.p(number), so that
  the implementation doesn't involve converting from string to number
  values, and we can directly use a string. It can even be fractional
  values, like s.f(0.25) or s.f(0.5) which will be even better.

> Another useful thing would be to have variables. And these would
  be subject to factor changes in the future as well. Something like
  s.v would be a tree of values. s.v.token.size, s.v.token.width and
  so on. We can define this earlier, and use it liberally.
--]]