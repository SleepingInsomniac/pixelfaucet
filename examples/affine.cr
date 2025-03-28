require "../src/game"

module PF
  class Affine < Game
    @bricks : Sprite
    @top_left : PF2d::Vec2(Int32) = PF2d::Vec[0, 0]
    @transform : PF2d::Transform = PF2d::Transform.new
    @angle = 0.0
    @size = 1.0
    @zoom = 0.5

    def initialize(*args, **kwargs)
      super
      @bricks = Sprite.new("./assets/bricks.png")
      @bricks.convert(@screen)
    end

    def update(dt)
      @angle += 1.0 * dt
      @zoom, @size = -@zoom, @size.clamp(0.5..2.0) if @size > 2.0 || @size < 0.5
      @size = @size + @zoom * dt
    end

    def draw
      clear(50, 127, 200)

      @transform
        .reset
        .translate(-(@bricks.size // 2))
        .rotate(@angle)
        .scale(@size)
        .translate(viewport // 2)

      b1, b2 = @transform.bounding_box(@bricks.size.x, @bricks.size.y).map(&.to_i)

      @transform.invert

      b1.y.upto(b2.y) do |y|
        b1.x.upto(b2.x) do |x|
          point = @transform.apply(x, y).to_i
          if point >= @top_left && point < @bricks.size
            draw_point(x.to_i, y.to_i, @bricks.peak(point))
          end
        end
      end
    end
  end
end

game = PF::Affine.new(300, 200, 2)
game.run!
