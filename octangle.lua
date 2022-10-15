outs = {}

function init()
  crow.clear()
  params:set("clock_source", 1) -- 1: internal, 2: midi

  for i=1,4 do
    outs[i] = 1/i
    clock.run(ping, i)
    crow.output[i].action = "pulse(0.05, 8)"
  end
end

function ping(i)
  while true do
    clock.sync(outs[i])
    crow.output[i]()
  end
end

function redraw()
  screen.clear()
  screen.move(10, 40)
  screen.font_size(25)
  screen.level(15)
  screen.text(clock.get_tempo())
  screen.update()
end

function enc(n, d)
  if n == 1 then
    params:delta("clock_tempo", d)
    redraw()
  end
end
