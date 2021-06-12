-- gesture responder system
-- this has been archieved because it contains a way to
-- simulate touchpressed and touchreleased without using 
-- love's callback functions 'love.touchpressed' and 
-- 'love.touchreleased'! This can be potentially used to 
-- exert fine tuned control over exactly which touches have
-- been released or pressed! (or maybe the default callbacks)
-- also provide this information, and i'm just too early to
-- understand it ...

function love.load()
  message = '---'
  touched_message = '---'
  new_message = 'touchpressed doesn\'t work!'
  touches = {}
  component = {
    d_props = {
      x = love.graphics.getWidth() / 2 - 50, 
      y = love.graphics.getHeight() / 2 - 50,
      width = 100,
      height = 100,
      rx = 2,
      ry = 2
    }
  }
end

function love.update(dt)
  touches = love.touch.getTouches()

  -- the actual movement
  if #touches == 1 then
    local x, y = love.touch.getPosition(touches[1])
    if collides({x = x, y = y}, component) then
      message = 'collides!'
    else
      message = 'NO collision!'
    end

    if touched then
      touched_message = 'touch persisted!!'
    end

    touched = true
  elseif #touches == 2 then
    
  else
    touched = false
  end

  if not touched then
    touched_message = 'touch released!'
  end
end

function love.draw()
  -- let this be present for feedback
  for i, id in ipairs(touches) do
    local x, y = love.touch.getPosition(id)
    love.graphics.circle("fill", x, y, 20)
  end

  love.graphics.print(message, 50, 50)
  love.graphics.print(touched_message, 50, 70)
  love.graphics.print(new_message, 50, 90)

  -- the thing to move
  love.graphics.rectangle(
      'fill',
      component.d_props.x,
      component.d_props.y,
      component.d_props.width,
      component.d_props.height,
      component.d_props.rx,
      component.d_props.ry
    )
end

function collides(pointer, object)
  local x, y = pointer.x ,pointer.y
  local obj = object.d_props
  
  return (x >= obj.x and x <= obj.x + obj.width) and
    (y >= obj.y and y <= obj.y + obj.height)
end

function love.touchpressed()
  new_message = 'yay, touchpressed works!!'
end

function love.touchreleased()
  new_message = 'released also works!!'
end