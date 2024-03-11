require "./matrix"

module PF
  abstract struct Vector
    # Creates a new `Vector` with the given *args*
    #
    # ```
    # PF::Vector[1, 2] # => PF::Vector2(Int32)(@x=1, @y=2)
    # ```
    macro [](*args)
      PF::Vector{{args.size}}(typeof({{args.splat}})).new(
        {% for arg in args %}
          {{ arg }},
        {% end %}
      )
    end
  end

  {% for i in 2..4 %}
    {% vars = %w[x y z w] %}
    struct Vector{{i}}(T) < Vector
      {% for arg in 0...i %}
        property {{vars[arg].id}} : T
      {% end %}

      def initialize({% for arg in 0...i %} @{{vars[arg].id}} : T, {% end %})
      end

      # Returns the size of this vector
      # ```
      # PF::Vector{{i}}.new(...).size => {{i}}
      # ```
      def size
        {{ i.id }}
      end

      # Converts this Vector into a `StaticArray(T, {{i}})`
      def to_a
        StaticArray[{% for arg in 0...i %} @{{vars[arg].id}}, {% end %}]
      end

      {% for op in %w[> < >= <= ==] %}
        # Tests if all components of each vector meet the `{{op.id}}` condition
        def {{ op.id }}(other : Vector{{i}})
          {% for arg in 0...i %}
            return false unless @{{vars[arg].id}} {{op.id}} other.{{vars[arg].id}}
          {% end %}
          true
        end

        # Tests if all components of this vector meet the `{{op.id}}` condition with the given *n*
        def {{ op.id }}(n : (Int | Float))
          {% for arg in 0...i %}
            return false unless @{{vars[arg].id}} {{op.id}} n
          {% end %}
          true
        end
      {% end %}

      {% for op in %w[- abs] %}
        # Calls `{{ op.id }}` on all components of this vector
        def {{op.id}}
          Vector{{i}}(T).new({% for arg in 0...i %} @{{vars[arg].id}}.{{op.id}}, {% end %})
        end
      {% end %}

      {% for op in %w[* / // + - % **] %}
        # Applies `{{op.id}}` to all component of this vector with the corresponding component of *other*
        def {{ op.id }}(other : Vector{{i}})
          Vector[{% for arg in 0...i %} @{{vars[arg].id}} {{op.id}} other.{{vars[arg].id}}, {% end %}]
        end

        # Applies `{{op.id}}` to all component of this vector with *n*
        def {{ op.id }}(n : (Int | Float))
          Vector[{% for arg in 0...i %} @{{vars[arg].id}} {{op.id}} n, {% end %}]
        end
      {% end %}

      # Add all components together
      def sum
        {% for arg in 0...i %}
          @{{vars[arg].id}} {% if arg != i - 1 %} + {% end %}
        {% end %}
      end

      # The length or magnitude of the vector calculated by the Pythagorean theorem
      def magnitude
        Math.sqrt({% for arg in 0...i %} @{{vars[arg].id}} ** 2 {% if arg != i - 1 %} + {% end %}{% end %})
      end

      # Returns a new normalized unit `Vector{{i}}`
      def normalized
        m = magnitude
        return self if m == 0
        i = (1.0 / m)
        Vector[{% for arg in 0...i %} @{{vars[arg].id}} * i, {% end %}]
      end

      # Returns the dot product of this vector and *other*
      def dot(other : Vector{{i}})
        {% for arg in 0...i %} @{{vars[arg].id}} * other.{{vars[arg].id}} {% if arg != i - 1 %} + {% end %}{% end %}
      end

      # Calculates the cross product of this vector and *other*
      def cross(other : Vector{{i}})
        {% if i == 2 %}
          Vector[
            x * other.y - y * other.x,
            y * other.x - x * other.y,
          ]
        {% elsif i == 3 %}
          Vector[
            y * other.z - z * other.y,
            z * other.x - x * other.z,
            x * other.y - y * other.x,
          ]
        {% elsif i == 4 %}
          Vector[
            y * other.z - z * other.y,
            z * other.x - x * other.z,
            x * other.y - y * other.x,
            T.new(0),
          ]
        {% end %}
      end

      # Returns normalized value at a normal to the current vector
      def normal(other : Vector{{i}})
        cross(other).normalized
      end

      # Returns the distance between this vector and *other*
      def distance(other : Vector{{i}})
        (self - other).magnitude
      end

      # Multiply this vector by a *matrix*
      #
      # ```
      # v = PF::Vector[1, 2, 3]
      # m = PF::Matrix[
      #   1, 0, 0,
      #   0, 2, 0,
      #   0, 0, 1,
      # ]
      # # => PF::Vector3(Int32)(@x=1, @y=4, @z=3)
      # ```
      def *(matrix : Matrix)
        PF::Vector[{% for row in 0...i %}
          {% for col in 0...i %} @{{ vars[col].id }} * matrix[{{col}}, {{row}}] {% if col != i - 1 %} + {% end %}{% end %},
        {% end %}]
      end

      {% for method, type in {
                               to_i: Int32, to_u: UInt32, to_f: Float64,
                               to_i8: Int8, to_i16: Int16, to_i32: Int32, to_i64: Int64, to_i128: Int128,
                               to_u8: UInt8, to_u16: UInt16, to_u32: UInt32, to_u64: UInt64, to_u128: UInt128,
                               to_f32: Float32, to_f64: Float64,
                             } %}
        # Convert the components in this vector to {{ type }}
        def {{ method }}
          Vector{{i}}({{ type }}).new({% for arg in 0...i %} @{{vars[arg].id}}.{{method}}, {% end %})
        end
      {% end %}
    end
  {% end %}
end
