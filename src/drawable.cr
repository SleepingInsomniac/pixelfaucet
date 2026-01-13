module PF
  module Drawable
    def blend_point(at : Vec, color : RGBA)
      if dest = self[at]?
        draw_point(at, color.blend(dest))
      else
        draw_point(at, color)
      end
    end

    def draw_string(string : String, x : Number, y : Number, font : Pixelfont::Font, fore = RGBA.new(255, 255, 255, 255), back : RGBA? = nil)
      draw_string(string, Vec[x, y], font, fore, back)
    end

    def draw_string(string : String, pos : PF2d::Vec, font : Pixelfont::Font, fore = RGBA.new(255, 255, 255, 255), back : RGBA? = nil)
      font.draw(string) do |px, py, on|
        dest = Vec[px, py] + pos
        if on
          blend_point(dest, fore)
        else
          back.try { |b| blend_point(dest, b) }
        end
      end
    end

    # Sdl3 method for PF2d#draw
    def blit(other : Sprite, src_rect : PF2d::Rect(Number)? = nil, dest_rect : PF2d::Rect(Number)? = nil)
      if src_rect
        src_rect = LibSdl3::Rect.new(src_rect.top_left.x, src_rect.top_left.y, src_rect.size.x, src_rect.size.y)
      end

      if dest_rect
        dest_rect = LibSdl3::Rect.new(dest_rect.top_left.x, dest_rect.top_left.y, dest_rect.size.x, dest_rect.size.y)
      end

      @surface.blit(other.surface, src_rect, dest_rect)
    end
  end
end
