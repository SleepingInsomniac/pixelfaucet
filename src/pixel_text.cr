require "sdl/image"

module PF
  class PixelText
    getter width : Int32
    getter height : Int32
    @img : SDL::Surface
    @chars : String

    def initialize(path : String, @width : Int32 = 7, @height : Int32 = 8, mapping : String? = nil)
      @img = SDL::IMG.load(path)
      @chars = mapping || "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!?().,/\\[]{}$#+-“”‘’'\"@"
    end

    def convert(surface : SDL::Surface)
      @img = @img.convert(surface)
    end

    def color(pixel : Pixel)
      color_val = pixel.format(@img.format)
      alpha_mask = @img.format.a_mask

      0.upto(@img.height - 1) do |y|
        0.upto(@img.width - 1) do |x|
          loc = pixel_pointer(x, y, @img)

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
            @img.blit(surface, SDL::Rect.new(char_x - 1, char_y, @width, @height), SDL::Rect.new(x + ix * @width, y + iy * @height, @width, @height))
          end
        end

        ix += 1
      end
    end

    private def pixel_pointer(x : Int32, y : Int32, surface = @img)
      target = surface.pixels + (y * surface.pitch) + (x * 4)
      target.as(Pointer(UInt32))
    end
  end
end
