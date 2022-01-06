require "../line"

module PF
  abstract class Game
    def fill_triangle(p1 : Vector, p2 : Vector, p3 : Vector, pixel : Pixel = Pixel.new, surface = @screen)
      # Sort points from top to bottom
      p1, p2 = p2, p1 if p2.y < p1.y
      p1, p3 = p3, p1 if p3.y < p1.y
      p2, p3 = p3, p2 if p3.y < p2.y

      # sort left and right edges by run / rise
      line_left = PF::Line.new(p1, p2)
      line_right = PF::Line.new(p1, p3)

      if line_left.run / line_left.rise > line_right.run / line_right.rise
        line_left, line_right = line_right, line_left
      end

      # calculate line slopes
      slope_left = line_left.slope
      slope_right = line_right.slope

      c = p1.y # offset
      height = p3.y - p1.y
      mid = p2.y - p1.y

      0.upto(height) do |y|
        if slope_left == 0
          # When there is no rise, set the x value directly
          x_left = line_left.p2.x
        else
          x_left = ((y - (line_left.p1.y - p1.y)) / slope_left).round.to_i + line_left.p1.x
        end

        if slope_right == 0
          x_right = line_right.p2.x
        else
          x_right = ((y - (line_right.p1.y - p1.y)) / slope_right).round.to_i + line_right.p1.x
        end

        x_left.upto(x_right) do |x|
          draw_point(x, y + c, pixel, surface)
        end

        if y == mid
          if line_left.p2 == p2
            line_left = PF::Line.new(p2, p3)
            slope_left = line_left.slope
          else
            line_right = PF::Line.new(p2, p3)
            slope_right = line_right.slope
          end
        end
      end
    end

    def fill_triangle(points : Enumerable(Vector), pixel : Pixel = Pixel.new, surface = @screen)
      fill_triangle(points[0], points[1], points[2], pixel, surface)
    end
  end
end
