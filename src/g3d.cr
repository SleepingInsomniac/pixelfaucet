module PF
  module G3d
    # Given a point on a plane *plane_point*, and a normal to the plane *plane_normal*,
    # see if a line from *line_start* to *line_end* intersects a plane, and return the
    # point at intersection
    def self.line_intersects_plane(plane_point : Vector(Float64, 3), plane_normal : Vector(Float64, 3), line_start : Vector(Float64, 3), line_end : Vector(Float64, 3))
      plane_normal = plane_normal.normalized
      plane_dot_product = -plane_normal.dot(plane_point)
      ad = line_start.dot(plane_normal)
      bd = line_end.dot(plane_normal)
      t = (-plane_dot_product - ad) / (bd - ad)
      line_start_to_end = line_end - line_start
      line_to_intersect = line_start_to_end * t
      line_start + line_to_intersect
    end
  end
end
