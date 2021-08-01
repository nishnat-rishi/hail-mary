--[[

  [X] (done? spring.lua) Can encapsulae the various physicsy things into a
  smol_physics.lua module with some cute ways to provide springyness
  and so on to components.

  [X] (DONE) Scroll stuff can be tested as well.

  [X] (they finally got it, yay! :") components need their own module!
  lots of tree_draw, attach_*, and so on and so forth lying around
  here and there!

  [ ] event handling happens in a messy (if elsy) way, we can handle
  them better in a O(1) beautiful ram accessing pattern, 
  (handler.handlers[event]()) or something.

  [ ] BIG CHANGE (but maybe really worth it), is to add a separate 
  bordering mechanism / system. Stuff like effective_width and 
  effective_height would have to be introduced? height and width might
  be convertible to dimension as a vector, so that effective_dimension 
  (or effective_dim) might be sensible. and it would eliminate lots of
  code (at least at first glance on the side of the user, maybe later
  on on the side of the code as well (?)).

  [ ] In accordance with the above big change, something like an 
  interchangeable usage of (x, y) and (pos) as well as (width, height),
  (dim) would fit perhaps? something like:
  function constructor(params)
    ...
      dim = vec2d{x = params.width, y = params.height},
    ...
  end

  and subsequently we'll be using (dim) internally

]]