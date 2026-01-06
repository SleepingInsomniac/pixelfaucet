require "pixelfont"
require "sdl3/image"

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
          sprite.draw_sprite(sheet, PF2d::Rect.new(PF2d::Vec[sx, sy], PF2d::Vec[tile_width, tile_height]), PF2d::Rect.new(0,0, tile_width, tile_height))
          sprites << sprite
        end
      end

      sprites
    end

    include PF2d::Drawable(RGBA)
    include PF2d::Viewable(RGBA)

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

    def get_point(x : Number, y : Number) : RGBA
      raise IndexError.new("x:#{x} out of bounds") if x < 0 || x >= width
      raise IndexError.new("y:#{y} out of bounds") if y < 0 || y >= height
      RGBA.new(to_slice[i = (y * width + x).to_i])
    end

    # Implements PF2d::Drawable(T)
    def draw_point(x, y, value : RGBA)
      if x >= 0 && x < width && y >= 0 && y < height
        to_slice[(y * width + x).to_i] = value.to_u32
      end
    end

    def draw_string(string : String, x : Number, y : Number, font : Pixelfont::Font, fore = RGBA.new(255, 255, 255, 255), back : RGBA? = nil)
      font.draw(string) do |px, py, on|
        if on
          draw_point(px + x, py + y, fore)
        else
          back.try { |b| draw_point(px + x, py + y, b) }
        end
      end
    end

    def draw_string(string : String, pos : PF2d::Vec, font : Pixelfont::Font, pixel)
      draw_string(string, pos.x, pos.y, font, pixel)
    end

    def blit(other : Sprite, src_rect : PF2d::Rect(Number)? = nil, dest_rect : PF2d::Rect(Number)? = nil)
      if src_rect
        src_rect = LibSdl3::Rect.new(src_rect.top_left.x, src_rect.top_left.y, src_rect.size.x, src_rect.size.y)
      end

      if dest_rect
        dest_rect = LibSdl3::Rect.new(dest_rect.top_left.x, dest_rect.top_left.y, dest_rect.size.x, dest_rect.size.y)
      end

      @surface.blit(other.surface, src_rect, dest_rect)
    end

    # TODO: This should accept a drawable as a target: drow_to ...
    def draw_sprite(sprite : Sprite, src_rect : PF2d::Rect(Number), dst_rect : PF2d::Rect(Number))
      sprite_pixels = Slice(UInt32).new(sprite.surface.pixels.to_unsafe.as(UInt32*), sprite.width * sprite.height)
      pixels = to_slice

      scale = dst_rect.size / src_rect.size

      0.upto(dst_rect.size.y) do |y|
        sy = ((y * scale.y) + src_rect.top_left.y).to_i32
        dy = y + dst_rect.top_left.y
        next if sy >= sprite.height || dy >= height
        0.upto(dst_rect.size.x) do |x|
          sx = ((x * scale.x) + src_rect.top_left.x).to_i32
          dx = x + dst_rect.top_left.x
          next if sx >= sprite.width || dx >= width
          source_color = RGBA.new(sprite_pixels[sy * sprite.width + sx])
          dest_color = RGBA.new(pixels[dy * width + dx])
          draw_point(dx, dy, source_color.blend(dest_color))
        end
      end
    end

    def draw_sprite(sprite  : Sprite, pos : PF2d::Vec)
      draw_sprite(sprite,
                  PF2d::Rect.new(PF2d::Vec[0,0], sprite.size),
                  PF2d::Rect.new(pos, sprite.size))
    end

  end
end
