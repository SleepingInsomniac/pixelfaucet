# require "crystaledge"

require "../src/game"
require "../src/controller"
require "../src/sprite"
require "../src/sprite/vector_sprite"

# include CrystalEdge

class Triangle < PF::Sprite
  include PF::VectorSprite

  @frame = PF::VectorSprite.generate_circle(3, size = 25.0)

  def update(dt)
    # @rotation += 0.5 * dt
  end

  def draw(engine)
    frame = project_points(@frame)
    engine.fill_triangle(frame[0], frame[1], frame[2], PF::Pixel.new(255, 255, 0))
    # engine.draw_shape(frame, PF::Pixel.new(0, 0, 255))
    # engine.draw_line(@position, frame[0], PF::Pixel.new(255, 255, 0))
  end
end

class TriangleThing < PF::Game
  @tri : Triangle
  @paused = false

  def initialize(@width, @height, @scale)
    super(@width, @height, @scale)

    @tri = Triangle.build do |t|
      t.position = Vector2.new(@width / 2, @height / 2)
    end

    @controller = PF::Controller(LibSDL::Keycode).new({
      LibSDL::Keycode::RIGHT => "Rotate Right",
      LibSDL::Keycode::LEFT  => "Rotate Left",
      LibSDL::Keycode::SPACE => "Pause",
    })
  end

  def update(dt)
    @paused = !@paused if @controller.pressed?("Pause")

    @tri.rotation += 1.0 * dt if @controller.action?("Rotate Right")
    @tri.rotation -= 1.0 * dt if @controller.action?("Rotate Left")

    unless @paused
      @tri.rotation += 1.0 * dt
    end

    @tri.update(dt)
  end

  def draw
    clear(0, 0, 255)
    # fill_rect(25, 25, 10, 15)
    # draw_rect(15, 15, 30, 30)
    @tri.draw(self)
    # draw_circle((@width / 2).to_i32, (@height / 2).to_i32, 45)
  end
end

engine = TriangleThing.new(100, 100, 5)
engine.run!
