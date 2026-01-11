require "../src/pixelfaucet"

class MouseExample < PF::Game
  include PF2d

  @pos : Vec2(Float32) = Vec[0.0f32, 0.0f32]
  @scroll = [] of Vec2(Float32)

  def initialize(*args, **kwargs)
    super

    @scroll << Vec[window.width.to_f32 / 2, window.height.to_f32 / 2]
  end

  # Override hook
  def on_mouse_wheel(cursor : PF2d::Vec, direction : PF2d::Vec, inverted : Bool, window_id, event : Sdl3::Event)
    @scroll << @scroll[-1] - (inverted ? Vec[direction.x, -direction.y] : direction)
  end

  # Override hook
  def on_mouse_motion(cursor : PF2d::Vec, event : Sdl3::Event)
    @pos = cursor
  end

  def update(delta_time)
  end

  def frame(delta_time)
    window.draw do
      window.clear
      window.draw_circle(@pos, 4, PF::Colors::Yellow)
      @scroll.each_cons(2) do |(p1, p2)|
        window.draw_line(Line[p1, p2], PF::Colors::Cyan)
      end
    end
  end
end

MouseExample.new(640, 480).run!
