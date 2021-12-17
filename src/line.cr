module PF
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
      rise.to_f / run.to_f
    end

    def length
      Math.sqrt((run * 2) + (rise * 2))
    end
  end
end
