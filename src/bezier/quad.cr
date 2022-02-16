module PF
  struct BezierQuad(T)
    def self.point(t : Float64, p0 : Number, p1 : Number, p2 : Number)
      (1 - t) ** 2 * p0 + 2 * (1 - t) * t * p1 + t ** 2 * p2
    end

    property p0 : Vector2(T)
    property p1 : Vector2(T)
    property p2 : Vector2(T)

    def initialize(@p0 : Vector2(T), @p1 : Vector2(T), @p2 : Vector2(T))
    end

    def [](index : Int)
      points[index]
    end

    def points
      {pointerof(@p0), pointerof(@p1), pointerof(@p2)}
    end

    # Get the point at percentage *t* of the curve
    def at(t : Float64)
      Vector[
        BezierQuad.point(t, @p0.x, @p1.x, @p2.x),
        BezierQuad.point(t, @p0.y, @p1.y, @p2.y),
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
