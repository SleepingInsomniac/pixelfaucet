require "../src/pixelfaucet"


SCALE = 16
WIDTH = 12
HEIGHT = 25

struct Square
  include PF2d
  property color : PF::RGBA

  def initialize(@color : PF::RGBA)
  end

  def draw_to(canvas : Canvas(PF::RGBA), at : Rect)
    canvas.fill_rect(at, color)

    canvas.draw_line(at.top_edge, color.lighten(0.3))
    canvas.draw_line(at.left_edge, color.lighten(0.3))

    canvas.draw_line(at.bottom_edge, color.darken(0.3))
    canvas.draw_line(at.right_edge, color.darken(0.3))
  end
end

class Shape < PF2d::Grid(UInt8)
  include PF2d

  PALLET = [
    PF::Colors::Aquamarine,
    PF::Colors::Navy,
    PF::Colors::Maroon,
    PF::Colors::Purple,
    PF::Colors::PeachPuff,
    PF::Colors::LawnGreen,
    PF::Colors::GoldenRod,
    PF::Colors::Gray,
  ]

  SHAPES = {
    I: {Slice[
      0u8, 1u8, 0u8, 0u8,
      0u8, 1u8, 0u8, 0u8,
      0u8, 1u8, 0u8, 0u8,
      0u8, 1u8, 0u8, 0u8
    ], 4, 4 },
    J: {Slice[
      0u8, 2u8, 0u8,
      0u8, 2u8, 0u8,
      2u8, 2u8, 0u8
    ], 3, 3, },
    L: {Slice[
      0u8, 3u8, 0u8,
      0u8, 3u8, 0u8,
      0u8, 3u8, 3u8
    ], 3, 3, },
    O: {Slice[
      4u8, 4u8,
      4u8, 4u8,
    ], 2, 2, },
    S: {Slice[
      5u8, 0u8, 0u8,
      5u8, 5u8, 0u8,
      0u8, 5u8, 0u8
    ], 3, 3, },
    T: {Slice[
      0u8, 0u8, 0u8,
      6u8, 6u8, 6u8,
      0u8, 6u8, 0u8
    ], 3, 3, },
    Z: {Slice[
      0u8, 7u8, 0u8,
      7u8, 7u8, 0u8,
      7u8, 0u8, 0u8
    ], 3, 3, },
  }

  def self.random
    new(*SHAPES.values.sample)
  end

  def self.shape(s : Symbol)
    new(*SHAPES[s])
  end

  property pos : Vec2(Float64)

  def initialize(data, width, height, @pos = Vec[0.0, 0.0])
    super(data, width, height)
  end

  def rotate(&)
    self.data = Slice(UInt8).new(data.size) do |i|
      y, x = i.divmod(@width)
      data[yield(x, y)]
    end
  end

  def rotate_right
    rotate { |x, y| (width - 1 - x) * width + y }
  end

  def rotate_left
    rotate { |x, y| x * width + ((width - 1) - y) }
  end

  def draw_to(canvas : Canvas(PF::RGBA), at : Vec, size : Int32)
    0.upto(width - 1) do |y|
      0.upto(width - 1) do |x|
        c = self[x, y]
        if c > 0
          pos = at + Vec[x, y] * size
          Square.new(PALLET[c - 1]).draw_to(canvas, at: Rect[pos.to_i, Vec[size, size]])
        end
      end
    end
  end
end

enum GameState
  Normal
  GameOver
end

class FallingBlocks < PF::Game
  include PF

  @font : Pixelfont::Font = Pixelfont::Font.new("#{__DIR__}/../lib/pixelfont/fonts/pixel-5x7.txt")
  @field = PF2d::Grid(UInt8).new(WIDTH, HEIGHT) do |p, s|
    p.x == 0 || p.x == s.x - 1 || p.y == s.y - 1 ? 8u8 : 0u8
  end
  @keys = Keymap.new({
    Scancode::Right  => "right",
    Scancode::Left   => "left",
    Scancode::Down   => "down",
    Scancode::Up     => "rotate_right",
    Scancode::Z      => "rotate_left",
    Scancode::X      => "rotate_right",
    Scancode::Space  => "drop",
    Scancode::B      => "down",
    Scancode::Escape => "reset",
  })
  @move_target : Vec2(Int32) = Vec[0,0]
  @fall_speed = 1.0 # Blocks per second
  @move = Interval.new(0.2.seconds)
  @state = GameState::Normal
  @line_blink = Interval.new(20.milliseconds)
  @animation_wait = Timeout.new(0.3.seconds)
  @cleared = 0
  @time_to_settle = 0.3.seconds
  @settle = 0.seconds

  def initialize(*args, **kwargs)
    super

    @falling = Shape.random
    @next = Array(Shape).new(3) { Shape.random }
    @move.pause
    keymap @keys

    new_drop
  end

  def collides?(at : Vec2(Int))
    clip = @field.clip(Rect[at, @falling.size])
    @falling.any? { |(p, v)| v > 0 && clip[p]?.try { |o| o > 0 } }
  end

  def collides?
    collides?(@falling.pos.to_i) ||
      collides?(@falling.pos.to_i + Vec[0, 1])
  end

  def collides_right?
    if @falling.pos.y - @falling.pos.y.floor < 0.25
      collides?(@falling.pos.to_i + Vec[1, 0])
    else
      collides?(@falling.pos.to_i + Vec[1, 0]) ||
        collides?(@falling.pos.to_i + Vec[1, 1])
    end
  end

  def collides_left?
    if @falling.pos.y - @falling.pos.y.floor < 0.25
      collides?(@falling.pos.to_i + Vec[-1, 0])
    else
      collides?(@falling.pos.to_i + Vec[-1, 0]) ||
        collides?(@falling.pos.to_i + Vec[-1, 1])
    end
  end

  def collides_down?
    collides?(@falling.pos.to_i + Vec[0, 1])
  end

  # Just jiggle the piece around a bunch, I guess.
  def kick?
    @falling.pos += Vec[1, 0]
    return true unless collides?
    @falling.pos += Vec[-2, 0]
    return true unless collides?
    @falling.pos += Vec[1, -1]
    return true unless collides? # Floor kick
    @falling.pos += Vec[0, 1]
    false
  end

  def lines
    result = [] of Int32
    4.upto(@field.height - 2) do |y|
      line = true
      1.upto(@field.width - 2) do |x|
        if @field[x, y] == 0
          line = false
          break
        end
      end
      result << y if line
    end
    result
  end

  def new_drop
    @settle = @time_to_settle
    @falling = @next.shift
    @next << Shape.random
    @falling.pos = Vec[@field.width / 2 - 1, 0.0]
    @animation_wait.reset
  end

  def update(delta_time)
    ds = delta_time.total_seconds

    if @keys.pressed?("reset")
      @cleared = 0
      @field = PF2d::Grid(UInt8).new(WIDTH, HEIGHT) do |p, s|
        p.x == 0 || p.x == s.x - 1 || p.y == s.y - 1 ? 8u8 : 0u8
      end
      @state = GameState::Normal
      new_drop
    end

    case @state
    when GameState::Normal
      if @keys.pressed?("right")
        if !collides_right?
          @falling.pos.x = @falling.pos.x + 1
        end
      end

      if @keys.pressed?("left") && !collides_left?
        @falling.pos.x = @falling.pos.x - 1
      end

      if @keys.pressed?("rotate_right")
        @falling.rotate_right
        @falling.rotate_left if collides? && !kick?
      end

      if @keys.pressed?("rotate_left")
        @falling.rotate_left
        @falling.rotate_right if collides? && !kick?
      end

      if @keys.pressed?("drop")
        @falling.pos.y = @falling.pos.y.to_i.to_f

        until collides_down?
          @falling.pos += Vec[0, 1]
        end
        @settle = 0.seconds
      elsif @keys.held?("down")
        @falling.pos += Vec[0.0, {20.0, @fall_speed}.max] * ds
      end

      if collides_down?
        @falling.pos.y = @falling.pos.y.floor
        @settle -= delta_time
        if @settle.to_f <= 0
          # Stamp the piece onto the field
          @field.draw(@falling, @falling.pos.round.to_i) { |src, dst| src + dst }

          if @falling.pos.y < 4
            @state = GameState::GameOver
          else
            new_drop
          end
        end
      else
        @falling.pos += Vec[0.0, @fall_speed + (@cleared // 10)] * ds
      end

      @line_blink.update(delta_time) do
        lines.each do |y|
          c = rand(1u8...Shape::PALLET.size.to_u8)
          1.upto(@field.width - 2) do |x|
            @field[x, y] = c
          end
        end
      end

      @animation_wait.update(delta_time) do
        @state = GameState::Normal
        @cleared += lines.size
        lines.each_with_index do |y, i|
          @field.data[0...(@field.width * (y + 1) - 1)].rotate!(-(@field.width))
          @field.row(0)[1...-1].map! { 0u8 }
          @field[@field.width - 1, 0] = Shape::PALLET.size.to_u8
        end
      end
    when GameState::GameOver
    end
  end

  def frame(delta_time)
    window.draw do
      window.clear(50, 50, 50)

      4.upto(@field.height) do |y|
        window.draw_line(Vec[0, y * SCALE], Vec[SCALE * @field.width, y * SCALE], RGBA[60,60,60])
        0.upto(@field.width) do |x|
          window.draw_line(Vec[x * SCALE, 4 * SCALE], Vec[x * SCALE, SCALE * @field.height], RGBA[80,80,80])
        end
      end

      @field.each_point do |p|
        if @field[p] > 0
          pos = p * SCALE
          c = @field[p]
          Square.new(Shape::PALLET[(c - 1) % Shape::PALLET.size]).draw_to(window, at: Rect[pos.to_i, Vec[SCALE, SCALE]])
        end
      end

      @next.each_with_index do |shape, i|
        x = @field.width * SCALE + (SCALE // 2)
        y = (i * 4) * SCALE + (i * (SCALE // 2))
        shape.draw_to(window, Vec[x, y], SCALE)
      end

      @falling.draw_to(window, @falling.pos * SCALE, SCALE)
      window.draw_string(<<-TEXT, @field.width * SCALE + SCALE // 2, @next.size * 5 * SCALE + SCALE // 2, @font, PF::Colors::White)
      Lines: #{@cleared}
      TEXT

      if @state.game_over?
        window.draw_string(<<-TEXT, (@field.width * SCALE) // 2 - @font.width_of("Game Over!") // 2, SCALE, @font, PF::Colors::White)
        Game Over!
        TEXT
      end
    end
  end
end

FallingBlocks.new((WIDTH + 5) * SCALE, HEIGHT * SCALE, 2).run!
