require "../src/game"
require "../src/pixel"

class DrawLine < PF::Game
  include PF2d

  @color = PF::Pixel.random

  @p1 : Vec2(Float64)
  @d1 : Vec2(Float64)

  @p2 : Vec2(Float64)
  @d2 : Vec2(Float64)

  @font = Pixelfont::Font.new("#{__DIR__}/../lib/pixelfont/fonts/pixel-5x7.txt")

  def initialize(*args, **kwargs)
    super
    @p1 = Vec[rand(0.0...width.to_f), rand(0.0...height.to_f)]
    @d1 = Vec[rand(-100.0..100.0), rand(-100.0..100.0)]

    @p2 = Vec[rand(0.0...width.to_f), rand(0.0...height.to_f)]
    @d2 = Vec[rand(-100.0..100.0), rand(-100.0..100.0)]
  end

  def update(dt)
    @p1 += (@d1 * dt)

    if @p1.x < 0
      @p1.x = 0
      @d1.x = -@d1.x
    end

    if @p1.x > width
      @p1.x = width
      @d1.x = -@d1.x
    end

    if @p1.y < 0
      @p1.y = 0
      @d1.y = -@d1.y
    end

    if @p1.y > height
      @p1.y = height
      @d1.y = -@d1.y
    end

    @p2 += (@d2 * dt)

    if @p2.x < 0
      @p2.x = 0
      @d2.x = -@d2.x
    end

    if @p2.x > width
      @p2.x = width
      @d2.x = -@d2.x
    end

    if @p2.y < 0
      @p2.y = 0
      @d2.y = -@d2.y
    end

    if @p2.y > height
      @p2.y = height
      @d2.y = -@d2.y
    end
  end

  def draw
    clear(0, 0, 100)
    # draw_string("P1: (#{@p1.x.to_i32},#{@p1.y.to_i32})", @p1, @font, @color)
    # draw_string("P2: (#{@p2.x.to_i32},#{@p2.y.to_i32})", @p2, @font, @color)
    draw_line(@p1, @p2, @color)
  end
end

engine = DrawLine.new(200, 200, 3)
engine.run!
