# require "crystaledge"

require "../src/game"
require "../src/controller"
require "../src/sprite"
require "../src/sprite/vector_sprite"
require "../src/pixel"

class Triangle < PF::Sprite
  include PF::VectorSprite

  def update(dt)
  end

  def draw(engine)
    frame = project_points(@frame)
    engine.fill_triangle(frame[0], frame[1], frame[2], PF::Pixel.yellow)
  end
end

class TriangleThing < PF::Game
  @tri : Triangle
  @paused = true
  @controller : PF::Controller(LibSDL::Scancode)

  def initialize(@width, @height, @scale)
    super(@width, @height, @scale)

    @tri = Triangle.build do |t|
      t.position = Vector2.new(@width / 2, @height / 2)
      t.frame = PF::VectorSprite.generate_circle(3, size = @width / 3)
    end

    @controller = PF::Controller(LibSDL::Scancode).new({
      LibSDL::Scancode::RIGHT => "Rotate Right",
      LibSDL::Scancode::LEFT  => "Rotate Left",
      LibSDL::Scancode::SPACE => "Pause",
      LibSDL::Scancode::A     => "Move Left",
      LibSDL::Scancode::D     => "Move Right",
      LibSDL::Scancode::W     => "Move Up",
      LibSDL::Scancode::S     => "Move Down",
    })
  end

  def update(dt)
    @paused = !@paused if @controller.pressed?("Pause")

    @tri.rotation += 0.5 * dt if @controller.action?("Rotate Right")
    @tri.rotation -= 0.5 * dt if @controller.action?("Rotate Left")

    if @controller.action?("Move Up")
      @tri.frame[1] = @tri.frame[1] + Vector2.new(0.0, -10.0) * dt
    end

    if @controller.action?("Move Down")
      @tri.frame[1] = @tri.frame[1] + Vector2.new(0.0, 10.0) * dt
    end

    if @controller.action?("Move Left")
      @tri.frame[1] = @tri.frame[1] + Vector2.new(-10.0, 0.0) * dt
    end

    if @controller.action?("Move Right")
      @tri.frame[1] = @tri.frame[1] + Vector2.new(10.0, 0.0) * dt
    end

    unless @paused
      @tri.rotation += 1.0 * dt
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
