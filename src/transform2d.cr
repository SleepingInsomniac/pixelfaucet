require "./matrix"
require "./vector"

module PF
  class Transform2d
    property matrix : Matrix(Float64, 3, 3) = Matrix[
      1.0, 0.0, 0.0,
      0.0, 1.0, 0.0,
      0.0, 0.0, 1.0,
    ]

    def initialize
    end

    def initialize(@matrix)
    end

    def reset
      @matrix = Matrix[
        1.0, 0.0, 0.0,
        0.0, 1.0, 0.0,
        0.0, 0.0, 1.0,
      ]
      self
    end

    def translate(x : Float | Int, y : Float | Int)
      @matrix = Matrix[
        1.0, 0.0, x.to_f64,
        0.0, 1.0, y.to_f64,
        0.0, 0.0, 1.0,
      ] * @matrix
      self
    end

    def translate(to : Vector2)
      translate(to.x, to.y)
    end

    def scale(x : Float | Int, y : Float | Int)
      @matrix = Matrix[
        x.to_f64, 0.0, 0.0,
        0.0, y.to_f64, 0.0,
        0.0, 0.0, 1.0,
      ] * @matrix
      self
    end

    def scale(n : Float | Int)
      scale(n, n)
    end

    def rotate(angle : Float | Int)
      cos = Math.cos(angle)
      sin = Math.sin(angle)
      @matrix = Matrix[
        cos, -sin, 0.0,
        sin, cos, 0.0,
        0.0, 0.0, 1.0,
      ] * @matrix
      self
    end

    def shear(x : Float | Int, y : Float | Int)
      @matrix = Matrix[
        1.0, x.to_f64, 0.0,
        y.to_f64, 1.0, 0.0,
        0.0, 0.0, 1.0,
      ] * @matrix
      self
    end

    def bounding_box(x : Float | Int, y : Float | Int)
      top_left = apply(0.0, 0.0)
      top_right = apply(x.to_f, 0.0)
      bot_right = apply(x.to_f, y.to_f)
      bot_left = apply(0.0, y.to_f)

      xs = Float64[top_left.x, top_right.x, bot_right.x, bot_left.x]
      ys = Float64[top_left.y, top_right.y, bot_right.y, bot_left.y]

      {Vector[xs.min, ys.min], Vector[xs.max, ys.max]}
    end

    def invert
      det = @matrix[0, 0] * (@matrix[1, 1] * @matrix[2, 2] - @matrix[1, 2] * @matrix[2, 1]) -
            @matrix[1, 0] * (@matrix[0, 1] * @matrix[2, 2] - @matrix[2, 1] * @matrix[0, 2]) +
            @matrix[2, 0] * (@matrix[0, 1] * @matrix[1, 2] - @matrix[1, 1] * @matrix[0, 2])

      idet = 1.0 / det

      @matrix = Matrix[
        (@matrix[1, 1] * @matrix[2, 2] - @matrix[1, 2] * @matrix[2, 1]) * idet,
        (@matrix[2, 0] * @matrix[1, 2] - @matrix[1, 0] * @matrix[2, 2]) * idet,
        (@matrix[1, 0] * @matrix[2, 1] - @matrix[2, 0] * @matrix[1, 1]) * idet,

        (@matrix[2, 1] * @matrix[0, 2] - @matrix[0, 1] * @matrix[2, 2]) * idet,
        (@matrix[0, 0] * @matrix[2, 2] - @matrix[2, 0] * @matrix[0, 2]) * idet,
        (@matrix[0, 1] * @matrix[2, 0] - @matrix[0, 0] * @matrix[2, 1]) * idet,

        (@matrix[0, 1] * @matrix[1, 2] - @matrix[0, 2] * @matrix[1, 1]) * idet,
        (@matrix[0, 2] * @matrix[1, 0] - @matrix[0, 0] * @matrix[1, 2]) * idet,
        (@matrix[0, 0] * @matrix[1, 1] - @matrix[0, 1] * @matrix[1, 0]) * idet,
      ]
      self
    end

    def apply(x : Float | Int, y : Float | Int)
      result = Vector[x, y, typeof(x, y).new(1)] * @matrix
      Vector[result.x, result.y]
    end

    def apply(point : Vector2)
      apply(point.x, point.y)
    end
  end
end
