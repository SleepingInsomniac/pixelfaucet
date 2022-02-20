require "../bezier"

module PF
  module Bezier
    struct Cubic(T)
      include Aproximations

      def self.point(t : Float64, p0 : Number, p1 : Number, p2 : Number, p3 : Number)
        (1 - t) ** 3 * p0 + 3 * (1 - t) ** 2 * t * p1 + 3 * (1 - t) * t ** 2 * p2 + t ** 3 * p3
      end

      def self.derivative(t : Float64, p0 : Number, p1 : Number, p2 : Number, p3 : Number)
        3 * (1 - t) ** 2 * (p1 - p0) + 6 * (1 - t) * t * (p2 - p1) + 3 * t ** 2 * (p3 - p2)
      end

      def self.second_derivative(t : Float64, p0 : Number, p1 : Number, p2 : Number, p3 : Number)
        6 * (1 - t) * (p2 - 2 * p1 + p0) + 6 * t * (p3 - 2 * p2 + p1)
      end

      property p0 : Vector2(T)
      property p1 : Vector2(T)
      property p2 : Vector2(T)
      property p3 : Vector2(T)

      def initialize(@p0 : Vector2(T), @p1 : Vector2(T), @p2 : Vector2(T), @p3 : Vector2(T))
      end

      def points
        {pointerof(@p0), pointerof(@p1), pointerof(@p2), pointerof(@p3)}
      end

      # Get the point at percentage *t* < 0 < 1 of the curve
      def at(t : Float64)
        Vector[
          T.new(self.class.point(t, @p0.x, @p1.x, @p2.x, @p3.x)),
          T.new(self.class.point(t, @p0.y, @p1.y, @p2.y, @p3.y)),
        ]
      end

      # Get the tangent to a point at *t* < 0 < 1 on the spline
      def tangent(t : Float64)
        Vector[
          T.new(self.class.derivative(t, @p0.x, @p1.x, @p2.x, @p3.x)),
          T.new(self.class.derivative(t, @p0.y, @p1.y, @p2.y, @p3.y)),
        ].normalized
      end

      # Get the normal to a point at *t* < 0 < 1 on the spline
      def normal(t : Float64)
        Vector[
          T.new(self.class.derivative(t, @p0.y, @p1.y, @p2.y, @p3.y)),
          T.new(-self.class.derivative(t, @p0.x, @p1.x, @p2.x, @p3.x)),
        ].normalized
      end
    end
  end
end
