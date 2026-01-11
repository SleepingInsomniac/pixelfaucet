require "../src/pixelfaucet"

# Demonstrates snow by rotating the pixels of a sprite
class Snow < PF::Game
  BG = PF::RGBA.new(0, 0, 0x25)
  @snow : PF::Sprite
  @shift = PF::Interval.new(20.milliseconds)

  def initialize(*args, **kwargs)
    super

    @snow = PF::Sprite.new(window.width, window.height)
    @snow.clear(BG)
  end

  def update(delta_time)
  end

  def frame(delta_time)
    window.draw do
      pixels = @snow.to_slice

      @shift.update(delta_time) do
        pixels.rotate!(-@snow.width)

        0.upto(@snow.width - 1) do |x|
          if rand(0..250) == 0
            shade = rand(25_u8..255_u8)
            pixels[x] = PF::RGBA.new(shade, shade, shade).to_u32
          else
            pixels[x] = 0x000025FF
          end
        end
      end

      0.upto(@snow.height - 1) do |y|
        if rand(0..2) == 0
          row = Slice(UInt32).new(pixels.to_unsafe + (y * @snow.width), @snow.width)
          row.rotate!(rand(-1..1))
        end
      end

      window.draw(@snow, PF::Vec[0, 0])
    end
  end
end

engine = Snow.new(600, 400, 2)
engine.run!
