module PF
  class Sprite
    def draw_curve(curve : Bezier::Cubic, samples : Int = 100, pixel : Pixel = Pixel.new)
      point = curve.p0
      0.upto(samples) do |x|
        t = x / samples
        next_point = curve.at(t)
        draw_line(point.to_i, next_point.to_i, pixel)
        point = next_point
      end
    end

    def draw_curve(curve : Bezier::Cubic, pixel : Pixel)
      draw_curve(curve, pixel: pixel)
    end
  end
end
