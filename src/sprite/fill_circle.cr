module PF
  class Sprite
    # Fill a circle using Bresenham’s Algorithm
    def fill_circle(cx : Int, cy : Int, r : Int, pixel : Pixel = Pixel.new)
      x, y = 0, r
      balance = 0 - r

      while x <= y
        p0 = cx - x
        p1 = cx - y

        w0 = x + x
        w1 = y + y

        scan_line(p0, cy + y, w0, pixel)
        scan_line(p0, cy - y, w0, pixel)
        scan_line(p1, cy + x, w1, pixel)
        scan_line(p1, cy - x, w1, pixel)

        x += 1
        balance += x + x

        if balance >= 0
          y -= 1
          balance -= (y + y)
        end
      end
    end

    def fill_circle(c : Vector2(Int), r : Int, pixel : Pixel = Pixel.new)
      fill_circle(c.x, c.y, r, pixel)
    end
  end
end
