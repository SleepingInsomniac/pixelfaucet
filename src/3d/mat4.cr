struct Mat4
  alias T = Float64
  alias RowT = Tuple(T, T, T, T)

  property matrix = Slice(T).new(4*4, 0.0)

  def index(x : Int, y : Int)
    y * 4 + x
  end

  def set(value : Tuple(RowT, RowT, RowT, RowT))
    {% for y in (0..3) %}
      {% for x in (0..3) %}
        self[{{x}},{{y}}] = value[{{x}}][{{y}}]
      {% end %}
    {% end %}
  end

  def [](x : Int, y : Int)
    self[index(x, y)]
  end

  def []=(x : Int, y : Int, value : Float64)
    self[index(x, y)] = value
  end

  def [](index)
    @matrix[index]
  end

  def []=(index, value)
    @matrix[index] = value
  end

  # Does not work for scaling, only for rotation / translation
  def quick_inverse
    matrix = Mat4.new
    matrix[0, 0] = self[0, 0]; matrix[0, 1] = self[1, 0]; matrix[0, 2] = self[2, 0]; matrix[0, 3] = 0.0
    matrix[1, 0] = self[0, 1]; matrix[1, 1] = self[1, 1]; matrix[1, 2] = self[2, 1]; matrix[1, 3] = 0.0
    matrix[2, 0] = self[0, 2]; matrix[2, 1] = self[1, 2]; matrix[2, 2] = self[2, 2]; matrix[2, 3] = 0.0
    matrix[3, 0] = -(self[3, 0] * matrix[0, 0] + self[3, 1] * matrix[1, 0] + self[3, 2] * matrix[2, 0])
    matrix[3, 1] = -(self[3, 0] * matrix[0, 1] + self[3, 1] * matrix[1, 1] + self[3, 2] * matrix[2, 1])
    matrix[3, 2] = -(self[3, 0] * matrix[0, 2] + self[3, 1] * matrix[1, 2] + self[3, 2] * matrix[2, 2])
    matrix[3, 3] = 1.0
    matrix
  end
end
