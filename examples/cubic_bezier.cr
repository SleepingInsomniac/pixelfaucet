require "../src/game"
require "../src/bezier"

module PF
  class CubicBezier < PF::Game
    @curve : BezierCubic(Float64)

    @hover_point : Vector2(Float64)*? = nil
    @selected_point : Vector2(Float64)*? = nil

    @mouse_pos : Vector2(Int32) = Vector[0, 0]

    def initialize(*args, **kwargs)
      super
      @curve = BezierCubic.new(
        Vector[width * 0.25, height * 0.75],
        Vector[width * 0.33, height * 0.5],
        Vector[width * 0.66, height * 0.5],
        Vector[width * 0.75, height * 0.75]
      )

      @controller = PF::Controller(Keys).new({
        Keys::KEY_1 => "p1",
        Keys::KEY_2 => "p2",
        Keys::KEY_3 => "p3",
        Keys::KEY_4 => "p4",

        Keys::UP    => "up",
        Keys::LEFT  => "left",
        Keys::DOWN  => "down",
        Keys::RIGHT => "right",
      })
    end

    def update(dt, event)
      @controller.map_event(event)

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

      draw_line(@curve.p0, @curve.p1, Pixel.new(100, 100, 100))
      draw_line(@curve.p3, @curve.p2, Pixel.new(100, 100, 100))

      point = @curve.p0
      0.upto(100) do |x|
        t = x / 100
        next_point = @curve.at(t)
        draw_line(point.to_i, next_point.to_i, Pixel.white)
        point = next_point
      end

      fill_circle(@curve.p0.to_i, 1, Pixel.blue)
      fill_circle(@curve.p1.to_i, 1, Pixel.blue)
      fill_circle(@curve.p2.to_i, 1, Pixel.blue)
      fill_circle(@curve.p3.to_i, 1, Pixel.blue)

      draw_string("P1", @curve.p0.to_i, Pixel.white)
      draw_string("P2", @curve.p1.to_i, Pixel.white)
      draw_string("P3", @curve.p2.to_i, Pixel.white)
      draw_string("P4", @curve.p3.to_i, Pixel.white)

      if point = @hover_point
        draw_circle(point.value.to_i, 5, Pixel.yellow)
      end
    end
  end
end

engine = PF::CubicBezier.new(500, 500, 2).run!
