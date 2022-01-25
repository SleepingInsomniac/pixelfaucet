module PF
  struct Matrix(T, S)
    include Indexable::Mutable(T)

    getter values : StaticArray(T, S)
    getter width : UInt8
    getter height : UInt8

    # Creates a new square `Matrix` with the given *args*
    #
    # ```
    # m = Matrix[1, 2, 3, 4] # => Matrix(Int32, 4) 2x2 [1, 2, 3, 4]
    # ```
    macro [](*args)
      # width and height are the isqrt of args.size
      {% if args.size == 4 %}
        PF::Matrix(typeof({{*args}}), 4).new(2, 2, StaticArray[{{*args}}])
      {% elsif args.size == 9 %}
        PF::Matrix(typeof({{*args}}), 9).new(3, 3, StaticArray[{{*args}}])
      {% elsif args.size == 16 %}
        PF::Matrix(typeof({{*args}}), 16).new(4, 4, StaticArray[{{*args}}])
      {% else %}
        raise "Cannot determine width and height of matrix with {{ args.size }} elements, " \
              "please provide them explicitly Matrix(Int32, 16).new(4, 4, StaticArray[...])"
      {% end %}
    end

    def initialize(@width : UInt8, @height : UInt8)
      @values = StaticArray(T, S).new(T.new(0))
    end

    def initialize(@width : UInt8, @height : UInt8, @values : StaticArray(T, S))
    end

    delegate :fill, to: @values

    def index(col : Int, row : Int)
      row * width + col
    end

    def size
      S
    end

    def unsafe_fetch(index : Int)
      @values.unsafe_fetch(index)
    end

    def unsafe_put(index : Int, value : T)
      @values.unsafe_put(index, value)
    end

    # Fetch a value at a specified *column* and *row*
    def [](col : Int, row : Int)
      unsafe_fetch(index(col, row))
    end

    # Put a value at a specified *column* and *row*
    def []=(col : Int, row : Int, value : T)
      unsafe_put(index(col, row), value)
    end

    # Tests the equality of two matricies
    def ==(other : Matrix)
      self.values == other.values
    end

    def *(other : Matrix)
      result = Matrix(typeof(@values.unsafe_fetch(0) * other.values.unsafe_fetch(0)), S).new(width, height)
      (0...height).each do |row|
        (0...width).each do |col|
          (0...width).each do |n|
            result[col, row] = result[col, row] + self[n, row] * other[col, n]
          end
        end
      end
      result
    end

    def to_s(io)
      io << {{@type}} << ' ' << width << "x" << height << " ["
      {% for i in 0...S %}
        io << unsafe_fetch({{i}})
        {% if i != S - 1 %}
          io << ", "
        {% end %}
      {% end %}
      io << ']'
    end
  end
end
