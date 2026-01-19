require "../src/pixelfaucet"

class Worm
  include Indexable::Mutable(PF::Vec2(Float64))

  @vel : PF::Vec2(Float64)
  @segments : Array(PF::Vec2(Float64))
  @seg_len = 2.0
  @ring : Int32 = 0
  property target_len : Int32

  def initialize(speed : Float64, @target_len : Int32, head : PF::Vec2(Float64))
    @vel = PF::Vec[speed, 0.0]
    @segments = Array(PF::Vec2(Float64)).new(@target_len) do |i|
      head - PF::Vec[@seg_len * i, 0.0]
    end
  end

  def rotate(rad)
    @vel = @vel.rotate(rad)
  end

  def speed_up(amount)
    @vel += amount
  end

  def update(delta_time)
    self[0] = self[0] + @vel * delta_time.total_seconds

    len = PF::Line[self[0], self[1]].length

    if len >= @seg_len
      self[-1] = self[0]
      @ring = (@ring - 1) % @segments.size

      if @segments.size < @target_len
        insert(-1, self[-1])
      end
    end
  end

  def insert(index, value)
    insert_index = (@ring + index) % @segments.size
    @segments.insert(insert_index, value)
    @ring += 1 if insert_index <= @ring
    @ring %= @segments.size
  end

  def size
    @segments.size
  end

  def unsafe_put(index : Int, value : T)
    @segments[(@ring + index) % @segments.size] = value
  end

  def unsafe_fetch(index : Int)
    @segments[(@ring + index) % @segments.size]
  end
end

class Apple
  PALLET = [
    PF::RGBA[0x00AA00FF],
    PF::RGBA[0xFF0000FF],
    PF::RGBA[0xAA0000FF],
    PF::RGBA[0xFF9999FF]
  ]
  SPRITE = <<-SPRITE
  ..0....
  .21011.
  2111131
  2111111
  .21111.
  ..211..
  SPRITE

  property pos : PF::Vec2(Int32) = PF::Vec[0,0]
  getter sprite : PF::Sprite = PF::Sprite.load_text(SPRITE, PALLET)
  getter size = 3.5
end

class Snake < PF::Game
  TURN_RAD = 6.0
  SPEED = 25.0
  GROWTH = 5

  @apple = Apple.new
  @worm : Worm
  @font = Pixelfont::Font.new("#{__DIR__}/../lib/pixelfont/fonts/pixel-3x5.txt")
  @score = 0
  @best = 0
  @game_over = false

  def initialize(*args, **kwargs)
    super
    @worm = Worm.new(SPEED, GROWTH, PF::Vec[window.width / 2, window.height / 2])
    reset
  end

  def reset
    @apple.pos = PF::Vec[
      rand(@apple.size.round.to_i...(window.width - @apple.size.to_i)),
      rand(@apple.size.round.to_i...(window.height - @apple.size.to_i))
    ]
    @score = 0
    @worm = Worm.new(SPEED, GROWTH, PF::Vec[window.width / 2, window.height / 2])
    @game_over = false
  end

  def update(delta_time)
    if @game_over
      reset if keys[:space].pressed?
      return
    end

    @worm.update(delta_time)
    @worm.rotate(TURN_RAD * delta_time.total_seconds) if keys[:right].held?
    @worm.rotate(-TURN_RAD * delta_time.total_seconds) if keys[:left].held?

    if @worm[0].distance(@apple.pos) <= @apple.size
      @apple.pos = PF::Vec[
        rand(@apple.size.round.to_i...(window.width - @apple.size.to_i)),
        rand(@apple.size.round.to_i...(window.height - @apple.size.to_i))
      ]
      @worm.target_len += GROWTH
      @score += 1
      @worm.speed_up(1.0)
      @best = @score if @score > @best
    end

    @game_over = true if collided?
    @game_over = true unless window.rect.covers?(@worm[0])
  end

  def collided?
    result = false
    head_line = PF::Line[@worm[0], @worm[1]]
    @worm.each_cons_pair.with_index do |(p1, p2), i|
      next if i <= 1
      line = PF::Line[p1, p2]
      if head_line.intersect?(line)
        result = true
        break
      end
    end
    result
  end

  def frame(delta_time)
    window.lock do
      window.each_point do |p|
        r = rand(0u8..25u8)
        g = rand(0u8..25u8)
        b = rand(0u8..50u8)
        window.draw_point(p, PF::RGBA[r,g,b])
      end

      window.draw(@apple.sprite, @apple.pos - @apple.size / 2 - 1)
      @worm.each_cons_pair.with_index { |(p1, p2), i| window.draw_line(p1, p2, i % 2 == 0 ? PF::RGBA[0x004400FF] : PF::RGBA[0x006600FF]) }
      window.draw_point(@worm[0], PF::Colors::Green)
      window.draw_string(<<-TEXT, 1, 1, @font, PF::RGBA.new(0xFFFFFF44))
      Score: #{@score}
      Best: #{@best}
      TEXT

      if @game_over
        window.draw_string(<<-TEXT, window.width // 2 - 4 * 6, window.height // 2 - 6, @font, PF::RGBA.new(0xFF0000FF))
          GAME OVER
        (press space)
        TEXT
      end
    end
  end
end

Snake.new(160,100,5).run!
