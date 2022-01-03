require "sdl/image"

module PF
  class Sprite
    @surface : SDL::Surface

    delegate :convert, to: @img

    def initialize(@surface)
    end

    def initialize(path : String)
      @surface = SDL::IMG.load(path)
    end

    def width
      @surface.width
    end

    def height
      @surface.height
    end

    def draw(surface : SDL::Surface, x : Int32, y : Int32)
      @surface.blit(surface, nil, SDL::Rect.new(x, y, width, height))
    end

    # Raw access to the pixels as a Slice
    def pixels
      Slice.new(@surface.pixels.as(Pointer(UInt32)), width * height)
    end

    # Get the pointer to a pixel
    private def pixel_pointer(x : Int32, y : Int32)
      target = @surface.pixels + (y * @surface.pitch) + (x * 4)
      target.as(Pointer(UInt32))
    end
  end
end
