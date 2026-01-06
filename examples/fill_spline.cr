require "../src/pixelfaucet"

class FillSpline < PF::Game
  include PF
  include PF2d

  @spline : QuadSpline(Float64)

  @hover_index : Int32? = nil
  @selected_index : Int32? = nil

  def initialize(*args, **kwargs)
    super

    @spline = QuadSpline.new(StaticArray[
      Vec[0.1, 0.3],
      Vec[0.2, 0.1],
      Vec[0.3, 0.25],
      Vec[0.4, 0.1],
      Vec[0.51, 0.2],
      Vec[0.6, 0.1],
      Vec[0.7, 0.25],
      Vec[0.8, 0.1],
      Vec[0.9, 0.3],
      Vec[0.5, 0.9],
    ]) * Vec[window.width, window.height]
  end

  def on_mouse_motion(cursor, event)
    if index = @selected_index
      @spline.points[index] = cursor.to_f
    else
      @hover_index = @spline.points.index { |p| cursor.distance(p) < 4 }
    end
  end

  def on_mouse_down(cursor, event)
    if event.button == 1
      @selected_index = @hover_index
    end
  end

  def on_mouse_up(cursor, event)
    @selected_index = nil
  end

  def update(delta_time)
  end

  def frame(delta_time)
    window.draw do
      window.clear(0, 25, 5)

      window.fill_spline(@spline, Colors::Gray)

      @spline.points.each do |point|
        window.fill_circle(point, 1, Colors::Red)
      end

      if index = @hover_index
        window.draw_circle(@spline.points[index], 5, Colors::Yellow)
      end
    end
  end
end

engine = FillSpline.new(300, 300, 3, fps_limit: 60.0)
engine.run!
