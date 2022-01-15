module PF
  struct Vec3d(T)
    property x : T
    property y : T
    property z : T
    property w : T

    def initialize(@x : T, @y : T, @z : T, w = nil)
      @w = w || T.new(1)
    end

    # Standard operations
    {% for op in %w[* / // + - %] %}
      def {{ op.id }}(other : Vec3d)
        Vec3d.new(@x {{op.id}} other.x, @y {{op.id}} other.y, @z {{op.id}} other.z)
      end

      def {{ op.id }}(n : (Int | Float))
        Vec3d.new(@x {{op.id}} n, @y {{op.id}} n, @z {{op.id}} n)
      end
    {% end %}

    {% for op in %w[- abs] %}
      def {{op.id}}
        Vec3d.new(@x.{{op.id}}, @y.{{op.id}}, @z.{{op.id}})
      end
    {% end %}

    def *(matrix : Mat4)
      vec = Vec3d.new(
        @x * matrix[0, 0] + @y * matrix[1, 0] + @z * matrix[2, 0] + matrix[3, 0],
        @x * matrix[0, 1] + @y * matrix[1, 1] + @z * matrix[2, 1] + matrix[3, 1],
        @x * matrix[0, 2] + @y * matrix[1, 2] + @z * matrix[2, 2] + matrix[3, 2]
      )
      w = @x * matrix[0, 3] + @y * matrix[1, 3] + @z * matrix[2, 3] + matrix[3, 3]
      vec /= w # unless w == 0.0
      vec
    end

    def cross(other : Vec3d)
      Vec3d.new(
        x: @y * other.z - @z * other.y,
        y: @z * other.x - @x * other.z,
        z: @x * other.y - @y * other.x
      )
    end

    # Geth the length using pythagorean
    def magnitude
      Math.sqrt(@x ** 2 + @y ** 2 + @z ** 2)
    end

    def normalized
      l = magnitude
      Vec3d.new(@x / l, @y / l, @z / l)
    end

    # Returns the dot product
    def dot(other : Vec3d)
      @x * other.x + @y * other.y + @z * other.z
    end
  end
end
