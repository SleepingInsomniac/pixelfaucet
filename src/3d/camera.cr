require "./vec3d"
require "./mat4"

module PF
  class Camera
    property position : Vec3d(Float64) = Vec3d.new(0.0, 0.0, 0.0)
    property up : Vec3d(Float64) = Vec3d.new(0.0, 1.0, 0.0)
    property rotation : Vec3d(Float64) = Vec3d.new(0.0, 0.0, 0.0)

    # Rotation about the X axis
    def pitch
      @rotation.x
    end

    def pitch=(value)
      @rotation.x = value
    end

    # Rotation about the Z axis
    def roll
      @rotation.z
    end

    def roll=(value)
      @rotation.z = value
    end

    # Rotation about the Y axis
    def yaw
      @rotation.y
    end

    def yaw=(value)
      @rotation.y = value
    end

    def forward_vector
      Vec3d.new(0.0, 0.0, 1.0) * rotation_matrix
    end

    def strafe_vector
      Vec3d.new(1.0, 0.0, 0.0) * rotation_matrix
    end

    def up_vector
      Vec3d.new(0.0, 1.0, 0.0) * rotation_matrix
    end

    def matrix
      Mat4.point_at(@position, @position + forward_vector, up_vector)
    end

    def view_matrix
      matrix.quick_inverse
    end

    def rotation_matrix
      Mat4.rot_x(pitch) * Mat4.rot_y(yaw) * Mat4.rot_z(roll)
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
      self.yaw += delta
    end

    def rotate_right(delta : Float64)
      self.yaw -= delta
    end

    def move_forward(delta : Float64)
      @position = @position + (@look_direction * delta)
    end

    def move_backward(delta : Float64)
      @position = @position - (@look_direction * delta)
    end
  end
end
