require "../src/pixelfaucet"
require "../src/shape"
require "../src/entity"
require "../src/entity/circle_collision"

class Ball < PF::Entity
  include PF::CircleCollision

  getter frame : Array(PF2d::Vec2(Float64))
  getter color = RGBA.random

  def initialize(size : Float64)
    @frame = Shape.circle(size.to_i32, size.to_i32)
    @mass = size
    @radius = size
  end
end

class Balls < Game
  include PF

  @adder = Interval.new(2.0.seconds)
  @balls : Array(Ball) = [] of Ball
  @font = Pixelfont::Font.new("#{__DIR__}/../lib/pixelfont/fonts/pixel-5x7.txt")

  def initialize(*args, **kwargs)
    super
    add_ball
  end

  def add_ball
    position = Vec[rand(0.0_f64..width.to_f64), rand(0.0_f64..height.to_f64)]
    ball = Ball.new(rand(10.0..30.0))
    ball.position = position
    ball.velocity = Vec[rand(-50.0..50.0), rand(-50.0..50.0)]
    @balls << ball
  end

  def update(delta_time)
    @adder.update(delta_time) do
      add_ball
    end

    @balls.each do |b|
      b.update(delta_time)

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

  def frame(delta_time)
    draw do
      clear(10, 10, 30)
      @balls.each do |ball|
        fill_poly(Shape.translate(ball.frame, translation: ball.position).map(&.to_i32), ball.color)
      end
      draw_string("Balls: #{@balls.size}", 5, 5, @font, Colors::White)
    end
  end
end

balls = Balls.new(600, 400, 2)
balls.run!
