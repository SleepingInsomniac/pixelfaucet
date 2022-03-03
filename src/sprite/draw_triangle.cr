module PF
  class Sprite
    # Draws 3 lines
    def draw_triangle(p1 : Vector2(Int), p2 : Vector2(Int), p3 : Vector2(Int), pixel : Pixel = Pixel.new)
      draw_line(p1, p2, pixel)
      draw_line(p2, p3, pixel)
      draw_line(p3, p1, pixel)
    end
  end
end
