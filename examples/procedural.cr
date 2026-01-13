require "../src/pixelfaucet"

class Proceedural < PF::Game
  def self.str_to_seed(str : String) : UInt32
    str.chars.map { |c| c.ord.to_u32! }.reduce(&.+)
  end

  @pan : PF2d::Vec2(Float64) = PF2d::Vec[0.0, 0.0]
  @seed : UInt32
  @font = Pixelfont::Font.new("#{__DIR__}/../lib/pixelfont/fonts/pixel-5x7.txt")
  @random = PF::Lehmer32.new
  @redraw = true
  @speed = 100.0
  @seed : UInt32 = str_to_seed("PixelFaucet")

  def zigzag(n : Int32)
    (((n << 1) ^ (n >> 31)).to_u32!) & 0xFFFF_u32
  end

  def seed(pos)
    zigzag(pos.x) << 16 | zigzag(pos.y)
  end

  def update(delta_time)
    dt = delta_time.total_seconds
    @redraw = true if @keys.any_held?
    @pan.x += @speed * dt if keys[:right].held?
    @pan.x -= @speed * dt if keys[:left].held?
    @pan.y -= @speed * dt if keys[:up].held?
    @pan.y += @speed * dt if keys[:down].held?
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

Proceedural.new(400, 300, 3).run!
