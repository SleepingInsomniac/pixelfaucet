require "../src/game"
require "../src/controller"
require "../src/entity"
require "../src/pixel"
require "../src/shape"
require "../src/vector"

class Triangle < PF::Entity
  property frame : Array(PF::Vector2(Float64))

  def initialize(*args, **kwargs)
    @frame = [] of PF::Vector2(Float64)
  end

  def update(dt)
  end

  def draw(engine)
    _frame = PF::Shape.rotate(@frame, @rotation)
    _frame = PF::Shape.translate(_frame, @position)
    engine.fill_triangle(_frame.map(&.to_i32), PF::Pixel::Yellow)
  end
end

class TriangleThing < PF::Game
  @tri : Triangle
  @paused = false
  @controller : PF::Controller(PF::Keys)

  def initialize(*args, **kwargs)
    super

    @tri = Triangle.new
    @tri.position = viewport / 2
    @tri.frame = PF::Shape.circle(3, size = width / 3)

    @controller = PF::Controller(PF::Keys).new({
      PF::Keys::RIGHT => "Rotate Right",
      PF::Keys::LEFT  => "Rotate Left",
      PF::Keys::SPACE => "Pause",
    })
    plug_in @controller
  end

  def update(dt)
    @paused = !@paused if @controller.pressed?("Pause")

    @tri.rotation = @tri.rotation + 1.0 * dt if @controller.held?("Rotate Right")
    @tri.rotation = @tri.rotation - 1.0 * dt if @controller.held?("Rotate Left")

    unless @paused || @controller.any_held?
      @tri.rotation = @tri.rotation + 0.5 * dt
    end

    @tri.update(dt)
  end

  def draw
    clear(0, 0, 100)
    @tri.draw(self)
  end
end

engine = TriangleThing.new(50, 50, 10)
engine.run!
