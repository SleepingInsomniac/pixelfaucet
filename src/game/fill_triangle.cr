require "../line"

module PF
  abstract class Game
    def fill_triangle(p1 : Vector2, p2 : Vector2, p3 : Vector2, pixel : Pixel = Pixel.new, surface = @screen)
      p1 = Point(Int32).new(x: p1.x.to_i, y: p1.y.to_i)
      p2 = Point(Int32).new(x: p2.x.to_i, y: p2.y.to_i)
      p3 = Point(Int32).new(x: p3.x.to_i, y: p3.y.to_i)
      fill_triangle(p1, p2, p3, pixel, surface)
    end

    def fill_triangle(p1 : PF::Point, p2 : PF::Point, p3 : PF::Point, pixel : Pixel = Pixel.new, surface = @screen)
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

    # Fills a triangle shape by drawing two edges from the top vertex and scanning across left to right
    def fill_triangle_bresenham(p1 : Point, p2 : Point, p3 : Point, pixel : Pixel = Pixel.new, surface = @screen)
      # Sort points from top to bottom
      p1, p2 = p2, p1 if p2.y < p1.y
      p1, p3 = p3, p1 if p3.y < p1.y
      p2, p3 = p3, p2 if p3.y < p2.y

      s1 = p2 - p1
      m1 = s1.y / s1.x

      edge1 = calculate_edge(p1, p2)
      edge2 = calculate_edge(p1, p3)
      edge3 = calculate_edge(p2, p3)

      if edge1.size > edge2.size
        edge2.pop
        edge2.concat edge3
      else
        edge1.pop
        edge1.concat edge3
      end

      0.upto(edge1.size - 1) do |line|
        if edge1[line].x < edge2[line].x
          edge1[line].x.upto(edge2[line].x) { |x| draw_point(x, edge1[line].y, pixel, surface) }
        else
          edge2[line].x.upto(edge1[line].x) { |x| draw_point(x, edge1[line].y, pixel, surface) }
        end
      end
    end

    # Calculate an edge using Bresenham’s Algorithm
    def calculate_edge(p1 : Point, p2 : Point)
      # The slope for each axis
      slope = Point.new((p2.x - p1.x).abs, -(p2.y - p1.y).abs)

      # The step direction in both axis
      step = Point.new(p1.x < p2.x ? 1 : -1, p1.y < p2.y ? 1 : -1)

      # The final decision accumulation
      # Initialized to the height of x and y
      decision = slope.x + slope.y

      edge = [] of Point(Int32)
      point = p1

      edge << point

      loop do
        # draw_point(point.x, point.y, Pixel.yellow)
        # Break if we've reached the ending point
        break if point == p2

        # Square the decision to avoid floating point calculations
        decision_squared = decision + decision

        # if decision_squared is greater than
        if decision_squared >= slope.y
          decision += slope.y
          point.x += step.x
        end

        if decision_squared <= slope.x
          decision += slope.x
          point.y += step.y
          edge << point
        end
      end

      edge
    end
  end
end
