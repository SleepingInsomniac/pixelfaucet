require "../src/game"
require "../src/bezier"

module PF
  class CubicBezier < PF::Game
    FONT_COLOR  = Pixel.new(0xFFFFFFFF)
    POINT_COLOR = Pixel.new(0xFF0000FF)
    CTL_COLOR   = Pixel.new(0x505050FF)
    CURVE_COLOR = Pixel.new(0x0077FFFF)
    SEL_COLOR   = Pixel.new(0xFFFF00FF)
    EXT_X_COLOR = Pixel.new(0xFF00FFFF)
    EXT_Y_COLOR = Pixel.new(0x00FF00FF)

    @curve : Bezier::Cubic(Float64)

    @hover_point : Vector2(Float64)*? = nil
    @selected_point : Vector2(Float64)*? = nil

    @mouse_pos : Vector2(Int32) = Vector[0, 0]

    def initialize(*args, **kwargs)
      super
      @curve = Bezier::Cubic.new(
        Vector[width * 0.25, height * 0.7],
        Vector[width * 0.33, height * 0.3],
        Vector[width * 0.66, height * 0.3],
        Vector[width * 0.75, height * 0.7]
      )
    end

    def update(dt, event)
      case event
      when SDL::Event::MouseButton
        if event.pressed? && event.button == 1
          @selected_point = @hover_point
        end

        if event.released? && event.button == 1
          @selected_point = nil
        end
      when SDL::Event::MouseMotion
        @mouse_pos = Vector[event.x, event.y] // scale

        unless point = @selected_point
          @hover_point = @curve.points.find { |p| @mouse_pos.distance(p.value) < 4 }
        else
          point.value.x = @mouse_pos.x.to_f
          point.value.y = @mouse_pos.y.to_f
        end
      end
    end

    def draw
      clear

      draw_line(@curve.p0, @curve.p1, CTL_COLOR)
      draw_line(@curve.p3, @curve.p2, CTL_COLOR)

      draw_string("Length: " + @curve.length.round(2).to_s, 5, 5, FONT_COLOR)
      draw_curve(@curve, CURVE_COLOR)

      ext_x, ext_y = @curve.extremeties

      ext_x.each do |point|
        draw_circle(point.to_i, 3, EXT_X_COLOR)
      end

      ext_y.each do |point|
        draw_circle(point.to_i, 3, EXT_Y_COLOR)
      end

      fill_circle(@curve.p0.to_i, 2, POINT_COLOR)
      fill_circle(@curve.p1.to_i, 2, POINT_COLOR)
      fill_circle(@curve.p2.to_i, 2, POINT_COLOR)
      fill_circle(@curve.p3.to_i, 2, POINT_COLOR)

      draw_string("P1", @curve.p0.to_i, color: FONT_COLOR)
      draw_string("P2", @curve.p1.to_i, color: FONT_COLOR)
      draw_string("P3", @curve.p2.to_i, color: FONT_COLOR)
      draw_string("P4", @curve.p3.to_i, color: FONT_COLOR)

      if point = @hover_point
        draw_circle(point.value.to_i, 5, SEL_COLOR)
      end
    end
  end
end

engine = PF::CubicBezier.new(500, 500, 2).run!
