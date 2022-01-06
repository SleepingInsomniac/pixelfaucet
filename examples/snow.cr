require "../src/game"
require "../src/controller"
require "../src/sprite"
require "../src/pixel"
require "../src/vector"
require "../src/pixel_text"

class Wind
  property width : Int32
  property height : Int32
  property density : Int32
  property gusts : Array(Gust) = [] of Gust
  @step : Float64?

  struct Gust
    property position : PF::Vector(Float64, 2)
    property strength : PF::Vector(Float64, 2)

    def initialize(@position, @strength)
    end
  end

  def initialize(@width, @height, @density = 20)
    setup_vectors
  end

  def step
    @step ||= (@width / @density)
  end

  def setup_vectors
    @gusts = [] of Gust
    y = step / 2
    while y < @height
      x = step / 2
      while x < @width
        @gusts << Gust.new(PF::Vector(Float64, 2).new(x, y), PF::Vector(Float64, 2).new(rand(-1.0..1.0), rand(-1.0..1.0)))
        x += step
      end
      y += step
    end
  end
end

class Flake
  property shape : UInt8
  property position : PF::Vector(Float64, 2)
  property z_pos : Float64
  property velocity : PF::Vector(Float64, 2)

  def initialize(@position, @shape = rand(0_u8..2_u8), @z_pos = rand(0.0..1.0), velocity : PF::Vector(Float64, 2)? = nil)
    @velocity = velocity || PF::Vector(Float64, 2).new(rand(-2.0..2.0), rand(0.0..20.0))
  end

  def update(dt)
    @velocity.y = @velocity.y + 1.0 * dt
    @position += @velocity * dt
  end
end

class Snow < PF::Game
  @wind : Wind
  @pixels : Slice(UInt32)
  @last_flake : Float64 = 0.0
  @flakes : Array(Flake) = [] of Flake

  def initialize(*args, **kwargs)
    super

    @wind = Wind.new(@width, @height)
    @pixels = Slice.new(@screen.pixels.as(Pointer(UInt32)), @width * @height)
    clear(0, 0, 15)
  end

  def update(dt, event)
    @last_flake += dt

    if @last_flake >= 0.025
      @last_flake = 0.0
      @flakes << Flake.new(position: PF::Vector[rand(0.0..@width.to_f64), 0.0])
    end

    @flakes.reject! do |flake|
      @wind.gusts.each do |gust|
        size = @wind.step / 3
        if flake.position > gust.position - size && flake.position < gust.position + size
          flake.velocity = flake.velocity + gust.strength * 3 * dt
        end
      end

      flake.update(dt)
      flake.position.y > @height
    end
  end

  def draw
    clear(0, 0, 15)

    @flakes.each do |flake|
      color = PF::Pixel.white * flake.z_pos
      if flake.shape == 0
        draw_point(flake.position.to_i32, color)
      else
        draw_circle(flake.position.to_i32, flake.shape, color)
      end
    end
  end
end

engine = Snow.new(1200, 800, 1, window_flags: SDL::Window::Flags::RESIZABLE | SDL::Window::Flags::SHOWN)
engine.run!
