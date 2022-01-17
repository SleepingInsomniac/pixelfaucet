module PF
  class Sprite
    # Draw a line using Bresenham’s Algorithm
    def draw_line(x1 : Int, y1 : Int, x2 : Int, y2 : Int, pixel : Pixel = Pixel.new)
      # The slope for each axis
      slope = Vector[(x2 - x1).abs, -(y2 - y1).abs]

      # The step direction in both axis
      step = Vector[x1 < x2 ? 1 : -1, y1 < y2 ? 1 : -1]

      # The final decision accumulation
      # Initialized to the height of x and y
      decision = slope.x + slope.y

      point = Vector[x1, y1]

      loop do
        draw_point(point.x, point.y, pixel)
        # Break if we've reached the ending point
        break if point.x == x2 && point.y == y2

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
        end
      end
    end

    # ditto
    def draw_line(p1 : Vector2(Int), p2 : Vector2(Int), pixel : Pixel = Pixel.new)
      draw_line(p1.x, p1.y, p2.x, p2.y, pixel)
    end

    # ditto
    def draw_line(p1 : Vector2(Float), p2 : Vector2(Float), pixel : Pixel = Pixel.new)
      draw_line(p1.to_i32, p2.to_i32, pixel)
    end

    # ditto
    def draw_line(line : Line, pixel : Pixel = Pixel.new)
      draw_line(line.p1.to_i32, line.p2.to_i32, pixel)
    end
  end
end
