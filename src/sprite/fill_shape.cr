module PF
  class Sprite
    # Fill an abitrary polygon. Expects a clockwise winding of points
    def fill_shape(points : Enumerable(Vector), color : Pixel = Pixel.new)
      return if points.empty?
      return draw_point(points[0], color) if points.size == 1
      return draw_line(points[0], points[1], color) if points.size == 2
      return draw_triangle(points[0], points[1], points[2], color) if points.size == 3

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

      # Form lines from the points
      lines = [] of Line(Int32)
      0.upto(points.size - 1) do |n|
        lines << Line.new(points[n], points[(n + 1) % points.size])
      end

      # Start at the top of the bounding box and draw scanlines until the end
      top.upto(bottom) do |y|
        intercepts = [] of Tuple(Int32, Bool) # TODO: use deque?

        # Get the x intercepts for each line at this y level
        lines.each do |line|
          next unless line.contains_y?(y)
          x = line.x_at(y).round.to_i
          is_ascending = line.p2.y >= line.p1.y
          intercepts << {x, is_ascending}
        end

        # sort x intercepts from left to right
        intercepts.sort! { |a, b| a[0] <=> b[0] }
        n = 0 # count which intercepts we've crossed on the scanline

        # Start at the left boundary
        intercepts[0][0].upto(right) do |x|
          break if n >= intercepts.size # No need to draw if we reach the right shape boundary

          # Only draw points within x values of an ascending slope,
          # descending slope indicates that the point is outside of the shape
          if intercepts[n][1] || x == intercepts[n][0] # Always draw the border itself
            draw_point(x, y, color)
          end

          # # While condition for overlapping points
          while n != intercepts.size && x == intercepts[n][0]
            n += 1
          end
        end
      end
    end

    def fill_shape(*points : Vector, color : Pixel = Pixel.new)
      fill_shape(points, color)
    end
  end
end
