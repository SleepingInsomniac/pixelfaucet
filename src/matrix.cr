module PF
  struct Matrix(T, W, H)
    property values = Slice(T).new(W * H, T.new(0))

    # Creates a new square `Matrix` with the given *args*
    #
    # ```
    # m = Matrix[1, 2, 3, 4]
    # m[0, 0] # => 1
    # m[1, 0] # => 2
    # m[0, 1] # => 3
    # m[1, 1] # => 4
    # m.class # => Matrix(Int32, 2, 2)
    # ```
    macro [](*args)
      %values = Slice(typeof({{*args}})).new({{args.size}}, typeof({{*args}}).new(0))
      {% for arg, i in args %}
        %values.to_unsafe[{{i}}] = {{arg}}
      {% end %}
      # width and height are the isqrt of args.size
      {% if args.size == 1 %}
        PF::Matrix(typeof({{*args}}), 1, 1).new(%values)
      {% elsif args.size == 4 %}
        PF::Matrix(typeof({{*args}}), 2, 2).new(%values)
      {% elsif args.size == 9 %}
        PF::Matrix(typeof({{*args}}), 3, 3).new(%values)
      {% elsif args.size == 16 %}
        PF::Matrix(typeof({{*args}}), 4, 4).new(%values)
      {% else %}
        raise "Cannot determine width and height of matrix with {{ args.size }} elements, " \
              "please provide them explicitly Matrix(Int32, 4, 4).new(...)"
      {% end %}
    end

    def self.identity
      new.tap do |m|
        m.size.times { |n| m[n, n] = T.new(1) }
      end
    end

    def initialize
    end

    def initialize(@values)
    end

    # Create a new matrix
    #
    # ```
    # PF::Matrix(Int32, 2, 2).new(1, 2, 3, 4)
    # ```
    def initialize(*nums : T)
      nums.each_with_index { |n, i| @values.to_unsafe[i] = n }
    end

    # Width of the matrix
    def width
      W
    end

    # Height of the matrix
    def height
      H
    end

    def size
      {% if W == H %}
        W
      {% else %}
        raise "Matrix({{W}}x{{H}}) is not square"
      {% end %}
    end

    # Tests the equality of two matricies
    def ==(other : Matrix)
      self.values == other.values
    end

    # Get the index of an element in the matrix by *x* and *y* coordinates
    def index(x : Int, y : Int)
      y * width + x
    end

    def [](i : Int)
      @values[i]
    end

    def []=(i : Int, value : T)
      @values[i] = value
    end

    # Get an element
    def [](x : Int, y : Int)
      self[index(x, y)]
    end

    # Set an element at an *x* and *y* position
    def []=(x : Int, y : Int, value : T)
      self[index(x, y)] = value
    end

    def *(other : Matrix)
      result = Matrix(T, W, H).new
      {% for y in (0...H) %}
        {% for x in (0...W) %}
          {% for n in (0...W) %}
            result[{{x}},{{y}}] = result[{{x}},{{y}}] + self[{{n}}, {{y}}] * other[{{x}}, {{n}}]
          {% end %}
        {% end %}
      {% end %}
      result
    end

    def inspect
      String.build do |io|
        H.times do |h|
          io << '['
          W.times { |w| io << self[w, h] }
          io << "]\n"
        end
      end
    end
  end
end
