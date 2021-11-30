module PF
  struct Point(T)
    property x : T, y : T

    def initialize(@x : T, @y : T)
    end
  end
end
