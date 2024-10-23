require "../src/game"

class LineIntersect < PF::Game
  include PF2d
  @line_1 : Line(Vec2(Float64))
  @line_2 : Line(Vec2(Float64))

  @hover_point : Vec2(Float64)*? = nil
  @selected_point : Vec2(Float64)*? = nil

  @font = Pixelfont::Font.new("#{__DIR__}/../lib/pixelfont/fonts/pixel-5x7.txt")

  def initialize(*args, **kwargs)
    super
    @line_1 = Line[Vec[5, 5].to_f64, Vec[width - 5, height - 5].to_f64]
    @line_2 = Line[Vec[width - 5, 5].to_f64, Vec[5, height - 5].to_f64]
  end

  def on_mouse_motion(cursor)
    if point = @selected_point
      point.value = cursor.to_f
    else
      @hover_point = {*@line_1.point_pointers, *@line_2.point_pointers}.find do |point|
        point.value.distance(cursor) < 3
      end
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

    draw_line(@line_1, PF::Pixel::Yellow)
    draw_line(@line_2, PF::Pixel::Yellow)
    fill_circle(@line_1.p1.to_i, 3, PF::Pixel::Red)
    fill_circle(@line_1.p2.to_i, 3, PF::Pixel::Red)
    fill_circle(@line_2.p1.to_i, 3, PF::Pixel::Red)
    fill_circle(@line_2.p2.to_i, 3, PF::Pixel::Red)

    if point = @hover_point
      draw_circle(point.value.to_i, 5, PF::Pixel::Blue)
    end

    if point = @line_1.intersects?(@line_2)
      fill_circle(point.to_i, 3, PF::Pixel::Green)
    end
  end
end

LineIntersect.new(300, 300, 2).run!
