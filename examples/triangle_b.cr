require "../src/pixelfaucet"
require "../src/entity"
require "../src/shape"

class Triangle < PF::Entity
  property frame : Array(PF2d::Vec2(Float64))

  def initialize(*args, **kwargs)
    @frame = [] of PF2d::Vec2(Float64)
  end

  def update(dt)
  end

  def draw(engine)
    _frame = PF::Shape.rotate(@frame, @rotation)
    _frame = PF::Shape.translate(_frame, @position)
    engine.fill_triangle(_frame.map(&.to_i32), PF::Colors::Yellow)
  end
end

class TriangleThing < PF::Game
  @tri : Triangle
  @paused = false
  @font = Pixelfont::Font.new("#{__DIR__}/../lib/pixelfont/fonts/pixel-5x7.txt")
  @fps_string = ""
  @fps_timer = PF::Interval.new(1.0.seconds)

  def initialize(*args, **kwargs)
    super

    @tri = Triangle.new
    @tri.position = @window.size / 2
    @tri.frame = PF::Shape.circle(3, size = window.width / 3)

    keys.map({
      PF::Key::Code::Right => "Rotate Right",
      PF::Key::Code::Left  => "Rotate Left",
      PF::Key::Code::Space => "Pause",
    })
  end

  def update(delta_time)
    @fps_timer.update(delta_time) { @fps_string = "#{window.fps.round.to_i} FPS" }
    dt = delta_time.total_seconds

    @paused = !@paused if keys["Pause"].pressed?

    @tri.rotation = @tri.rotation + 1.0 * dt if keys["Rotate Right"].held?
    @tri.rotation = @tri.rotation - 1.0 * dt if keys["Rotate Left"].held?

    unless @paused || keys.any_held?
      @tri.rotation = @tri.rotation + 0.5 * dt
    end

    @tri.update(dt)
  end

  def frame(delta_time)
    window.draw do
      window.clear(0, 0, 100)
      @tri.draw(window)
      # window.draw_string(@fps_string, 0, 0, @font, fore: PF::Colors::White)
    end
  end
end

engine = TriangleThing.new(50, 50, 10)
engine.run!
