local vec2d = {}
vec2d.__index = vec2d
some_stuff = {
  __call = function(vec2d, vector)
    if not vector then
      vector = {}
    end
    if not vector.x then
      vector.x = 0
    end
    if not vector.y then
      vector.y = 0
    end
    return setmetatable(vector, vec2d)
  end,
}
setmetatable(vec2d, some_stuff)

function vec2d.__tostring(vector)
  if not vector.x or not vector.y then
    return 'vector has missing fields.'
  end
  return string.format('{x=%f, y=%f}', vector.x, vector.y)
end

function vec2d.__add(v1, v2)
  return setmetatable({x=v1.x+v2.x, y=v1.y+v2.y}, vec2d)
end

function vec2d.__sub(v1, v2)
  return setmetatable({x=v1.x-v2.x, y=v1.y-v2.y}, vec2d)
end

function vec2d.__unm(v)
  v.x, v.y = -v.x, -v.y
  return v
end

function vec2d.s_mul(v, scalar)
  return setmetatable(
    {x = v.x * scalar, y = v.y * scalar},
    vec2d
  )
end

function vec2d.__eq(v1, v2)
  return v1.x == v2.x and v1.y == v2.y
end

function vec2d.update(v, v_updator)
  v.x = v_updator.x
  v.y = v_updator.y
end

function vec2d.near(v1, v2, threshold)
  return math.abs(v1.x - v2.x) <= threshold and
   math.abs(v1.y - v2.y) <= threshold
end

vec2d.zero = vec2d()

return vec2d