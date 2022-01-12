module PF
  class Sprite
    # Draw lines enclosing a shape
    def draw_shape(points : Enumerable(Vector), pixel : Pixel = Pixel.new)
      0.upto(points.size - 1) do |n|
        draw_line(points[n], points[(n + 1) % points.size], pixel)
      end
    end

    # Ditto
    def draw_shape(*points : Vector, color : Pixel = Pixel.new)
      draw_shape(points, color)
    end
  end
end
