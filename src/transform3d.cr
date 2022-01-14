require "./matrix"
require "./vector"

module PF
  class Transform3d
    property matrix : Matrix(Float64, 4, 4)

    def self.identity
      Matrix[
        1.0, 0.0, 0.0, 0.0,
        0.0, 1.0, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 1.0,
      ]
    end

    def self.rot_x(theta : Float64)
      cox, sox = Math.cos(theta), Math.sin(theta)
      Matrix[
        1.0, 0.0, 0.0, 0.0,
        0.0, cox, sox, 0.0,
        0.0, -sox, cox, 0.0,
        0.0, 0.0, 0.0, 1.0,
      ]
    end

    def self.rot_y(theta : Float64)
      coy, soy = Math.cos(theta), Math.sin(theta)
      Matrix[
        coy, 0.0, soy, 0.0,
        0.0, 1.0, 0.0, 0.0,
        -soy, 0.0, coy, 0.0,
        0.0, 0.0, 0.0, 1.0,
      ]
    end

    def self.rot_z(theta : Float64)
      coz, siz = Math.cos(theta), Math.sin(theta)
      Matrix[
        coz, siz, 0.0, 0.0,
        -siz, coz, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 1.0,
      ]
    end

    def self.rotation(x : Float64, y : Float64, z : Float64)
      self.rot_x(x) * self.rot_y(y) * self.rot_z(z)
    end

    def self.rotation(angle : Vector(Float64, 3))
      self.rotation(angle.x, angle.y, angle.z)
    end

    def self.translation(x : Float64, y : Float64, z : Float64)
      Matrix[
        1.0, 0.0, 0.0, x,
        0.0, 1.0, 0.0, y,
        0.0, 0.0, 1.0, z,
        0.0, 0.0, 0.0, 1.0,
      ]
    end

    def self.translation(pos : Vector(Float64, 3))
      self.translation(pos.x, pos.y, pos.z)
    end

    # Does not work for scaling, only for rotation / translation
    def self.quick_inverse(other : Matrix)
      matrix = Matrix(Float64, 4, 4).new
      matrix[0, 0] = other[0, 0]; matrix[0, 1] = other[1, 0]; matrix[0, 2] = other[2, 0]; matrix[0, 3] = 0.0
      matrix[1, 0] = other[0, 1]; matrix[1, 1] = other[1, 1]; matrix[1, 2] = other[2, 1]; matrix[1, 3] = 0.0
      matrix[2, 0] = other[0, 2]; matrix[2, 1] = other[1, 2]; matrix[2, 2] = other[2, 2]; matrix[2, 3] = 0.0
      matrix[3, 0] = -(other[3, 0] * matrix[0, 0] + other[3, 1] * matrix[1, 0] + other[3, 2] * matrix[2, 0])
      matrix[3, 1] = -(other[3, 0] * matrix[0, 1] + other[3, 1] * matrix[1, 1] + other[3, 2] * matrix[2, 1])
      matrix[3, 2] = -(other[3, 0] * matrix[0, 2] + other[3, 1] * matrix[1, 2] + other[3, 2] * matrix[2, 2])
      matrix[3, 3] = 1.0
      matrix
    end

    def self.point_at(position : Vector(Float64, 3), target : Vector(Float64, 3), up : Vector(Float64, 3) = Vector[0.0, 1.0, 0.0])
      new_forward = (target - position).normalized
      new_up = (up - new_forward * up.dot(new_forward)).normalized
      new_right = new_up.cross(new_forward)

      Matrix[
        new_right.x, new_up.x, new_forward.x, position.x,
        new_right.y, new_up.y, new_forward.y, position.y,
        new_right.z, new_up.z, new_forward.z, position.z,
        0.0, 0.0, 0.0, 1.0,
      ]
    end

    # TODO: Optionally return the result of w in some way (pointer / tuple?)
    def self.apply(point : Vector(Float64, 3), matrix : Matrix(Float64, 4, 4))
      vector = Vector[point.x, point.y, point.z, 1.0] * matrix
      if vector.w == 0.0
        Vector[vector.x, vector.y, vector.z]
      else
        Vector[vector.x, vector.y, vector.z] / vector.w
      end
    end

    def initialize
      @matrix = PF::Transform3d.identity
    end

    def initialize(@matrix)
    end

    def reset
      @matrix = PF::Transform3d.identity
      self
    end

    def rot_x(theta : Float64)
      @matrix = PF::Transform3d.rot_x(theta) * @matrix
      self
    end

    def rot_y(theta : Float64)
      @matrix = PF::Transform3d.rot_y(theta) * @matrix
      self
    end

    def rot_z(theta : Float64)
      @matrix = PF::Transform3d.rot_z(theta) * @matrix
      self
    end

    def self.rotate(r : Vector(Float64, 3))
      rot_x(r.x)
      rot_y(r.y)
      rot_z(r.z)
      self
    end

    def translate(pos : Vector(Float64, 3))
      @matrix = PF::Transform3d.translation * @matrix
      self
    end

    # Does not work for scaling, only for rotation / translation
    def quick_invert
      @matrix = PF::Transform3d.quick_inverse(@matrix)
      self
    end

    # TODO: Optionally return the result of w in some way (pointer / tuple?)
    def apply(point : Vector(Float64, 3))
      vector = Vector[point.x, point.y.point.z, 1.0] * @matrix
      if vector.w == 0.0
        Vector[vector.x, vector.y, vector.z]
      else
        Vector[vector.x, vector.y, vector.z] / vector.w
      end
    end
  end
end
