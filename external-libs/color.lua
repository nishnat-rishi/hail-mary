local color = {
  s = {},
  meta = {}
}
local some_stuff = {
  __call = function(...)
    local color, r, g, b, a = ...
    print(r, g, b, a)
    
    return {
      r = r and r / 255 or 1,
      g = g and g / 255 or 1,
      b = b and b / 255 or 1,
      a = a or 1,
    }
  end,
}
setmetatable(color, some_stuff)

function color:initialize(init_params)
  self.meta = init_params -- meta is just our meta controller stuff
end

function color.from_table(color_table)
  return {
    r = color_table[1] and color_table[1] / 255 or 1,
    g = color_table[2] and color_table[2] / 255 or 1,
    b = color_table[3] and color_table[3] / 255 or 1,
    a = color_table[4] or 1,
  }
end

local function is_color_table(val)
  return next(val) == nil or type(val[1]) == 'number'
end

local function update_template_raw(s_node, template_node)
  for k, v in pairs(template_node) do
    if is_color_table(v) then
      s_node[k] = color.from_table(v)
    else
      s_node[k] = {}
      update_template_raw(s_node[k], v)
    end
  end
end

function color:set_template(template)
  color.meta.error_handler:assert(
    not is_color_table(template), 'TOP_LEVEL_COLOR_NODE'
  )
  update_template_raw(color, {s = template})
end

--[[ # TESTING

local u = require('external-libs.utility')

template = {
  red = {
    deep = {245, 90, 66},
    shallow = {255, 187, 176},
  },
  green = {
    deep = {34, 212, 75},
    shallow = {121, 209, 142},
  },
  blue = {
    deep = {56, 112, 255},
    shallow = {173, 196, 255},
  },
  yellow = {
    deep = {219, 216, 29},
    shallow = {255, 253, 140}
  }
}

print(is_color_table(template))
color:set_template(template)
print(u.table_string(color.s))

-- # END_TESTING ]]

return color