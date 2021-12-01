# require "crystaledge"

require "../src/game"
require "../src/controller"
require "../src/sprite"
require "../src/sprite/vector_sprite"
require "../src/pixel"

# include CrystalEdge

class Triangle < PF::Sprite
  include PF::VectorSprite

  def update(dt)
  end

  def draw(engine)
    frame = project_points(@frame)
    engine.fill_triangle(frame[0], frame[1], frame[2], PF::Pixel.yellow)
    engine.draw_triangle(frame[0], frame[1], frame[2], PF::Pixel.green)
  end
end

class TriangleThing < PF::Game
  @tri : Triangle
  @paused = false

  def initialize(@width, @height, @scale)
    super(@width, @height, @scale)

    @tri = Triangle.build do |t|
      t.position = Vector2.new(@width / 2, @height / 2)
      t.frame = PF::VectorSprite.generate_circle(3, size = @width / 3)
    end

    @controller = PF::Controller(LibSDL::Keycode).new({
      LibSDL::Keycode::RIGHT => "Rotate Right",
      LibSDL::Keycode::LEFT  => "Rotate Left",
      LibSDL::Keycode::SPACE => "Pause",
    })
  end

  def update(dt)
    @paused = !@paused if @controller.pressed?("Pause")

    @tri.rotation += 0.5 * dt if @controller.action?("Rotate Right")
    @tri.rotation -= 0.5 * dt if @controller.action?("Rotate Left")

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

engine = TriangleThing.new(100, 100, 6)
engine.run!
