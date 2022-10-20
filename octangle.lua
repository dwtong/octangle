clocks = {}
clock_options = {-- 12, default
  1/32, 1/16, 1/12, 1/10, 1/8,
  1/7, 1/6, 1/5, 1/4, 1/3, 1/2,
  1, 2, 3, 4, 5, 6, 7, 8
}

old_tempo = 0

-- m = midi.connect()
-- m.event = function(data)
--   print("midi event: "..data)
-- end

function clock.transport.start()
  print("clock transport start")
  for i=1,4 do clocks[i] = clock.run(ping, i) end
end

function clock.transport.stop()
  print("clock transport stop")
  for i=1,4 do clock.cancel(clocks[i]) end
end

function init()
  crow.clear()
  params:set("clock_source", 2) -- midi

  params:add_separator("crow_clock_rates", "crow clock rates")

  for i=1,4 do
    params:add_option("crowout"..i, "out "..i, clock_options, 12)
    clocks[i] = clock.run(ping, i)
    crow.output[i].action = "pulse(0.05, 8)"
  end

  clock.run(check_tempo)
end

function check_tempo()
  while true do
    clock.sleep(0.5)

    if old_tempo ~= get_tempo() then
      old_tempo = get_tempo()
      redraw()
    end
  end
end

function ping(i)
  while true do
    crow.output[i]()
    clock.sync(clock_options[params:get("crowout"..i)])
  end
end

function redraw()
  screen.clear()
  screen.move(10, 40)
  screen.font_size(25)
  screen.level(15)
  screen.text(get_tempo())
  screen.update()
end

function enc(n, d)
  if n == 1 then
    params:delta("clock_tempo", d)
    redraw()
  end
end

function get_tempo()
  return math.floor(clock.get_tempo() + 0.5)
end

function r()
  norns.script.load("code/octangle/octangle.lua")
end
