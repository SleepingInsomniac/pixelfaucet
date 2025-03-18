require "../src/game"

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
    ]) * viewport
  end

  def on_mouse_motion(cursor)
    if index = @selected_index
      @spline.points[index] = cursor.to_f
    else
      @hover_index = @spline.points.index { |p| cursor.distance(p) < 4 }
    end
  end

  def on_mouse_button(event)
    if event.button == 1
      if event.pressed?
        @selected_index = @hover_index
      else
        @selected_index = nil
      end
    end
  end

  def update(dt)
  end

  def draw
    clear(0, 25, 5)

    fill_spline(@spline, Pixel::Gray)

    @spline.points.each do |point|
      fill_circle(point, 1, Pixel::Red)
    end

    if index = @hover_index
      draw_circle(@spline.points[index], 5, Pixel::Yellow)
    end
  end
end

engine = FillSpline.new(300, 300, 3)
engine.run!
