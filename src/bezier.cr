module PF
  module Bezier
    alias Curve = Quad(Float64) | Cubic(Float64)

    module Aproximations
      # Get the length of the curve by calculating the length of line segments
      # Increase *steps* for accuracy
      def length(steps : UInt32 = 10)
        _length = 0.0
        seg_p0 = Vector[@p0.x, @p0.y]

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
end

require "./bezier/*"
