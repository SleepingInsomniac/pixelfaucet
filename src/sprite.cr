require "pixelfont"
require "sdl3/image"

module PF
  class Sprite
    include PF2d::Canvas(RGBA)
    include Drawable

    # Loads sprites based on a sprite sheet defined by a grid of tiles *tile_width* and *tile_height*
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
          sprite.draw(sheet,
                      PF2d::Rect.new(PF2d::Vec[sx, sy], PF2d::Vec[tile_width, tile_height]),
                      PF2d::Rect.new(0,0, tile_width, tile_height)
          )# { |d, s| s }
          sprites << sprite
        end
      end

      sprites
    end

    property surface : Sdl3::Surface
    @texture : Sdl3::Texture? = nil

    def initialize(@surface)
    end

    def initialize(path : String)
      @surface = Sdl3::Image.load(path).convert(Sdl3::PixelFormat::Rgba8888)
    end

    def initialize(width : Int, height : Int)
      @surface = Sdl3::Surface.new(width.to_i32, height.to_i32, Sdl3::PixelFormat::Rgba8888)
    end

    def width
      @surface.width
    end

    def height
      @surface.height
    end

    def rect
      PF2d::Rect.new(PF2d::Vec[0, 0], size.to_i32)
    end

    def size : PF2d::Vec2
      PF2d::Vec[width, height]
    end

    # Fill a sprite with a color
    def clear(color : PF::RGBA)
      to_slice.fill(color.to_u32)
    end

    def clear(red = 0u8, green = 0u8, blue = 0u8, alpha = 255u8)
      to_slice.fill(RGBA.new(red, green, blue, alpha).to_u32)
    end

    # Raw access to the pixels as a Slice
    def to_slice
      Slice(UInt32).new(@surface.pixels.to_unsafe.as(UInt32*), width * height)
    end

    def get_point?(x : Number, y : Number) : RGBA?
      return nil if x < 0 || x >= width || y < 0 || y >= height
      RGBA.new(to_slice[i = (y * width + x).to_i])
    end

    # Implements PF2d::Drawable(T)
    def draw_point(x, y, value : RGBA)
      if x >= 0 && x < width && y >= 0 && y < height
        to_slice[(y * width + x).to_i] = value.to_u32
      end
    end
  end
end
