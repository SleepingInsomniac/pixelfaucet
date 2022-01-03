require "../src/game"
require "../src/shape"
require "../src/entity"
require "../src/entity/circle_collision"

module PF
  class Ball < Entity
    include CircleCollision

    getter frame : Array(Point(Float64))

    def initialize(size : Float64)
      @frame = Shape.circle(size.to_i32, size.to_i32)
      @mass = size
      @radius = size
    end
  end

  class Balls < Game
    @balls : Array(Ball) = [] of Ball

    def initialize(*args, **kwargs)
      super

      15.times do
        position = Point(Float64).new(rand(0.0_f64..@width.to_f64), rand(0.0_f64..@height.to_f64))
        ball = Ball.new(rand(10.0..30.0))
        ball.position = position
        ball.velocity = Point(Float64).new(rand(-50.0..50.0), rand(-50.0..50.0))

        @balls << ball
      end
    end

    # override to wrap the coordinates
    def draw_point(x : Int32, y : Int32, pixel : PF::Pixel, surface = @screen)
      x = x % @width
      y = y % @height

      x = @width + x if x < 0
      y = @height + y if y < 0

      super(x, y, pixel, surface)
    end

    def update(dt, event)
      @balls.each do |b|
        b.update(dt)
        b.position = b.position % viewport # wrap coords
      end

      collission_pairs = [] of Tuple(Ball, Ball)
      @balls.each do |a|
        @balls.each do |b|
          next if a == b
          next if collission_pairs.includes?({a, b})

          if a.collides_with?(b)
            collission_pairs << {a, b}
            a.resolve_collision(b)
          end
        end
      end
    end

    def draw
      clear(10, 10, 30)
      # @balls.each { |b| draw_circle(b.position.to_i32, b.radius.to_i32) }
      @balls.each do |ball|
        fill_shape(Shape.translate(ball.frame, translation: ball.position).map(&.to_i32))
      end
    end
  end
end

balls = PF::Balls.new(600, 400, 2)
balls.run!
