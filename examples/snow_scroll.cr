require "../src/game"

class Snow < PF::Game
  @pixels : Slice(UInt32)
  @last_shift : Float64 = 0.0

  def initialize(*args, **kwargs)
    super

    @pixels = Slice.new(@screen.pixels.as(Pointer(UInt32)), @width * @height)
    clear(0, 0, 25)
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
          shade = rand(0..255)
          @pixels[x] = LibSDL.map_rgba(@screen.format, shade, shade, shade, 255)
        else
          @pixels[x] = LibSDL.map_rgba(@screen.format, 0, 0, 25, 255)
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
