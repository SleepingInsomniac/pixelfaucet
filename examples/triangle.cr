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
    engine.fill_triangle(_frame.map(&.to_i32), PF::Pixel.yellow)
  end
end

class TriangleThing < PF::Game
  @tri : Triangle
  @paused = false
  @controller : PF::Controller(LibSDL::Scancode)

  def initialize(@width, @height, @scale)
    super(@width, @height, @scale)

    @tri = Triangle.new
    @tri.position = viewport / 2
    @tri.frame = PF::Shape.circle(3, size = @width / 3)

    @controller = PF::Controller(LibSDL::Scancode).new({
      LibSDL::Scancode::RIGHT => "Rotate Right",
      LibSDL::Scancode::LEFT  => "Rotate Left",
      LibSDL::Scancode::SPACE => "Pause",
    })
  end

  def update(dt, event)
    case event
    when SDL::Event::Keyboard
      @controller.press(event.scancode) if event.keydown?
      @controller.release(event.scancode) if event.keyup?
    end

    @paused = !@paused if @controller.pressed?("Pause")

    @tri.rotation = @tri.rotation + 0.5 * dt if @controller.action?("Rotate Right")
    @tri.rotation = @tri.rotation - 0.5 * dt if @controller.action?("Rotate Left")

    unless @paused
      @tri.rotation = @tri.rotation + 1.0 * dt
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
