require "sdl/image"
require "./sprite"

module PF
  class PixelText < Sprite
    getter width : Int32
    getter height : Int32
    @chars : String

    def initialize(path : String, @width : Int32 = 7, @height : Int32 = 8, mapping : String? = nil)
      super(path)
      @chars = mapping || "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!?().,/\\[]{}$#+-“”‘’'\"@"
    end

    def color(pixel : Pixel)
      color_val = pixel.format(@surface.format)
      alpha_mask = @surface.format.a_mask

      0.upto(@surface.height - 1) do |y|
        0.upto(@surface.width - 1) do |x|
          loc = pixel_pointer(x, y)

          if loc.value & alpha_mask != 0
            loc.value = color_val
          end
        end
      end
    end

    def draw(surface : SDL::Surface, text : String, x : Int32 = 0, y : Int32 = 0)
      ix = 0
      iy = 0
      text.each_char do |char|
        if char == '\n'
          iy += 1
          ix = 0
          next
        end

        if index = @chars.index(char)
          char_y, char_x = index.divmod(26)
          char_y *= @height
          char_x *= @width

          unless char == ' '
            @surface.blit(surface, SDL::Rect.new(char_x - 1, char_y, @width, @height), SDL::Rect.new(x + ix * @width, y + iy * @height, @width, @height))
          end
        end

        ix += 1
      end
    end
  end
end
