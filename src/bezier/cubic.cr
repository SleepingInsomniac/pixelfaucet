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

      def self.extremeties(p0 : Number, p1 : Number, p2 : Number, p3 : Number)
        a = 3 * p3 - 9 * p2 + 9 * p1 - 3 * p0
        b = 6 * p0 - 12 * p1 + 6 * p2
        c = 3 * p1 - 3 * p0

        disc = b * b - 4 * a * c

        return Tuple.new unless disc >= 0

        t1 = (-b + Math.sqrt(disc)) / (2 * a)
        t2 = (-b - Math.sqrt(disc)) / (2 * a)

        accept_1 = t1 >= 0 && t1 <= 1
        accept_2 = t2 >= 0 && t2 <= 1

        if accept_1 && accept_2
          {t1, t2}
        elsif accept_1
          {t1}
        elsif accept_2
          {t2}
        else
          {0.5}
        end
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

      # Get the points at the extremeties of this curve
      def extremeties
        txs = self.class.extremeties(@p0.x, @p1.x, @p2.x, @p3.x)
        tys = self.class.extremeties(@p0.y, @p1.y, @p2.y, @p3.y)

        txs = txs.map { |t| at(t) }
        tys = tys.map { |t| at(t) }

        {txs, tys}
      end
    end
  end
end
