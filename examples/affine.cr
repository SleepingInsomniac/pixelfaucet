require "../src/pixelfaucet"

class Affine < PF::Game
  include PF

  @bricks : Sprite
  @top_left : PF2d::Vec2(Int32) = PF2d::Vec[0, 0]
  @transform : PF2d::Transform = PF2d::Transform.new
  @angle = 0.0
  @size = 1.0
  @zoom = 0.5

  def initialize(*args, **kwargs)
    super
    @bricks = Sprite.new("./assets/bricks.png")
  end

  def update(delta_time)
    dt = delta_time.total_seconds
    @angle += 1.0 * dt
    @zoom, @size = -@zoom, @size.clamp(0.5..2.0) if @size > 2.0 || @size < 0.5
    @size = @size + @zoom * dt
  end

  def frame(delta_time)
    window.draw do
      window.clear(50, 127, 200)

      @transform
        .reset
        .translate(-(@bricks.size // 2))
        .rotate(@angle)
        .scale(@size)
        .translate(window.size // 2)

      b1, b2 = @transform.bounding_box(@bricks.size.x, @bricks.size.y).map(&.to_i)

      @transform.invert

      b1.y.upto(b2.y) do |y|
        b1.x.upto(b2.x) do |x|
          point = @transform.apply(x, y).to_i
          if point >= @top_left && point < @bricks.size
            window.draw_point(x.to_i, y.to_i, @bricks.get_point(point))
          end
        end
      end
    end
  end
end

game = Affine.new(300, 200, 2)
game.run!
