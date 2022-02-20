module PF
  module Bezier
    struct Quad(T)
      include Aproximations

      def self.point(t : Float64, p0 : Number, p1 : Number, p2 : Number)
        (1 - t) ** 2 * p0 + 2 * (1 - t) * t * p1 + t ** 2 * p2
      end

      property p0 : Vector2(T)
      property p1 : Vector2(T)
      property p2 : Vector2(T)

      def initialize(@p0 : Vector2(T), @p1 : Vector2(T), @p2 : Vector2(T))
      end

      def points
        {pointerof(@p0), pointerof(@p1), pointerof(@p2)}
      end

      # Get the point at percentage *t* of the curve
      def at(t : Float64)
        Vector[
          self.class.point(t, @p0.x, @p1.x, @p2.x),
          self.class.point(t, @p0.y, @p1.y, @p2.y),
        ]
      end
    end
  end
end
