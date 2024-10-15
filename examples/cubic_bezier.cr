require "../src/game"

class CubicBezier < PF::Game
  FONT_COLOR  = PF::Pixel.new(0xFFFFFFFF)
  POINT_COLOR = PF::Pixel.new(0xFF0000FF)
  CTL_COLOR   = PF::Pixel.new(0x505050FF)
  CURVE_COLOR = PF::Pixel.new(0x0077FFFF)
  SEL_COLOR   = PF::Pixel.new(0xFFFF00FF)
  EXT_X_COLOR = PF::Pixel.new(0xFF00FFFF)
  EXT_Y_COLOR = PF::Pixel.new(0x00FF00FF)

  @curve : PF2d::Bezier::Cubic(Float64)

  @hover_point : PF2d::Vec2(Float64)*? = nil
  @selected_point : PF2d::Vec2(Float64)*? = nil

  @font = Pixelfont::Font.new("#{__DIR__}/../lib/pixelfont/fonts/pixel-5x7.txt")

  def initialize(*args, **kwargs)
    super
    @curve = PF2d::Bezier::Cubic.new(
      PF2d::Vec[width * 0.25, height * 0.7],
      PF2d::Vec[width * 0.33, height * 0.3],
      PF2d::Vec[width * 0.66, height * 0.3],
      PF2d::Vec[width * 0.75, height * 0.7]
    )
  end

  def on_mouse_motion(cursor)
    if point = @selected_point
      point.value = cursor.to_f
    else
      @hover_point = @curve.points.find { |p| cursor.distance(p.value) < 4 }
    end
  end

  def on_mouse_button(event)
    if event.button == 1
      if event.pressed?
        @selected_point = @hover_point
      else
        @selected_point = nil
      end
    end
  end

  def update(dt)
  end

  def draw
    clear

    draw_line(@curve.p0, @curve.p1, CTL_COLOR)
    draw_line(@curve.p3, @curve.p2, CTL_COLOR)

    draw_string("Length: " + @curve.length.round(2).to_s, 5, 5, @font, FONT_COLOR)

    draw_rect(*@curve.rect.map(&.to_i), CTL_COLOR)
    draw_curve(@curve, CURVE_COLOR)

    fill_circle(@curve.p0.to_i, 2, POINT_COLOR)
    fill_circle(@curve.p1.to_i, 2, POINT_COLOR)
    fill_circle(@curve.p2.to_i, 2, POINT_COLOR)
    fill_circle(@curve.p3.to_i, 2, POINT_COLOR)

    draw_string("P1 (#{@curve.p0.x.to_i}, #{@curve.p0.y.to_i})", @curve.p0, @font, FONT_COLOR)
    draw_string("P2 (#{@curve.p1.x.to_i}, #{@curve.p1.y.to_i})", @curve.p1, @font, FONT_COLOR)
    draw_string("P3 (#{@curve.p2.x.to_i}, #{@curve.p2.y.to_i})", @curve.p2, @font, FONT_COLOR)
    draw_string("P4 (#{@curve.p3.x.to_i}, #{@curve.p3.y.to_i})", @curve.p3, @font, FONT_COLOR)

    if point = @hover_point
      draw_circle(point.value.to_i, 5, SEL_COLOR)
    end

    @curve.extremities.each do |point|
      point.try do |p|
        draw_circle(p.to_i, 3, EXT_Y_COLOR)
      end
    end
  end
end

engine = CubicBezier.new(500, 500, 2).run!
