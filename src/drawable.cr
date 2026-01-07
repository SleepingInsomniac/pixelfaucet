module PF
  module Drawable
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
