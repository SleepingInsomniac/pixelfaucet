require "../src/pixelfaucet"

class Wind
  property width : Int32
  property height : Int32
  property density : Int32
  property gusts : Array(Gust) = [] of Gust
  @step : Float64?

  struct Gust
    property position : PF2d::Vec2(Float64)
    property strength : PF2d::Vec2(Float64)

    def initialize(@position, @strength = PF2d::Vec[rand(-10.0..10.0), rand(-10.0..10.0)])
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
    while y <= @height
      x = step / 2
      while x <= @width
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
  property age : Time::Span = 0.seconds

  def initialize(@position, @shape = rand(0_u8..2_u8), @z_pos = rand(0.0..1.0), velocity : PF2d::Vec2(Float64)? = nil)
    @velocity = velocity || PF2d::Vec[rand(-2.0..2.0), rand(10.0..20.0)]
  end
end

class Snow < PF::Game
  @wind : Wind
  @flakes : Array(Flake) = [] of Flake
  @snowfall = PF::Interval.new(10.0.milliseconds)
  @ttl = 20.seconds

  def initialize(*args, **kwargs)
    super

    @wind = Wind.new(window.width, window.height)
  end

  def update(delta_time)
    dt = delta_time.total_seconds

    @snowfall.update(delta_time) do
      @flakes << Flake.new(position: PF2d::Vec[rand(0.0..window.width.to_f64), 0.0])
    end

    @flakes.reject! do |flake|
      @wind.gusts.each do |gust|
        size = @wind.step / 2
        area = PF2d::Rect[gust.position - size, PF2d::Vec[size, size]]

        if area.covers?(flake.position)
          flake.velocity = flake.velocity + gust.strength * dt
        end
      end

      unless flake.position.y >= window.height - 1
        flake.velocity.y = flake.velocity.y + 3.0 * dt
        flake.position += flake.velocity * dt
      end
      flake.age += delta_time
      flake.age > @ttl
    end
  end

  def frame(delta_time)
    window.draw do
      window.clear(0, 0, 15)

      {% if flag?(:show_wind) %}
        @wind.gusts.each do |gust|
          size = @wind.step / 2
          window.draw_rect(gust.position - size, gust.position + size, PF::RGBA[255, 255, 255, 20])
          window.fill_circle(gust.position, 2, PF::RGBA[255, 255, 255, 40])
          window.draw_line(gust.position, gust.position + gust.strength * 4, PF::RGBA[255, 255, 255, 40])
        end
      {% end %}

      @flakes.each do |flake|
        color = PF::Colors::White * flake.z_pos * ((@ttl - flake.age) / (@ttl / 4)).clamp(0.0, 1.0)
        if flake.shape == 0
          window.draw_point(flake.position.to_i32, color)
        else
          window.fill_circle(flake.position.to_i32, flake.shape, color)
        end
      end
    end
  end
end

engine = Snow.new(1200, 800, 1, window_flags: Sdl3::Window::Flags::Resizable)
engine.run!
