require "../src/game"
require "../src/shape"
require "../src/entity"
require "../src/entity/circle_collision"

module PF
  class Ball < Entity
    include CircleCollision

    getter frame : Array(Vector2(Float64))
    getter color = Pixel.random

    def initialize(size : Float64)
      @frame = Shape.circle(size.to_i32, size.to_i32)
      @mass = size
      @radius = size
    end
  end

  class Balls < Game
    ADD_BALL = 2.0
    @balls : Array(Ball) = [] of Ball
    @ball_clock = ADD_BALL

    def initialize(*args, **kwargs)
      super
      add_ball
    end

    def add_ball
      position = Vector[rand(0.0_f64..width.to_f64), rand(0.0_f64..height.to_f64)]
      ball = Ball.new(rand(10.0..30.0))
      ball.position = position
      ball.velocity = Vector[rand(-50.0..50.0), rand(-50.0..50.0)]
      @balls << ball
    end

    def update(dt)
      @ball_clock -= dt
      if @ball_clock < 0
        @ball_clock = ADD_BALL
        add_ball
      end

      @balls.each do |b|
        b.update(dt)

        b.position.x = width + b.radius if b.position.x < -b.radius
        b.position.y = height + b.radius if b.position.y < -b.radius
        b.position.x = -b.radius if b.position.x > width + b.radius
        b.position.y = -b.radius if b.position.y > height + b.radius
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
        fill_shape(Shape.translate(ball.frame, translation: ball.position).map(&.to_i32), ball.color)
      end
      draw_string("Balls: #{@balls.size}", 5, 5, Pixel::White)
    end
  end
end

balls = PF::Balls.new(600, 400, 2)
balls.run!
