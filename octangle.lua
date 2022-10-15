i = 1

function init()
  crow.output[1]:clock(1)
  crow.output[2]:clock(2)
  crow.output[3]:clock(3)
  crow.output[4]:clock(4)

  clock.run(function()
    while true do
      i = i + 1
      clock.sleep(0.1)
      redraw()
    end
  end)
end

function redraw()
  screen.clear()
  screen.move(40,40)
  screen.font_size(25)
  screen.level(15)
  screen.text(clock.get_tempo())
  screen.update()
end
