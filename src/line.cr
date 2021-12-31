require "crystaledge/vector2"

module PF
  include CrystalEdge

  struct Line(T)
    property p1 : Point(T), p2 : Point(T)

    def initialize(@p1 : Point(T), @p2 : Point(T))
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

    def length
      Math.sqrt((run.abs * 2) + (rise.abs * 2))
    end

    def to_vector
      Vector2.new(run.to_f64, rise.to_f64)
    end

    def /(n : (Float | Int))
      Line.new(@p1 / n, @p2 / n)
    end

    def to_point
      Point.new(run, rise)
    end
  end
end
