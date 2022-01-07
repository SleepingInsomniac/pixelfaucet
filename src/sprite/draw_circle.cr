module PF
  class Sprite
    # Draw a circle using Bresenham’s Algorithm
    def draw_circle(cx : Int, cy : Int, r : Int, pixel : Pixel = Pixel.new)
      x, y = 0, r
      d = 3 - 2 * r

      loop do
        draw_point(cx + x, cy + y, pixel)
        draw_point(cx - x, cy + y, pixel)
        draw_point(cx + x, cy - y, pixel)
        draw_point(cx - x, cy - y, pixel)
        draw_point(cx + y, cy + x, pixel)
        draw_point(cx - y, cy + x, pixel)
        draw_point(cx + y, cy - x, pixel)
        draw_point(cx - y, cy - x, pixel)

        break if x > y

        x += 1

        if d > 0
          y -= 1
          d = d + 4 * (x - y) + 10
        else
          d = d + 4 * x + 6
        end
      end
    end

    def draw_circle(c : Vector(Int, 2), r : Int, pixel : Pixel = Pixel.new)
      draw_circle(c.x, c.y, r, pixel)
    end
  end
end
