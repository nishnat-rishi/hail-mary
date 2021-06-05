local utility = {}

function utility.lerp(x, a, b, af, bf)  -- linear interpolation
  return af + ((x - a) / (b - a)) * (bf - af)
end

function utility.normalize(r, g, b, a)
  return r / 255, g / 255, b / 255, a and a / 255 or 1
end

function utility.table_string_nr(t)
  -- return '{' .. table.concat(t, ', ') .. '}'
  local s = '{'
  for i, item in ipairs(t) do
    s = s .. tostring(item) .. (next(t, i) ~=nil and ', ' or '')
  end
  s = s .. '}'
  return s
end

function utility.table_string_dumb(t)
  local s = '{'
  for k, item in pairs(t) do
      s = s .. string.format('%s', item)
    if next(t, k) then
        s = s .. ', '
    end
  end
  s = s .. '}'
  return s
end

local function table_string(t)
  local s = '{'
  for k, item in pairs(t) do
    if type(item) == 'table' then
      s = s .. table_string(item)
    else
      s = s .. string.format('%s', item)
    end
    if next(t, k) then
      s = s .. ', '
    end
  end
  s = s .. '}'
  return s
end
utility.table_string = table_string

function utility.collides(pointer, d_props, scale) 
  -- uses scale as well hopefully,
  -- rotate is too hard though :( (can be done with line formulas)
  local object = d_props
  scale = scale or 1
  local x, y = pointer.x ,pointer.y
  local obj = {
    x = object.x + ((1 - scale) * object.width) / 2,
    y = object.y + ((1 - scale) * object.height) / 2,
    width = scale * object.width,
    height = scale * object.height
  }
  
  return (x >= obj.x and x <= obj.x + obj.width) and
    (y >= obj.y and y <= obj.y + obj.height)
end

function utility.collides_d(pointer, d_props, scale) 
  local object = d_props
  scale = scale or 1
  local x, y = pointer.x ,pointer.y
  local obj = {
    x = object.d.x + ((1 - scale) * object.width) / 2,
    y = object.d.y + ((1 - scale) * object.height) / 2,
    width = scale * object.width,
    height = scale * object.height
  }
  
  return (x >= obj.x and x <= obj.x + obj.width) and
    (y >= obj.y and y <= obj.y + obj.height)
end

local function sign(value)
  return value >= 0 and 1 or -1
end

function utility.diminish(value, amount)
  local ret_val = math.abs(value) - amount

  return ret_val < 0 and
    0 or
    sign(value) * ret_val
end

return utility