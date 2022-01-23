require "./matrix"
require "./vector"

module PF
  class Transform2d
    property matrix : Matrix(Float64, 3, 3)

    def self.identity
      Matrix[
        1.0, 0.0, 0.0,
        0.0, 1.0, 0.0,
        0.0, 0.0, 1.0,
      ]
    end

    # Returns a matrix representing a 2d translation
    def self.translation(x : Float | Int, y : Float | Int)
      Matrix[
        1.0, 0.0, x.to_f64,
        0.0, 1.0, y.to_f64,
        0.0, 0.0, 1.0,
      ]
    end

    # Returns a matrix representing a 2d scaling
    def self.scale(x : Float | Int, y : Float | Int)
      Matrix[
        x.to_f64, 0.0, 0.0,
        0.0, y.to_f64, 0.0,
        0.0, 0.0, 1.0,
      ]
    end

    # Returns a matrix representing a 2d rotation
    def self.rotation(angle : Float | Int)
      cos = Math.cos(angle)
      sin = Math.sin(angle)
      Matrix[
        cos, -sin, 0.0,
        sin, cos, 0.0,
        0.0, 0.0, 1.0,
      ]
    end

    # Returns a matrix representing a 2d shear
    def self.shear(x : Float | Int, y : Float | Int)
      Matrix[
        1.0, x.to_f64, 0.0,
        y.to_f64, 1.0, 0.0,
        0.0, 0.0, 1.0,
      ]
    end

    # Return a new inverted version of the given *matrix*
    def self.invert(matrix : Matrix)
      det = matrix[0, 0] * (matrix[1, 1] * matrix[2, 2] - matrix[1, 2] * matrix[2, 1]) -
            matrix[1, 0] * (matrix[0, 1] * matrix[2, 2] - matrix[2, 1] * matrix[0, 2]) +
            matrix[2, 0] * (matrix[0, 1] * matrix[1, 2] - matrix[1, 1] * matrix[0, 2])

      idet = 1.0 / det

      Matrix[
        (matrix[1, 1] * matrix[2, 2] - matrix[1, 2] * matrix[2, 1]) * idet,
        (matrix[2, 0] * matrix[1, 2] - matrix[1, 0] * matrix[2, 2]) * idet,
        (matrix[1, 0] * matrix[2, 1] - matrix[2, 0] * matrix[1, 1]) * idet,

        (matrix[2, 1] * matrix[0, 2] - matrix[0, 1] * matrix[2, 2]) * idet,
        (matrix[0, 0] * matrix[2, 2] - matrix[2, 0] * matrix[0, 2]) * idet,
        (matrix[0, 1] * matrix[2, 0] - matrix[0, 0] * matrix[2, 1]) * idet,

        (matrix[0, 1] * matrix[1, 2] - matrix[0, 2] * matrix[1, 1]) * idet,
        (matrix[0, 2] * matrix[1, 0] - matrix[0, 0] * matrix[1, 2]) * idet,
        (matrix[0, 0] * matrix[1, 1] - matrix[0, 1] * matrix[1, 0]) * idet,
      ]
    end

    def initialize
      @matrix = PF::Transform2d.identity
    end

    def initialize(@matrix)
    end

    # =============

    # Reset the transformation to the identity matrix
    def reset
      @matrix = PF::Transform2d.identity
      self
    end

    # =============
    # = translate =
    # =============

    # Translate by *x* and *y*
    def translate(x : Number, y : Number)
      @matrix = PF::Transform2d.translation(x, y) * @matrix
      self
    end

    # ditto
    def translate(point : Vector2)
      translate(point.x, point.y)
    end

    # ==========
    # = rotate =
    # ==========

    # Rotate by *angle* (in radians)
    def rotate(angle : Float | Int)
      @matrix = PF::Transform2d.rotation(angle) * @matrix
      self
    end

    # =========
    # = scale =
    # =========

    # Scale by *x* and *y*
    def scale(x : Float | Int, y : Float | Int)
      @matrix = PF::Transform2d.scale(x, y) * @matrix
      self
    end

    # ditto
    def scale(point : Vector2)
      scale(point.x, point.y)
    end

    # Scale both x and y by *n*
    def scale(n : Number)
      scale(n, n)
    end

    # =========
    # = shear =
    # =========

    # Shear by *x* and *y*
    def shear(x : Float | Int, y : Float | Int)
      @matrix = PF::Transform2d.shear(x, y) * @matrix
      self
    end

    # ditto
    def shear(point : Vector2)
      shear(point.x, point.y)
    end

    # ==========

    # Return the boudning box of the current transformation matrix
    def bounding_box(x : Float | Int, y : Float | Int)
      top_left = apply(0.0, 0.0)
      top_right = apply(x.to_f, 0.0)
      bot_right = apply(x.to_f, y.to_f)
      bot_left = apply(0.0, y.to_f)

      xs = Float64[top_left.x, top_right.x, bot_right.x, bot_left.x]
      ys = Float64[top_left.y, top_right.y, bot_right.y, bot_left.y]

      {Vector[xs.min, ys.min], Vector[xs.max, ys.max]}
    end

    # Invert the transformation
    def invert
      @matrix = PF::Transform2d.invert(@matrix)
      self
    end

    def apply(x : Float | Int, y : Float | Int)
      result = Vector[x, y, 1.0] * @matrix
      Vector[result.x, result.y]
    end

    def apply(point : Vector2)
      apply(point.x, point.y)
    end
  end
end
