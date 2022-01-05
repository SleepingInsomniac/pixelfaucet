module PF
  struct Vector(T, S)
    property values : StaticArray(T, S)

    # Creates a new `Vector` with the given *args*
    #
    # ```
    # v = Vector[1, 2]
    # v[0]    # => 1
    # v[1]    # => 2
    # v.class # => Vector(Int32, 2)
    # ```
    macro [](*args)
      %array = uninitialized StaticArray(typeof({{*args}}), {{args.size}})
      {% for arg, i in args %}
        %array.to_unsafe[{{i}}] = {{arg}}
      {% end %}
      Vector(typeof({{*args}}), {{args.size}}).new(%array)
    end

    # Creates a new unitialized `Vector`
    def initialize
      @values = uninitialized StaticArray(T, S)
    end

    # Creates a new `Vector` from a `StaticArray`
    def initialize(@values)
    end

    def initialize(*args)
      @values = uninitialized StaticArray(T, S)
      args.each_with_index { |v, i| @values[i] = v }
    end

    def size
      S
    end

    {% for char, index in %w[x y z w] %}
      # Return positional values by common use index
      def {{ char.id }}
        values[{{ index }}]
      end

      # Set positional values by common use index
      def {{ char.id }}=(value : T)
        values[{{ index }}] = value
      end
    {% end %}

    def [](index : Int)
      values[index]
    end

    def []=(index : Int, value : T)
      values[index] = value
    end

    def ==(other : Vector)
      values == other.values
    end

    # Standard operations
    {% for op in %w[* / + - %] %}
      def {{ op.id }}(other : Vector)
        Vector(T, S).new(values.map_with_index { |v, i| v {{ op.id }} other[i] })
      end

      def {{ op.id }}(other : (Int | Float))
        Vector(T, S).new(values.map { |v| v {{ op.id }} other })
      end
    {% end %}

    def >(other : Vector)
      values.zip(other.values).all? { |a, b| a > b }
    end

    def <(other : Vector)
      values.zip(other.values).all? { |a, b| a < b }
    end

    def abs
      Vector(T, S).new(values.map(&.abs))
    end

    # The length or magnitude of the vector calculated by the Pythagorean theorem
    def magnitude
      Math.sqrt(values.reduce(T.new(0)) { |m, v| m + v ** 2 })
    end

    # Returns a new normalized unit `Vector`
    def normalized
      m = magnitude
      return self if m == 0.0
      i = (1.0 / m)
      Vector(Float64, S).new(values.map { |v| v * i })
    end

    # Returns the dot product of this vector and another
    def dot(other : Vector)
      (self * other).values.reduce { |m, v| m + v }
    end

    def cross(other : Vector)
      {% if S == 2 %}
        Vector[
          x * other.y - y * other.x,
          y * other.x - x * other.y,
        ]
      {% elsif S == 3 %}
        Vector[
          y * other.z - z * other.y,
          z * other.x - x * other.z,
          x * other.y - y * other.x,
        ]
      {% elsif S == 4 %}
        Vector[
          y * other.z - z * other.y,
          z * other.x - x * other.z,
          x * other.y - y * other.x,
          T.new(0),
        ]
      {% else %}
        raise "Cannot compute cross product of Vector size {{ S }}"
      {% end %}
    end

    def normal(other : Vector)
      cross(other).normalized
    end

    # Returns the distance between two Vectors
    def distance(other : Vector)
      (self - other).magnitude
    end
  end

  alias Vec2 = Vector(Int32, 2)
  alias Vec2f = Vector(Float64, 2)
  alias Vec3 = Vector(Int32, 3)
  alias Vec3f = Vector(Float64, 3)
  alias Vec4 = Vector(Int32, 4)
  alias Vec4f = Vector(Float64, 4)
end
