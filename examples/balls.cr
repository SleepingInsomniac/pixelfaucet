require "../src/game"
require "../src/shape"
require "../src/entity"
require "../src/entity/circle_collision"

module PF
  class Sprite
    # Redefine draw_point to wrap the coordinates
    def draw_point(x : Int32, y : Int32, color : UInt32)
      x = x % width
      y = y % height

      x = width + x if x < 0
      y = height + y if y < 0

      # super(x, y, color) # Undefined method super for Object??
      pixel_pointer(x, y).value = color
    end
  end

  class Ball < Entity
    include CircleCollision

    getter frame : Array(Vector(Float64, 2))

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
        position = Vector(Float64, 2).new(rand(0.0_f64..@width.to_f64), rand(0.0_f64..@height.to_f64))
        ball = Ball.new(rand(10.0..30.0))
        ball.position = position
        ball.velocity = Vector(Float64, 2).new(rand(-50.0..50.0), rand(-50.0..50.0))

        @balls << ball
      end
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
      @balls.each do |ball|
        fill_shape(Shape.translate(ball.frame, translation: ball.position).map(&.to_i32))
        # draw_circle(ball.position.to_i32, ball.radius.to_i32, Pixel.green)
      end
    end
  end
end

balls = PF::Balls.new(600, 400, 2)
balls.run!
