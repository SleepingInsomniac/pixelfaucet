require "./matrix"

module PF
  struct Vector(T, S)
    property values : Slice(T)

    # Creates a new `Vector` with the given *args*
    #
    # ```
    # v = Vector[1, 2]
    # v[0]    # => 1
    # v[1]    # => 2
    # v.class # => Vector(Int32, 2)
    # ```
    macro [](*args)
      %values = Slice(typeof({{*args}})).new({{args.size}}, typeof({{*args}}).new(0))
      {% for arg, i in args %}
        %values.to_unsafe[{{i}}] = {{arg}}
      {% end %}
      PF::Vector(typeof({{*args}}), {{args.size}}).new(%values)
    end

    # Creates a new unitialized `Vector`
    def initialize
      @values = Slice(T).new(S, T.new(0))
    end

    # Creates a new `Vector` from a `Slice`
    def initialize(@values)
    end

    # Create a new `Vector` with the given values
    def initialize(*nums : T)
      @values = Slice(T).new(S) { |i| nums[i] }
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
    {% for op in %w[* / // + - %] %}
      def {{ op.id }}(other : Vector)
        Vector(T, S).new(values.map_with_index { |v, i| v {{ op.id }} other[i] })
      end

      def {{ op.id }}(n : (Int | Float))
        v = values.map { |v| v {{ op.id }} n }
        Vector(typeof(v.first), S).new(values.map { |v| v {{ op.id }} n })
      end
    {% end %}

    # Comparison methods
    {% for op in %w[> < >= <=] %}
      def {{ op.id }}(other : Vector)
        values.zip(other.values).all? { |a, b| a {{ op.id }} b }
      end

      def {{ op.id }}(n : (Int | Float))
        values.all? { |v| v {{ op.id }} n }
      end
    {% end %}

    {% for op in %w[- abs] %}
      # Return a new vector with {{op}} applied to each value
      def {{op.id}}
        Vector(T, S).new(values.map(&.{{op.id}}))
      end
    {% end %}

    # The length or magnitude of the vector calculated by the Pythagorean theorem
    def magnitude
      Math.sqrt(values.reduce(T.new(0)) { |m, v| m + v ** 2 })
    end

    # ditto
    def length
      magnitude
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

    # Calculates the cross product of this vector and another based on the vector size
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

    # Returns normalized value at a normal to the current vector
    def normal(other : Vector)
      cross(other).normalized
    end

    # Returns the distance between two Vectors
    def distance(other : Vector)
      (self - other).magnitude
    end

    def *(matrix : Matrix)
      # a b c   x   ax + by + cz
      # d e f * y = dx + ey + fz
      # g h i   z   gx + hy + iz
      new_values = matrix.values.each_slice(S)
        .map { |slice| slice.map_with_index { |v, i| v * values[i] }.reduce { |m, v| m + v } }
      new_vec = Vector(typeof(new_values.first), S).new
      new_values.each_with_index { |v, i| new_vec[i] = v }
      new_vec
    end

    # Type conversion methods
    {% for method, type in {
                             to_i: Int32, to_u: UInt32, to_f: Float64,
                             to_i8: Int8, to_i16: Int16, to_i32: Int32, to_i64: Int64, to_i128: Int128,
                             to_u8: UInt8, to_u16: UInt16, to_u32: UInt32, to_u64: UInt64, to_u128: UInt128,
                             to_f32: Float32, to_f64: Float64,
                           } %}
      def {{ method }}
        Vector({{ type }}, S).new(values.map(&.{{ method }}))
      end
    {% end %}
  end

  alias Vec2 = Vector(Int32, 2)
  alias Vec2f = Vector(Float64, 2)
  alias Vec3 = Vector(Int32, 3)
  alias Vec3f = Vector(Float64, 3)
  alias Vec4 = Vector(Int32, 4)
  alias Vec4f = Vector(Float64, 4)
end
