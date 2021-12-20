module PF
  struct Mat4
    alias T = Float64
    alias RowT = Tuple(T, T, T, T)

    property matrix = Slice(T).new(4*4, 0.0)

    def self.identity
      new(Slice[
        T.new(1), T.new(0), T.new(0), T.new(0),
        T.new(0), T.new(1), T.new(0), T.new(0),
        T.new(0), T.new(0), T.new(1), T.new(0),
        T.new(0), T.new(0), T.new(0), T.new(1),
      ])
    end

    def self.point_at(position : Vec3d, target : Vec3d, up : Vec3d = Vec3d.new(0.0, 1.0, 0.0))
      new_forward = (target - position).normalized
      new_up = (up - new_forward * up.dot(new_forward)).normalized
      new_right = new_up.cross_product(new_forward)

      matrix = Mat4.new
      matrix[0, 0] = new_right.x
      matrix[0, 1] = new_right.y
      matrix[0, 2] = new_right.z
      matrix[0, 3] = 0.0

      matrix[1, 0] = new_up.x
      matrix[1, 1] = new_up.y
      matrix[1, 2] = new_up.z
      matrix[1, 3] = 0.0

      matrix[2, 0] = new_forward.x
      matrix[2, 1] = new_forward.y
      matrix[2, 2] = new_forward.z
      matrix[2, 3] = 0.0

      matrix[3, 0] = position.x
      matrix[3, 1] = position.y
      matrix[3, 2] = position.z
      matrix[3, 3] = 1.0

      matrix
    end

    def self.rot_x(theta : T)
      cox = Math.cos(theta)
      sox = Math.sin(theta)
      new(Slice[
        1.0, 0.0, 0.0, 0.0,
        0.0, cox, sox, 0.0,
        0.0, -sox, cox, 0.0,
        0.0, 0.0, 0.0, 1.0,
      ])
    end

    def self.rot_y(theta : T)
      coy = Math.cos(theta)
      soy = Math.sin(theta)
      new(Slice[
        coy, 0.0, soy, 0.0,
        0.0, 1.0, 0.0, 0.0,
        -soy, 0.0, coy, 0.0,
        0.0, 0.0, 0.0, 1.0,
      ])
    end

    def self.rot_z(theta : T)
      coz = Math.cos(theta)
      siz = Math.sin(theta)
      new(Slice[
        coz, siz, 0.0, 0.0,
        -siz, coz, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 1.0,
      ])
    end

    def self.rotation(r : Vec3d)
      Mat4.rot_x(r.x) * Mat4.rot_y(r.y) * Mat4.rot_z(r.z)
    end

    def self.translation(pos : Vec3d)
      new(Slice[
        1.0, 0.0, 0.0, pos.x,
        0.0, 1.0, 0.0, pos.y,
        0.0, 0.0, 1.0, pos.z,
        0.0, 0.0, 0.0, 1.0,
      ])
    end

    def initialize
    end

    def initialize(values : Slice(T))
      @matrix = values
    end

    def initialize(values : Tuple(RowT, RowT, RowT, RowT))
      {% for y in (0..3) %}
        {% for x in (0..3) %}
          self[{{x}},{{y}}] = values[{{y}}][{{x}}]
        {% end %}
      {% end %}
    end

    def index(x : Int, y : Int)
      y * 4 + x
    end

    def fill(value : T)
      @matrix.fill(value)
    end

    def set(values : Slice(T))
      @matrix = values
    end

    def set(values : Tuple(RowT, RowT, RowT, RowT))
      {% for y in (0..3) %}
        {% for x in (0..3) %}
          self[{{x}},{{y}}] = values[{{y}}][{{x}}]
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

    def *(other : Mat4)
      result = Mat4.new
      {% for y in (0..3) %}
        {% for x in (0..3) %}
          {% for n in (0..3) %}
            result[{{x}},{{y}}] = result[{{x}},{{y}}] + self[{{n}}, {{y}}] * other[{{x}}, {{n}}]
          {% end %}
        {% end %}
      {% end %}
      result
    end

    def translate(pos : Vec3d)
      self * Mat4.translation(pos)
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
end
