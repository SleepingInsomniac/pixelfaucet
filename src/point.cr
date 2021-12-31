module PF
  struct Point(T)
    property x : T, y : T

    def initialize(@x : T, @y : T)
    end

    def ==(other : Point(Float | Int))
      self.x == other.x && self.y == other.y
    end

    def *(n : Float | Int)
      Point.new(x * n, y * n)
    end

    def *(other : Point(Float | Int))
      Point.new(x * other.x, y * other.y)
    end

    def /(n : Float | Int)
      Point.new(x / n, y / n)
    end

    def /(other : Point(Float | Int))
      Point.new(x / other.x, y / other.y)
    end

    def +(other : Point(Float | Int))
      Point.new(x + other.x, y + other.y)
    end

    def -(other : Point(Float | Int))
      Point.new(x - other.x, y - other.y)
    end

    def abs
      Point.new(x.abs, y.abs)
    end

    def length
      Math.sqrt((x.abs ** 2) + (y.abs ** 2))
    end

    def normalized
      l = length
      return self if l == 0.0
      i = (1.0 / l)
      Point.new(x * i, y * i)
    end

    def dot(other : Point)
      x * other.x + y * other.y
    end

    def cross(other : Point)
      Point.new(x * other.y - y * other.x, y * other.x - x * other.y)
    end

    def inspect
      "(#{@x}, #{@y})"
    end
  end
end
