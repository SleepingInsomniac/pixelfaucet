require "../src/pixelfaucet"

class Snow < PF::Game
  BG = PF::RGBA.new(0, 0, 0x25)
  @snow : PF::Sprite
  @shift = PF::Interval.new(20.milliseconds)

  def initialize(*args, **kwargs)
    super

    @snow = PF::Sprite.new(width, height)
    @snow.clear(BG)
  end

  def update(delta_time)
  end

  def frame(delta_time)
    draw do
      pixels = @snow.to_slice

      @shift.update(delta_time) do
        pixels.rotate!(-width)

        0.upto(width - 1) do |x|
          if rand(0..250) == 0
            shade = rand(25_u8..255_u8)
            pixels[x] = PF::RGBA.new(shade, shade, shade).to_u32
          else
            pixels[x] = 0x000025FF
          end
        end
      end

      0.upto(height - 1) do |y|
        if rand(0..2) == 0
          row = Slice(UInt32).new(pixels.to_unsafe + (y * width), width)
          row.rotate!(rand(-1..1))
        end
      end

      draw_sprite(@snow, PF::Vec[0, 0])
    end
  end
end

engine = Snow.new(600, 400, 2)
engine.run!
