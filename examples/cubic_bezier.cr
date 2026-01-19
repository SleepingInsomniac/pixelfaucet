require "../src/pixelfaucet"

class CubicBezier < PF::Game
  FONT_COLOR  = PF::RGBA.new(0xFFFFFFFF)
  POINT_COLOR = PF::RGBA.new(0xFF0000FF)
  CTL_COLOR   = PF::RGBA.new(0x505050FF)
  CURVE_COLOR = PF::RGBA.new(0x0077FFFF)
  SEL_COLOR   = PF::RGBA.new(0xFFFF00FF)
  EXT_X_COLOR = PF::RGBA.new(0xFF00FFFF)
  EXT_Y_COLOR = PF::RGBA.new(0x00FF00FF)

  @curve : PF2d::Bezier::Cubic(Float64)
  @qc1 : PF2d::Bezier::Cubic(Float64)
  @qc2 : PF2d::Bezier::Cubic(Float64)

  @hover_point : PF2d::Vec2(Float64)*? = nil
  @selected_point : PF2d::Vec2(Float64)*? = nil

  @font = Pixelfont::Font.new("#{__DIR__}/../lib/pixelfont/fonts/pixel-5x7.txt")

  def initialize(*args, **kwargs)
    super
    @curve = PF2d::Bezier::Cubic.new(
      PF2d::Vec[window.width * 0.25, window.height * 0.7],
      PF2d::Vec[window.width * 0.33, window.height * 0.3],
      PF2d::Vec[window.width * 0.66, window.height * 0.3],
      PF2d::Vec[window.width * 0.75, window.height * 0.7]
    )

    @qc1, @qc2 = @curve.split(0.5)
  end

  def on_mouse_motion(direction, event)
    if point = @selected_point
      point.value = PF::Mouse.pos
      point.value.x = 0 if point.value.x < 0
      point.value.x = window.width.to_f if point.value.x > window.width
      point.value.y = 0 if point.value.y < 0
      point.value.y = window.height.to_f if point.value.y > window.height
    else
      @hover_point = @curve.point_pointers.find { |p| PF::Mouse.pos.distance(p.value) < 4 }
    end
  end

  def on_mouse_down(event)
    @selected_point = @hover_point
  end

  def on_mouse_up(event)
    @selected_point = nil
  end

  def update(delta_time)
  end

  def frame(delta_time)
    window.draw do
      window.clear(0, 0, 0)

      window.draw_line(0, window.height // 2, window.width, window.height // 2, PF::RGBA.new(25, 25, 25))

      window.draw_line(@curve.p0, @curve.p1, CTL_COLOR)
      window.draw_line(@curve.p3, @curve.p2, CTL_COLOR)

      window.draw_string("Length: " + @curve.length.round(2).to_s, 5, 5, @font, FONT_COLOR)

      window.draw_rect(@curve.rect, CTL_COLOR)

      window.draw_curve(@qc1, PF::RGBA.new(30, 10, 10))
      window.draw_curve(@qc2, PF::RGBA.new(10, 30, 10))

      @qc1.points.each { |p| window.draw_circle(p.to_i, 3, PF::RGBA.new(25, 25, 25)) }
      @qc2.points.each { |p| window.draw_circle(p.to_i, 3, PF::RGBA.new(25, 25, 25)) }

      window.draw_curve(@curve, CURVE_COLOR)

      @curve.horizontal_intersects(window.height // 2) do |t|
        window.draw_circle(@curve.at(t).to_i, 3, PF::Colors::Orange)
      end

      @curve.points.each do |p|
        window.fill_circle(p.to_i, 2, POINT_COLOR)
      end

      @curve.points.each_with_index do |p, i|
        window.draw_string("P#{i} (#{p.x.to_i}, #{p.y.to_i})", p.x, p.y, @font, FONT_COLOR)
      end

      if point = @hover_point
        window.draw_circle(point.value.to_i, 5, SEL_COLOR)
      end

      @curve.extrema do |point|
        window.draw_circle(point.to_i, 3, EXT_Y_COLOR)
      end
    end
  end
end

engine = CubicBezier.new(500, 500, 2, fps_limit: 120.0).run!
