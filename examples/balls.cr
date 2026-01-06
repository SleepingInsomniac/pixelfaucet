require "../src/pixelfaucet"
require "../src/shape"
require "../src/entity"
require "../src/entity/circle_collision"

class Ball < PF::Entity
  include PF::CircleCollision

  getter frame : Array(PF2d::Vec2(Float64))
  getter color = PF::RGBA.random

  def initialize(size : Float64)
    @frame = PF::Shape.circle(size.to_i32, size.to_i32)
    @mass = size
    @radius = size
  end
end

class Balls < PF::Game
  include PF

  @adder = Interval.new(0.1.seconds)
  @balls : Array(Ball) = [] of Ball
  @font = Pixelfont::Font.new("#{__DIR__}/../lib/pixelfont/fonts/pixel-5x7.txt")
  @keys : PF::Keymap

  def initialize(*args, **kwargs)
    super
    3.times { add_ball }
    @keys = keymap({
      PF::Scancode::Up => "add",
      PF::Scancode::Down => "remove",
    })
  end

  def add_ball
    position = Vec[rand(0.0_f64..window.width.to_f64), rand(0.0_f64..window.height.to_f64)]
    ball = Ball.new(rand(10.0..30.0))
    ball.position = position
    ball.velocity = Vec[rand(-50.0..50.0), rand(-50.0..50.0)]
    @balls << ball
  end

  def remove_ball
    @balls.pop
  end

  def update(delta_time)
    if @keys.pressed?("add")
      add_ball
      @adder.reset
    end

    if @keys.pressed?("remove")
      remove_ball
      @adder.reset
    end

    @adder.update(delta_time) do
      if @keys.held?("add")
        add_ball
      end

      if @keys.held?("remove")
        remove_ball
      end
    end

    @balls.each do |b|
      b.update(delta_time.total_seconds)

      b.position.x = window.width + b.radius if b.position.x < -b.radius
      b.position.y = window.height + b.radius if b.position.y < -b.radius
      b.position.x = -b.radius if b.position.x > window.width + b.radius
      b.position.y = -b.radius if b.position.y > window.height + b.radius
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
    window.draw do
      window.clear(10, 10, 30)
      @balls.each do |ball|
        window.fill_poly(Shape.translate(ball.frame, translation: ball.position).map(&.to_i32), ball.color)
      end
      window.draw_string("Balls: #{@balls.size}", 5, 5, @font, Colors::White)
    end
  end
end

balls = Balls.new(600, 400, 2, fps_limit: 60.0)
balls.run!
