require "pixelfont"
require "sdl/image"

module PF
  class Sprite
    def self.load_tiles(path, tile_width, tile_height)
      sheet = Sprite.new(path)
      sprites = [] of Sprite

      tiles_x = sheet.width // tile_width
      tiles_y = sheet.height // tile_height

      0.upto(tiles_y - 1) do |ty|
        0.upto(tiles_x - 1) do |tx|
          sx = tx * tile_width
          sy = ty * tile_height
          sprite = Sprite.new(tile_width, tile_height)
          sheet.draw_to(sprite, PF2d::Vec[sx, sy], PF2d::Vec[tile_width, tile_height], PF2d::Vec[0, 0])
          sprites << sprite
        end
      end

      sprites
    end

    include PF2d::Drawable(UInt32 | Pixel)
    include PF2d::Viewable(Pixel)

    property surface : SDL::Surface

    delegate :fill, :lock, :format, to: @surface

    def initialize(@surface)
    end

    def initialize(path : String)
      @surface = SDL::IMG.load(path)
    end

    def initialize(width : Int, height : Int)
      @surface = SDL::Surface.new(LibSDL.create_rgb_surface(
        flags: 0, width: width, height: height, depth: 32,
        r_mask: 0xFF000000, g_mask: 0x00FF0000, b_mask: 0x0000FF00, a_mask: 0x000000FF
      ))
    end

    def width
      @surface.width
    end

    def height
      @surface.height
    end

    def size : PF2d::Vec2
      PF2d::Vec[width, height]
    end

    # Fill a sprite with a color
    def fill(color : PF::Pixel)
      @surface.fill(color.r, color.g, color.b)
    end

    # Convert the color mode of this sprite to another for optimization
    def convert(other : SDL::Surface)
      @surface = @surface.convert(other)
    end

    # ditto
    def convert(other : Sprite)
      @surface = @surface.convert(other.surface)
    end

    # Draw this sprite to another
    def draw_to(surface : SDL::Surface, x : Int = 0, y : Int = 0)
      @surface.blit(surface, nil, SDL::Rect.new(x, y, width, height))
    end

    # ditto
    def draw_to(sprite : Sprite, x : Int = 0, y : Int = 0)
      draw_to(sprite.surface, x, y)
    end

    # ditto
    def draw_to(dest : SDL::Surface | Sprite, at : PF2d::Vec)
      draw_to(dest, at.x, at.y)
    end

    # Draw this sprite to another given a source rect and destination
    def draw_to(sprite : Sprite, source : PF2d::Vec, size : PF2d::Vec, dest : PF2d::Vec)
      @surface.blit(sprite.surface, SDL::Rect.new(source.x, source.y, size.x, size.y), SDL::Rect.new(dest.x, dest.y, size.x, size.y))
    end

    # Raw access to the pixels as a Slice
    def pixels
      Slice.new(@surface.pixels.as(Pointer(UInt32)), width * height)
    end

    # Peak at a raw pixel value at (*x*, *y*)
    def peak(x : Int, y : Int)
      pixel_pointer(x, y).value
    end

    # ditto
    def peak(point : PF2d::Vec)
      pixel_pointer(point.x, point.y).value
    end

    def get_point(x : Number, y : Number) : Pixel
      sample(x.to_i, y.to_i)
    end

    # Sample a color at an *x* and *y* position
    def sample(x : Int, y : Int)
      raw_pixel = peak(x, y)
      LibSDL.get_rgb(raw_pixel, format, out r, out g, out b)
      Pixel.new(r, g, b)
    end

    # ditto
    def sample(point : PF2d::Vec)
      sample(point.x, point.y)
    end

    # Sample a color with alhpa
    def sample(x : Int, y : Int, alpha : Bool)
      return sample(x, y) unless alpha
      raw_pixel = pixel_pointer(x, y).value
      LibSDL.get_rgba(raw_pixel, format, out r, out g, out b, out a)
      Pixel.new(r, g, b, a)
    end

    # ditto
    def sample(point : PF2d::Vec, alpha : Bool)
      sample(point.x, point.y, alpha)
    end

    # Get the pointer to a pixel
    def pixel_pointer(x : Int32, y : Int32)
      target = @surface.pixels + (y * @surface.pitch) + (x * sizeof(UInt32))
      target.as(Pointer(UInt32))
    end

    # Implements PF2d::Drawable(UInt32)
    def draw_point(x, y, value : UInt32 | Pixel)
      if x >= 0 && x < width && y >= 0 && y < height
        pixel_pointer(x.to_i32, y.to_i32).value = value.to_u32
      end
    end

    def draw_string(string : String, x : Number, y : Number, font : Pixelfont::Font, pixel)
      font.draw(string) do |px, py, on|
        draw_point(px + x, py + y, pixel) if on
      end
    end

    def draw_string(string : String, pos : PF2d::Vec, font : Pixelfont::Font, pixel)
      draw_string(string, pos.x, pos.y, font, pixel)
    end
  end
end
