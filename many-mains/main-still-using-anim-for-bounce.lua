local u = require('external-libs.utility')
local lume = require('external-libs.lume')

local anim = require('external-libs.anim')


function love.load()

  message = ''

  anim:add_fn(
    'EASE_OUT_BOUNCE',
    function(x) 
      local n1, d1 = 7.5625, 2.75

      if x < 1 / d1 then
        return n1 * x * x
      elseif x < 2 / d1 then
        return n1 * (x - 1.5 / d1) * (x - 1.5 / d1) + 0.75
      elseif x < 2.5 / d1 then
        return n1 * (x - 2.25 / d1) * (x - 2.25 / d1) + 0.9375
      else
        return n1 * (x - 2.625 / d1) * (x - 2.625 / d1) + 0.984375
      end
    end,
    0,
    1
  )

  anim:add_fn(
    'EASE_OUT_ELASTIC',
    function (x)
      local c4 = (2 * math.pi) / 3

      return x == 0
      and 0
      or (x == 1
      and 1
      or (2^(-10 * x)) * math.sin((x * 10 - 0.75) * c4) + 1)
    end,
    0,
    1
  )

  dims = {
    x = love.graphics.getWidth(),
    y = love.graphics.getHeight()
  }

  on_oscillator = false

  origin = {
    x = dims.x / 3, y = dims.y / 3,
  }

  oscillator = {
    d_props = {
      x = dims.x / 3, y = dims.y / 3,
      width = 100,
      height = 50,
      rx = 4, ry = 4
    }
  }

  difference = {
    x = 0
  }

end

function love.update(dt)
  anim:update(dt)
  message = next(anim._change_list) and 'yaas!' or 'nil'

  if not on_oscillator then
    oscillator.d_props.x = origin.x + difference.x
  end
end

function love.draw()
  love.graphics.rectangle('fill',
    oscillator.d_props.x,
    oscillator.d_props.y,
    oscillator.d_props.width,
    oscillator.d_props.height,
    oscillator.d_props.rx,
    oscillator.d_props.ry
  )

  love.graphics.circle('fill', origin.x, origin.y, 5)

  love.graphics.print(difference.x, 100, 100)
  love.graphics.print(message, 100, 120)

end

function love.mousepressed(x, y)
  on_oscillator = u.collides(
    {x = x, y = y},
    oscillator.d_props
  )
end

function love.mousemoved(x, y, dx, dy)
  if on_oscillator then

    anim:purge(difference)

    difference.x = oscillator.d_props.x - origin.x

    oscillator.d_props.x = 
    lume.clamp(
      oscillator.d_props.x + dx,
      0, dims.x - oscillator.d_props.width
    )

  end
end

function love.mousereleased(x, y)
  on_oscillator = false
  anim:move({
    obj = difference,
    to = {
      x = 0
    },
    seconds = 5,
    fn = anim.fn.EASE_OUT_ELASTIC
  })
end