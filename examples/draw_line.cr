require "../src/pixelfaucet"

class DrawLine < PF::Game
  include PF
  include PF2d

  @color = RGBA.random

  class Vertex
    property pos : Vec2(Float64)
    property vel : Vec2(Float64)

    def initialize(@pos, @vel)
    end
  end

  @verticies = [] of Vertex

  @font = Pixelfont::Font.new("#{__DIR__}/../lib/pixelfont/fonts/pixel-5x7.txt")

  def initialize(*args, **kwargs)
    super

    10.times do
      @verticies << Vertex.new(
        Vec[rand(0.0...width.to_f), rand(0.0...height.to_f)],
        Vec[rand(-0.1..0.1), rand(-0.1..0.1)]
      )
    end
  end

  def update(delta_time)
    @verticies.each do |v|
      v.pos += (v.vel * delta_time.to_f)

      if v.pos.x < 0
        v.pos.x = 0
        v.vel.x = -v.vel.x
      end

      if v.pos.x > width
        v.pos.x = width
        v.vel.x = -v.vel.x
      end

      if v.pos.y < 0
        v.pos.y = 0
        v.vel.y = -v.vel.y
      end

      if v.pos.y > height
        v.pos.y = height
        v.vel.y = -v.vel.y
      end
    end
  end

  def draw(delta_time)
    clear(0, 0, 100)
    @verticies.each_cons(2) do |(v1, v2)|
      draw_line(v1.pos, v2.pos, @color)
    end
  end
end

DrawLine.new(200, 200, 3).run!
