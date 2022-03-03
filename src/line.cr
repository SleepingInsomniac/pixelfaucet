require "./vector"

module PF
  struct Line(T)
    property p1 : Vector2(T), p2 : Vector2(T)

    def initialize(@p1 : Vector2(T), @p2 : Vector2(T))
    end

    def rise
      @p2.y - @p1.y
    end

    def run
      @p2.x - @p1.x
    end

    def slope
      return 0.0 if run == 0
      rise / run
    end

    def inv_slope
      return 0.0 if rise == 0
      run / rise
    end

    def left
      @p1.x < @p2.x ? @p1.x : @p2.x
    end

    def right
      @p1.x > @p2.x ? @p1.x : @p2.x
    end

    def top
      @p1.y > @p2.y ? @p2.y : @p1.y
    end

    def bottom
      @p1.y > @p2.y ? @p1.y : @p2.y
    end

    def contains_y?(y)
      if @p1.y < @p2.y
        top, bottom = @p1.y, @p2.y
      else
        top, bottom = @p2.y, @p1.y
      end

      y >= top && y <= bottom
    end

    def y_at(x)
      return p1.y if slope == 1.0
      x * slope + p1.y
    end

    def x_at(y)
      return p1.x if slope == 0.0
      (y - p1.y) / slope + p1.x
    end

    # Linearly interpolate
    def lerp(t : Float64)
      (@p2 - @p1) * t + @p1
    end

    def length
      Math.sqrt((run.abs * 2) + (rise.abs * 2))
    end

    def /(n : (Float | Int))
      Line.new(@p1 / n, @p2 / n)
    end

    def to_point
      Vector[run, rise]
    end

    # Find the normal axis to this line
    def normal
      Vector[-rise, run].normalized
    end

    # Normal counter clockwise
    def normal_cc
      Vector[rise, -run].normalized
    end
  end
end
