module PF
  abstract class Game
    # Fill an abitrary polygon. Expects a clockwise winding of points
    def fill_shape(*points : Point, color : Pixel = Pixel.new, surface = @screen)
      return if points.empty?
      return draw_point(points[0], color, surface) if points.size == 1
      return draw_line(points[0], points[1], color, surface) if points.size == 2
      return draw_triangle(points[0], points[1], points[2], color, surface) if points.size == 3

      # set initial bounding box
      top = points[0].y
      bottom = points[-1].y
      left = points[0].x
      right = points[-1].x

      # find bounding box
      points.each do |point|
        top = point.y if point.y < top
        bottom = point.y if point.y > bottom
        left = point.x if point.x < left
        right = point.x if point.x > right
      end

      lines = [] of Line(Int32)
      0.upto(points.size - 1) do |n|
        lines << Line.new(points[n], points[(n + 1) % points.size])
      end

      top.upto(bottom) do |y|
        intercepts = [] of Int32 # TODO: use deque
        slopes = [] of Int32

        lines.each do |line|
          next unless line.contains_y?(y)
          intercepts << line.x_at(y).round.to_i
        end

        # sort x intercepts from left to right
        intercepts.sort!.uniq!
        n = 0

        intercepts[0].upto(right) do |x|
          break if n == intercepts.size

          draw_point(x, y, color, surface) if n.odd?

          while n != intercepts.size && x == intercepts[n]
            draw_point(x, y, color, surface)
            n += 1
          end
        end
      end
    end

    def draw_shape(*points : Point, color : Pixel = Pixel.new, surface = @screen)
      0.upto(points.size - 1) do |n|
        draw_line(points[n], points[(n + 1) % points.size], color, surface)
      end
    end
  end
end
