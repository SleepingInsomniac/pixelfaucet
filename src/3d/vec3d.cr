struct Vec3d(T)
  property x : T
  property y : T
  property z : T
  property w : T

  # Given a point on a plane *plane_point*, and a normal to the plane *plane_normal*,
  # see if a line from *line_start* to *line_end* intersects a plane, and return the
  # point at intersection
  def self.line_intersects_plane(plane_point : Vec3d, plane_normal : Vec3d, line_start : Vec3d, line_end : Vec3d)
    plane_normal = plane_normal.normalized
    plane_dot_product = -plane_normal.dot(plane_point)
    ad = line_start.dot(plane_normal)
    bd = line_end.dot(plane_normal)
    t = (-plane_dot_product - ad) / (bd - ad)
    line_start_to_end = line_end - line_start
    line_to_intersect = line_start_to_end * t
    line_start + line_to_intersect
  end

  def initialize(@x : T, @y : T, @z : T, @w = T.new(1))
  end

  def +(other : T)
    Vec3d.new(@x + other, @y + other, @z + other)
  end

  def +(other : Vec3d)
    Vec3d.new(@x + other.x, @y + other.y, @z + other.z)
  end

  def -(other : T)
    Vec3d.new(@x - other, @y - other, @z - other)
  end

  def -(other : Vec3d)
    Vec3d.new(@x - other.x, @y - other.y, @z - other.z)
  end

  def *(matrix : Mat4)
    vec = Vec3d.new(
      @x * matrix[0, 0] + @y * matrix[1, 0] + @z * matrix[2, 0] + matrix[3, 0],
      @x * matrix[0, 1] + @y * matrix[1, 1] + @z * matrix[2, 1] + matrix[3, 1],
      @x * matrix[0, 2] + @y * matrix[1, 2] + @z * matrix[2, 2] + matrix[3, 2]
    )
    w = @x * matrix[0, 3] + @y * matrix[1, 3] + @z * matrix[2, 3] + matrix[3, 3]
    vec /= w unless w == 0.0
    vec
  end

  def *(other : Vec3d)
    Vec3d.new(@x * other.x, @y * other.y, @z * other.z)
  end

  def *(other : T)
    Vec3d.new(@x * other, @y * other, @z * other)
  end

  def /(other : Vec3d)
    Vec3d.new(@x / other.x, @y / other.y, @z / other.z)
  end

  def /(other : T)
    Vec3d.new(@x / other, @y / other, @z / other)
  end

  def cross_product(other : Vec3d)
    Vec3d.new(
      x: @y * other.z - @z * other.y,
      y: @z * other.x - @x * other.z,
      z: @x * other.y - @y * other.x
    )
  end

  # Geth the length using pythagorean
  def length
    Math.sqrt(@x * @x + @y * @y + @z * @z)
  end

  def normalized
    l = length
    Vec3d.new(@x / l, @y / l, @z / l)
  end

  # Returns the dot product
  def dot(other : Vec3d)
    @x * other.x + @y * other.y + @z * other.z
  end
end
