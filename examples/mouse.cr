require "../src/pixelfaucet"

class MouseExample < PF::Game
  include PF2d

  @scroll = [] of Vec2(Float64)
  @move = [] of Vec2(Float64)

  def initialize(*args, **kwargs)
    super

    @scroll << Vec[window.width, window.height] / 2
    @move << Vec[window.width, window.height] / 2
  end

  # Override hook
  def on_mouse_wheel(direction : PF2d::Vec, inverted : Bool, window_id, event : Sdl3::Event)
    @scroll << @scroll[-1] - (inverted ? Vec[direction.x, -direction.y] : direction)
  end

  # Override hook
  def on_mouse_motion(direction : PF2d::Vec, event : PF::Event)
    @move << @move[-1] + direction
  end

  def update(delta_time)
  end

  def frame(delta_time)
    lock do
      clear
      draw_circle(PF::Mouse.pos, 4, PF::Colors::Yellow)

      @scroll.each_cons_pair do |p1, p2|
        draw_line(Line[p1, p2], PF::Colors::Cyan)
      end

      @move.each_cons_pair do |p1, p2|
        draw_line(Line[p1, p2], PF::Colors::Green)
      end
    end
  end
end

MouseExample.new(640, 480).run!
