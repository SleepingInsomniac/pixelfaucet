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
      Matrix(typeof({{*args}}), {{args.size // 2}}, {{args.size // 2}}).new(%values)
    end

    def initialize
    end

    def initialize(@values)
    end

    # Width of the matrix
    def width
      W
    end

    # Height of the matrix
    def height
      H
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

    # TODO
  end
end
