require "./vec3d"
require "./mat4"

module PF
  class Camera
    property position : Vec3d(Float64) = Vec3d.new(0.0, 0.0, 0.0)
    property up : Vec3d(Float64) = Vec3d.new(0.0, 1.0, 0.0)
    property yaw : Float64 = 0.0

    def forward_vector
      Vec3d.new(0.0, 0.0, 1.0) * rotation_matrix
    end

    def strafe_vector
      Vec3d.new(1.0, 0.0, 0.0) * rotation_matrix
    end

    def matrix
      Mat4.point_at(@position, @position + forward_vector, @up)
    end

    def view_matrix
      matrix.quick_inverse
    end

    def rotation_matrix
      Mat4.rot_y(@yaw)
    end

    def move_right(delta : Float64)
      @position = @position - (strafe * delta)
    end

    def move_left(delta : Float64)
      @position = @position + (strafe * delta)
    end

    def move_up(delta : Float64)
      @position.y = @position.y + delta
    end

    def move_down(delta : Float64)
      @position.y = @position.y - delta
    end

    def rotate_left(delta : Float64)
      @yaw = @yaw + delta
    end

    def rotate_right(delta : Float64)
      @yaw = @yaw - delta
    end

    def move_forward(delta : Float64)
      @position = @position + (@look_direction * delta)
    end

    def move_backward(delta : Float64)
      @position = @position - (@look_direction * delta)
    end
  end
end
