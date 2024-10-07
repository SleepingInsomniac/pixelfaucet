require "../src/game"
require "../src/controller"
require "../src/sprite"
require "../src/pixel"

class Wind
  property width : Int32
  property height : Int32
  property density : Int32
  property gusts : Array(Gust) = [] of Gust
  @step : Float64?

  struct Gust
    property position : PF2d::Vec2(Float64)
    property strength : PF2d::Vec2(Float64)

    def initialize(@position, @strength = PF2d::Vec[rand(-5.0..5.0), rand(-5.0..5.0)])
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
        @gusts << Gust.new(PF2d::Vec[x, y])
        x += step
      end
      y += step
    end
  end
end

class Flake
  property shape : UInt8
  property position : PF2d::Vec2(Float64)
  property z_pos : Float64
  property velocity : PF2d::Vec2(Float64)

  def initialize(@position, @shape = rand(0_u8..2_u8), @z_pos = rand(0.0..1.0), velocity : PF2d::Vec2(Float64)? = nil)
    @velocity = velocity || PF2d::Vec[rand(-2.0..2.0), rand(10.0..20.0)]
  end

  def update(dt)
    @velocity.y = @velocity.y + 5.0 * dt
    @position += @velocity * dt
  end
end

class Snow < PF::Game
  @wind : Wind
  @last_flake : Float64 = 0.0
  @flakes : Array(Flake) = [] of Flake

  def initialize(*args, **kwargs)
    super

    @wind = Wind.new(width, height)
    500.times do
      @flakes << Flake.new(position: PF2d::Vec[rand(0.0..width.to_f64), rand(0.0..height.to_f64)])
    end
    clear(0, 0, 15)
  end

  def update(dt)
    @last_flake += dt

    if @last_flake >= 0.025
      @last_flake = 0.0
      @flakes << Flake.new(position: PF2d::Vec[rand(0.0..width.to_f64), 0.0])
    end

    @flakes.reject! do |flake|
      @wind.gusts.each do |gust|
        size = @wind.step / 3
        if flake.position > gust.position - size && flake.position < gust.position + size
          flake.velocity = flake.velocity + gust.strength * 3 * dt
        end
      end

      flake.update(dt)
      flake.position.y > height
    end
  end

  def draw
    clear(0, 0, 15)

    @flakes.each do |flake|
      color = PF::Pixel::White * flake.z_pos
      if flake.shape == 0
        draw_point(flake.position.to_i32, color)
      else
        fill_circle(flake.position.to_i32, flake.shape, color)
      end
    end
  end
end

engine = Snow.new(1200, 800, 1, window_flags: SDL::Window::Flags::RESIZABLE | SDL::Window::Flags::SHOWN)
engine.run!
