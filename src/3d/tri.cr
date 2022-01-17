require "../transform3d"
require "../pixel"
require "../g3d"

module PF
  struct Tri
    property p1 : Vector3(Float64)
    property p2 : Vector3(Float64)
    property p3 : Vector3(Float64)
    property color : PF::Pixel

    setter normal : Vector3(Float64)?

    def initialize(@p1 : Vector3(Float64), @p2 : Vector3(Float64), @p3 : Vector3(Float64), @color = PF::Pixel.white, @normal = nil)
    end

    def initialize(p1x : Float64, p1y : Float64, p1z : Float64, p2x : Float64, p2y : Float64, p2z : Float64, p3x : Float64, p3y : Float64, p3z : Float64, @color = PF::Pixel.white)
      @p1 = Vector3(Float64).new(p1x, p1y, p1z)
      @p2 = Vector3(Float64).new(p2x, p2y, p2z)
      @p3 = Vector3(Float64).new(p3x, p3y, p3z)
    end

    # Return the normal assuming clockwise pointing winding
    def normal
      @normal ||= begin
        line1 = @p2 - @p1
        line2 = @p3 - @p1
        line1.cross(line2).normalized
      end
    end

    # Get the average x value
    def x
      (@p1.x + @p2.x + @p3.x) / 3.0
    end

    # Get the average y value
    def y
      (@p1.y + @p2.y + @p3.y) / 3.0
    end

    # Get the average z value
    def z
      (@p1.z + @p2.z + @p3.z) / 3.0
    end

    # Multiply all points by a Mat4, returning a new Tri
    def *(mat : Mat4)
      Tri.new(
        Transform3d.apply(@p1, mat),
        Transform3d.apply(@p2, mat),
        Transform3d.apply(@p3, mat),
        @color
      )
    end

    # Split the triangle based on which points are inside of a given plane
    # Returns a tuple of 0-2 triangles
    def clip(plane : Vector3, plane_normal : Vector3)
      # Make sure plane normal is indeed normal
      plane_normal = plane_normal.normalized

      # Create two temporary storage arrays to classify points either side of plane
      inside_points = StaticArray(Vector3(Float64), 3).new(Vector3(Float64).new(0.0, 0.0, 0.0))
      inside_count = 0
      outside_points = StaticArray(Vector3(Float64), 3).new(Vector3(Float64).new(0.0, 0.0, 0.0))
      outside_count = 0

      # Classify each point as inside or outside of the plane
      {p1, p2, p3}.each do |p|
        # Get the distance of the point to the clipping plane
        distance = plane_normal.x * p.x + plane_normal.y * p.y + plane_normal.z * p.z - plane_normal.dot(plane)

        # If the distance is positive, our point lies on inside of plane
        if distance >= 0
          inside_points[inside_count] = p
          inside_count += 1
        else
          outside_points[outside_count] = p
          outside_count += 1
        end
      end

      # All points are inside of the plane
      # No clipping required, return the original triangle
      return {self} if inside_count == 3

      if inside_count == 1 && outside_count == 2
        # One point inside the plane
        # the two intersection points and the one inside point form a new triangle
        return {
          Tri.new(
            inside_points[0],
            G3d.line_intersects_plane(plane, plane_normal, inside_points[0], outside_points[0]),
            G3d.line_intersects_plane(plane, plane_normal, inside_points[0], outside_points[1]),
            color: @color
          ),
        }
      end

      if inside_count == 2 && outside_count == 1
        # Two points are inside the plane, this will form a quad
        # We must now split the quad into two new triangles

        # Calculate the two intersection points
        intersect_p1 = G3d.line_intersects_plane(plane, plane_normal, inside_points[0], outside_points[0])
        intersect_p2 = G3d.line_intersects_plane(plane, plane_normal, inside_points[1], outside_points[0])

        return {
          # The first triangle will have the two inside points, and first intersection point
          Tri.new(
            inside_points[0],
            inside_points[1],
            intersect_p1,
            color: @color
          ),
          # The second triangle will have the second inside point, the second intersection, then the first intersection
          # This order preserves clockwise winding
          Tri.new(
            inside_points[1],
            intersect_p2,
            intersect_p1,
            color: @color
          ),
        }
      end

      # No points are inside the plane
      # Return an empty tuple with no triangles
      Tuple.new
    end
  end
end
