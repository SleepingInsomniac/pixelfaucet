require "sdl/image"
require "./sprite"
require "./pixel"

module PF
  class PixelText < Sprite
    getter char_width : Int32
    getter char_height : Int32
    @chars : String

    def initialize(path : String, @char_width : Int32 = 7, @char_height : Int32 = 8, mapping : String? = nil)
      super(path)
      @chars = mapping || "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!?().,/\\[]{}$#+-“”‘’'\"@=><_"
    end

    def color(pixel : Pixel)
      color_val = pixel.format(@surface.format)
      alpha_mask = @surface.format.a_mask

      pixels.map! do |p|
        p & alpha_mask != 0_u32 ? color_val : 0_u32
      end
    end

    def draw_to(surface : SDL::Surface, text : String, x : Int32 = 0, y : Int32 = 0)
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
          char_y *= @char_height
          char_x *= @char_width

          unless char == ' '
            @surface.blit(surface,
              SDL::Rect.new(char_x - 1, char_y, @char_width, @char_height),
              SDL::Rect.new(x + ix * @char_width, y + iy * @char_height, @char_width, @char_height)
            )
          end
        end

        ix += 1
      end
    end

    def draw_to(sprite : Sprite, text : String, x : Int32 = 0, y : Int32 = 0)
      draw_to(sprite.surface, text, x, y)
    end

    def draw_to(sprite : Sprite, text : String, x : Int32 = 0, y : Int32 = 0, bg : Pixel? = nil)
      if background = bg
        sprite.fill_rect(x - 1, y - 1, x + (char_width * text.size) - 1, y + char_height - 1, background)
      end
      draw_to(sprite.surface, text, x, y)
    end
  end
end
