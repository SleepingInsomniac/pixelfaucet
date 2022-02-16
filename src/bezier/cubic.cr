require "../bezier"

module PF
  struct BezierCubic(T)
    def self.point(t : Float64, p0 : Number, p1 : Number, p2 : Number, p3 : Number)
      (1 - t) ** 3 * p0 + 3 * (1 - t) ** 2 * t * p1 + 3 * (1 - t) * t ** 2 * p2 + t ** 3 * p3
    end

    property p0 : Vector2(T)
    property p1 : Vector2(T)
    property p2 : Vector2(T)
    property p3 : Vector2(T)

    def initialize(@p0 : Vector2(T), @p1 : Vector2(T), @p2 : Vector2(T), @p3 : Vector2(T))
    end

    def [](index : Int)
      points[index]
    end

    def points
      {pointerof(@p0), pointerof(@p1), pointerof(@p2), pointerof(@p3)}
    end

    # Get the point at percentage *t* of the curve
    def at(t : Float64)
      Vector[
        BezierCubic.point(t, @p0.x, @p1.x, @p2.x, @p3.x),
        BezierCubic.point(t, @p0.y, @p1.y, @p2.y, @p3.y),
      ]
    end

    # Get the length of the curve by calculating the length of line segments
    def length(steps : UInt32 = 10)
      _length = 0.0
      seg_p0 = Vector[@p0.x, @p0.y]
      seg_p1 = uninitialized Vector2(T)

      0.upto(steps) do |n|
        t = n / steps
        seg_p1 = at(t)
        _length += seg_p0.distance(seg_p1)
        seg_p0 = seg_p1
      end
      _length
    end
  end
end
