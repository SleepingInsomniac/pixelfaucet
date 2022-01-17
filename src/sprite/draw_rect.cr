module PF
  class Sprite
    # Draw the outline of a square rect
    def draw_rect(x1 : Int, y1 : Int, x2 : Int, y2 : Int, pixel : Pixel = Pixel.new)
      # draw from top left to bottom right
      y1, y2 = y2, y1 if y1 > y2
      x1, x2 = x2, x1 if x1 > x2

      x1.upto(x2) do |x|
        draw_point(x, y1, pixel)
        draw_point(x, y2, pixel)
      end

      y1.upto(y2) do |y|
        draw_point(x1, y, pixel)
        draw_point(x2, y, pixel)
      end
    end

    # ditto
    def draw_rect(p1 : PF::Vector2(Int), p2 : PF::Vector2(Int), pixel : Pixel = Pixel.new)
      draw_rect(p1.x, p1.y, p2.x, p2.y, pixel)
    end

    # ditto
    def draw_rect(size : PF::Vector2(Int), pixel : Pixel = Pixel.new)
      draw_rect(0, 0, size.x, size.y, pixel)
    end
  end
end
