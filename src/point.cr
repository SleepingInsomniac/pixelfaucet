module PF
  struct Point(T)
    property x : T, y : T

    def initialize(@x : T, @y : T)
    end

    def ==(other : Point(T))
      self.x == other.x && self.y == other.y
    end

    def +(other : Point(T))
      self.x + other.x
      self.y + other.y
      self
    end

    def -(other : Point(T))
      self.x - other.x
      self.y - other.y
      self
    end
  end
end
