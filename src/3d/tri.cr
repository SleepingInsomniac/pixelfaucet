require "../transform3d"
require "../pixel"
require "../g3d"

module PF
  struct Tri
    property p1 : Vector3(Float64)
    property p2 : Vector3(Float64)
    property p3 : Vector3(Float64)

    property t1 : Vector3(Float64) = Vector[0.0, 0.0, 0.0]
    property t2 : Vector3(Float64) = Vector[0.0, 0.0, 0.0]
    property t3 : Vector3(Float64) = Vector[0.0, 0.0, 0.0]

    property color : PF::Pixel

    setter normal : Vector3(Float64)?

    def initialize(@p1 : Vector3(Float64), @p2 : Vector3(Float64), @p3 : Vector3(Float64), @color = PF::Pixel.white, @normal = nil)
    end

    def initialize(@p1, @p2, @p3, @t1, @t2, @t3, @color = PF::Pixel.white)
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

    # Multiply all points by a *Matrix*, returning a new *Tri*
    def *(mat : Matrix)
      pp1, w1 = Transform3d.apply(@p1, mat)
      pp2, w2 = Transform3d.apply(@p2, mat)
      pp3, w3 = Transform3d.apply(@p3, mat)

      Tri.new(
        pp1, pp2, pp3,
        @t1,
        @t2,
        @t3,
        @color
      )
    end

    # Split the triangle based on which points are inside of a given plane
    # Returns a tuple of 0-2 triangles
    def clip(plane : Vector3, plane_normal : Vector3)
      # Make sure plane normal is indeed normal
      plane_normal = plane_normal.normalized

      # Create two temporary storage arrays to classify points either side of plane
      inside_points = uninitialized StaticArray(Vector3(Float64), 3)
      inside_count = 0
      outside_points = uninitialized StaticArray(Vector3(Float64), 3)
      outside_count = 0

      # Create the same for texture points
      inside_texts = uninitialized StaticArray(Vector3(Float64), 3)
      outside_texts = uninitialized StaticArray(Vector3(Float64), 3)

      # Classify each point as inside or outside of the plane
      { {p1, t1}, {p2, t2}, {p3, t3} }.each do |p, t|
        # Get the distance of the point to the clipping plane
        distance = plane_normal.x * p.x + plane_normal.y * p.y + plane_normal.z * p.z - plane_normal.dot(plane)

        # If the distance is positive, our point lies on inside of the plane
        if distance >= 0
          inside_points[inside_count] = p
          inside_texts[inside_count] = t
          inside_count += 1
        else
          outside_points[outside_count] = p
          outside_texts[outside_count] = t
          outside_count += 1
        end
      end

      # Clip the entire triangle
      return Tuple.new if inside_count == 0

      # All points are inside of the plane
      # No clipping required, return the original triangle
      return {self} if inside_count == 3

      # Clip two points of the tri into one tri
      # One point inside the plane, 2 outside
      if inside_count == 1 && outside_count == 2
        # the two intersection points and the one inside point form a new triangle
        clip_p1, t = G3d.line_intersects_plane(plane, plane_normal, inside_points[0], outside_points[0])
        int_t1 = (outside_texts[0] - inside_texts[0]) * t + inside_texts[0]

        clip_p2, t = G3d.line_intersects_plane(plane, plane_normal, inside_points[0], outside_points[1])
        int_t2 = (outside_texts[1] - inside_texts[0]) * t + inside_texts[0]

        return {
          Tri.new(
            inside_points[0], clip_p1, clip_p2,
            inside_texts[0], int_t1, int_t2,
            color: @color
          ),
        }
      end

      # Clip one point of the tri, return two tris
      if inside_count == 2 && outside_count == 1
        # Two points are inside the plane, this will form a quad
        # We must now split the quad into two new triangles

        # Calculate the two intersection points
        clip_p1, t = G3d.line_intersects_plane(plane, plane_normal, inside_points[0], outside_points[0])
        int_t1 = (outside_texts[0] - inside_texts[0]) * t + inside_texts[0]

        clip_p2, t = G3d.line_intersects_plane(plane, plane_normal, inside_points[1], outside_points[0])
        int_t2 = (outside_texts[0] - inside_texts[1]) * t + inside_texts[1]

        return {
          # The first triangle will have the two inside points, and first intersection point
          Tri.new(
            inside_points[0], inside_points[1], clip_p1,
            inside_texts[0], inside_texts[1], int_t1,
            color: @color
          ),
          # The second triangle will have the second inside point, the second intersection, then the first intersection
          # This order preserves clockwise winding
          Tri.new(
            inside_points[1], clip_p2, clip_p1,
            inside_texts[1], int_t2, int_t1,
            color: @color
          ),
        }
      end

      # So the compiler doesn't complain about nil return type
      Tuple.new
    end
  end
end
