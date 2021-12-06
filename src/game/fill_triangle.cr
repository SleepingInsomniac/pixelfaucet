module PF
  abstract class Game
    def fill_triangle(p1 : Vector2, p2 : Vector2, p3 : Vector2, pixel : Pixel = Pixel.new, surface = @screen)
      p1 = Point(Int32).new(x: p1.x.to_i, y: p1.y.to_i)
      p2 = Point(Int32).new(x: p2.x.to_i, y: p2.y.to_i)
      p3 = Point(Int32).new(x: p3.x.to_i, y: p3.y.to_i)
      fill_triangle(p1, p2, p3, pixel, surface)
    end

    # Fills a triangle shape by drawing two edges from the top vertex and scanning across left to right
    def fill_triangle(p1 : Point, p2 : Point, p3 : Point, pixel : Pixel = Pixel.new, surface = @screen)
      # Sort points from top to bottom
      p1, p2 = p2, p1 if p2.y < p1.y
      p1, p3 = p3, p1 if p3.y < p1.y
      p2, p3 = p3, p2 if p3.y < p2.y

      s1 = p2 - p1
      m1 = s1.y / s1.x

      edge1 = calculate_edge(p1, p2)
      edge2 = calculate_edge(p1, p3)
      edge3 = calculate_edge(p2, p3)
      edge3.pop

      if edge1.size > edge2.size
        edge2.concat edge3
      else
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
