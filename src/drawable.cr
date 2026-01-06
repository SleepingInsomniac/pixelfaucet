module PF
  module Drawable
    include PF2d::Drawable(RGBA)

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

    # TODO: Move this to pf2d?
    # TODO: faster case for 1:1 scale
    # TODO: Should this accept a drawable as a target: drow_to ...
    def draw_sprite(sprite : Sprite, src_rect : PF2d::Rect(Number), dst_rect : PF2d::Rect(Number))
      scale = dst_rect.size / src_rect.size

      0.upto(dst_rect.size.y - 1) do |y|
        sy = ((y * scale.y) + src_rect.top_left.y).to_i32
        dy = y + dst_rect.top_left.y
        next if sy >= sprite.height || dy >= height
        0.upto(dst_rect.size.x - 1) do |x|
          sx = ((x * scale.x) + src_rect.top_left.x).to_i32
          dx = x + dst_rect.top_left.x
          next if sx >= sprite.width || dx >= width
          source_color = sprite.get_point(sx, sy)
          if dest_color = get_point(dx, dy)
            draw_point(dx, dy, source_color.blend(dest_color))
          else
            draw_point(dx, dy, source_color)
          end
        end
      end
    end

    def draw_sprite(sprite  : Sprite, pos : PF2d::Vec = PF2d::Vec[0, 0])
      draw_sprite(sprite,
                  PF2d::Rect.new(PF2d::Vec[0,0], sprite.size),
                  PF2d::Rect.new(pos, sprite.size))
    end
  end
end
