require "sdl/image"
require "./vector"
require "./sprite/*"

module PF
  class Sprite
    property surface : SDL::Surface

    delegate :fill, :lock, :format, to: @surface

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

    def size
      Vector[width, height]
    end

    def convert(other : SDL::Surface)
      @surface = @surface.convert(other)
    end

    def convert(other : Sprite)
      @surface = @surface.convert(other.surface)
    end

    def draw_to(surface : SDL::Surface, x : Int32, y : Int32)
      @surface.blit(surface, nil, SDL::Rect.new(x, y, width, height))
    end

    def draw_to(sprite : Sprite, x : Int32, y : Int32)
      draw_to(sprite.surface, x, y)
    end

    # Raw access to the pixels as a Slice
    def pixels
      Slice.new(@surface.pixels.as(Pointer(UInt32)), width * height)
    end

    # Sample a color at an *x* and *y* position
    def sample(x : Int, y : Int)
      raw_pixel = pixel_pointer(x, y).value

      r = uninitialized UInt8
      g = uninitialized UInt8
      b = uninitialized UInt8

      LibSDL.get_rgb(raw_pixel, format, pointerof(r), pointerof(g), pointerof(b))
      Pixel.new(r, g, b)
    end

    # ditto
    def sample(point : Vector(Int, 2))
      sample(point.x, point.y)
    end

    # Sample a color with alhpa
    def sample(x : Int, y : Int, alpha = true)
      raw_pixel = pixel_pointer(x, y).value

      r = uninitialized UInt8
      g = uninitialized UInt8
      b = uninitialized UInt8
      a = uninitialized UInt8

      LibSDL.get_rgba(raw_pixel, format, pointerof(r), pointerof(g), pointerof(b), pointerof(a))
      Pixel.new(r, g, b, a)
    end

    # Get the pointer to a pixel
    private def pixel_pointer(x : Int32, y : Int32)
      target = @surface.pixels + (y * @surface.pitch) + (x * 4)
      target.as(Pointer(UInt32))
    end
  end
end
