module PF
  class Sprite
    # Draws 3 lines
    def draw_triangle(p1 : Vector, p2 : Vector, p3 : Vector, pixel : Pixel = Pixel.new)
      draw_line(p1, p2, pixel)
      draw_line(p2, p3, pixel)
      draw_line(p3, p1, pixel)
    end
  end
end
