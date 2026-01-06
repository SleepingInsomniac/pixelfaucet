require "../src/pixelfaucet"

class Proceedural < PF::Game
  @pan : PF2d::Vec2(Float64) = PF2d::Vec[0.0, 0.0]
  @seed : UInt32
  @font = Pixelfont::Font.new("#{__DIR__}/../lib/pixelfont/fonts/pixel-5x7.txt")
  @keys : PF::Keymap

  def initialize(*args, **kwargs)
    super

    @keys = keymap({
      PF::Scancode::Left  => "left",
      PF::Scancode::Right => "right",
      PF::Scancode::Up    => "up",
      PF::Scancode::Down  => "down",
    })

    # @screen = PF::Sprite.new(width, height)
    @random = PF::Lehmer32.new
    @redraw = true

    @speed = 100.0
    @seed = str_to_seed("PixelFaucet")
  end

  def str_to_seed(str : String)
    str.chars.map { |c| c.ord.to_u32! }.reduce(&.+)
  end

  def zigzag(n : Int32)
    (((n << 1) ^ (n >> 31)).to_u32!) & 0xFFFF_u32
  end

  def seed(pos)
    zigzag(pos.x) << 16 | zigzag(pos.y)
  end

  def update(delta_time)
    dt = delta_time.total_seconds
    @redraw = true if @keys.any_held?
    @pan.x += @speed * dt if @keys.held?("right")
    @pan.x -= @speed * dt if @keys.held?("left")
    @pan.y -= @speed * dt if @keys.held?("up")
    @pan.y += @speed * dt if @keys.held?("down")
  end

  def frame(delta_time)
    if @redraw
      @redraw = false
      window.draw do
        start = elapsed_time.total_milliseconds
        0.upto(window.height - 1) do |y|
          0.upto(window.width - 1) do |x|
            @random.new_seed(seed(@pan.to_i32 + PF::Vec[x, y]))

            if @random.rand(0.0..1.0) > 0.995
              b = @random.rand(0u8..0xFFu8)
              window.draw_point(x, y, PF::RGBA.new(b, b, b))
            else
              window.draw_point(x, y, PF::Colors::Black)
            end
          end
        end
        time = elapsed_time.total_milliseconds - start
        window.draw_string("frame: #{time.round(2)}ms", 5, 5, @font, PF::Colors::White)
      end
    end
  end
end

Proceedural.new(400, 300, 3, fps_limit: 120.0).run!
