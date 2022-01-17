module PF
  class Sprite
    # Draw a single point
    def draw_point(x : Int32, y : Int32, color : UInt32)
      if x >= 0 && x < width && y >= 0 && y < height
        pixel_pointer(x, y).value = color
      end
    end

    # ditto
    def draw_point(x : Int32, y : Int32, pixel : Pixel = Pixel.new)
      draw_point(x, y, pixel.format(format))
    end

    # ditto
    def draw_point(point : Vector2(Int), pixel : Pixel = Pixel.new)
      draw_point(point.x, point.y, pixel)
    end

    # ditto
    def draw_point(point : Vector2(Float), pixel : Pixel = Pixel.new)
      draw_point(point.to_i32, pixel)
    end
  end
end
