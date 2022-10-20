clocks = {}
clock_options = {-- 12, default
  1/32, 1/16, 1/12, 1/10, 1/8,
  1/7, 1/6, 1/5, 1/4, 1/3, 1/2,
  1, 2, 3, 4, 5, 6, 7, 8
}

old_tempo = 0
playing = true

-- m = midi.connect()
-- m.event = function(data)
--   print("midi event: "..data)
-- end

function init()
  crow.clear()
  params:set("clock_source", 2) -- midi

  params:add_separator("crow_clock_rates", "crow clock rates")

  for i=1,4 do
    params:add_option("crowout"..i, "out "..i, clock_options, 12)
    clocks[i] = clock.run(ping, i)
    crow.output[i].action = "pulse(0.05, 8)"
  end

  params:add_separator("midi_options", "midi options")
  params:add_binary("follow_midi_transport", "follow midi transport (K3)", "toggle", 1)

  clock.run(check_tempo)
end

function clock.transport.start()
  print("midi transport start")
  if params:get("follow_midi_transport") == 1 then start_transport(false) end
end

function clock.transport.stop()
  print("midi transport stop")
  if params:get("follow_midi_transport") == 1 then stop_transport(false) end
end

function start_transport(skip_first)
  if playing then return end -- already playing
  for i=1,4 do clocks[i] = clock.run(ping, i, skip_first) end
  playing = true
  redraw()
end

function stop_transport()
  if not playing then return end -- already stopped
  for i=1,4 do clock.cancel(clocks[i]) end
  playing = false
  redraw()
end

function toggle_transport()
  if playing then
    stop_transport()
  else
    start_transport(true)
  end
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

function ping(i, skip_first)
  if not skip_first then crow.output[i]() end

  while true do
    clock.sync(clock_options[params:get("crowout"..i)])
    crow.output[i]()
  end
end

function redraw()
  screen.clear()
  screen.level(15)

  screen.move(17, 55)
  screen.font_size(8)
  transport = playing and "play" or "stop"
  screen.text(transport)

  screen.move(10, 40)
  screen.font_size(25)
  screen.text(get_tempo())

  screen.update()
end

function enc(n, d)
  if n == 1 then
    params:delta("clock_tempo", d)
    redraw()
  end
end

function key(k, z)
  if k == 2 and z == 1 then
    toggle_transport()
  end
end

function get_tempo()
  return math.floor(clock.get_tempo() + 0.5)
end

function r()
  norns.script.load("code/octangle/octangle.lua")
end
