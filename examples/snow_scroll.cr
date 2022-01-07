require "../src/game"

class Snow < PF::Game
  @pixels : Slice(UInt32)
  @last_shift : Float64 = 0.0

  def initialize(*args, **kwargs)
    super

    @pixels = @screen.pixels
    clear(0, 0, 0x25)
  end

  def update(dt, event)
    @last_shift += dt
  end

  def draw
    if @last_shift >= 0.02
      @last_shift = 0.0

      @pixels.rotate!(-@width)

      0.upto(@width - 1) do |x|
        if rand(0..250) == 0
          shade = rand(25_u8..255_u8)
          @pixels[x] = PF::Pixel.new(shade, shade, shade).to_u32
        else
          @pixels[x] = 0x000025FF
        end
      end
    end

    0.upto(@height - 1) do |y|
      if rand(0..2) == 0
        row = Slice(UInt32).new(@pixels.to_unsafe + (y * @width), @width)
        row.rotate!(rand(-1..1))
      end
    end
  end
end

engine = Snow.new(600, 400, 2)
engine.run!
