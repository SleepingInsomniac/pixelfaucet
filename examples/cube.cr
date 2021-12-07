require "../src/game"
require "../src/controller"
require "../src/sprite"
require "../src/sprite/vector_sprite"
require "../src/pixel"
require "../src/point"

struct Vec3d(T)
  property x : T
  property y : T
  property z : T

  def initialize(@x : T, @y : T, @z : T)
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

  def normalized
    # pythag
    length = Math.sqrt(@x * @x + @y * @y + @z * @z)
    Vec3d.new(@x / length, @y / length, @z / length)
  end

  # Returns the dot product
  def dot(other : Vec3d)
    @x * other.x + @y * other.y + @z * other.z
  end
end

struct Mat4
  alias T = Float64
  alias RowT = Tuple(T, T, T, T)

  property matrix = Slice(T).new(4*4, 0.0)

  def index(x : Int, y : Int)
    y * 4 + x
  end

  def set(value : Tuple(RowT, RowT, RowT, RowT))
    {% for y in (0..4) %}
      {% for x in (0..4) %}
        self[x,y] = value[x][y]
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
end

struct Tri
  property p1 : Vec3d(Float64)
  property p2 : Vec3d(Float64)
  property p3 : Vec3d(Float64)

  @normal : Vec3d(Float64)?

  def initialize(@p1 : Vec3d(Float64), @p2 : Vec3d(Float64), @p3 : Vec3d(Float64))
  end

  def initialize(p1x : Float64, p1y : Float64, p1z : Float64, p2x : Float64, p2y : Float64, p2z : Float64, p3x : Float64, p3y : Float64, p3z : Float64)
    @p1 = Vec3d(Float64).new(p1x, p1y, p1z)
    @p2 = Vec3d(Float64).new(p2x, p2y, p2z)
    @p3 = Vec3d(Float64).new(p3x, p3y, p3z)
  end

  def normal
    # line 1 is p2 - p1, line2 is p3 - p1
    line1 = @p2 - @p1
    line2 = @p3 - @p1
    @normal ||= line1.cross_product(line2).normalized
  end

  def z
    (@p1.z + @p2.z + @p3.z) / 3.0
  end
end

class Mesh
  property tris = [] of Tri

  def initialize(@tris)
  end

  def self.load(path)
    verticies = [] of Vec3d(Float64)
    tris = [] of Tri

    File.open(path) do |file|
      file.each_line do |line|
        case line[0]
        when 'v'
          parts = line.split(/\s+/)
          verticies << Vec3d.new(parts[1].to_f64, parts[2].to_f64, parts[3].to_f64)
        when 'f'
          parts = line.split(/\s+/)
          tris << Tri.new(verticies[parts[1].to_i - 1], verticies[parts[2].to_i - 1], verticies[parts[3].to_i - 1])
        end
      end
    end

    new(tris)
  end
end

class Cube
  property mesh : Mesh
  property position = Vec3d(Float64).new(0.0, 0.0, 0.0)
  property rotation = Vec3d(Float64).new(0.0, 0.0, 0.0)

  @mat_rx = Mat4.new
  @mat_ry = Mat4.new
  @mat_rz = Mat4.new

  def initialize
    @mesh = Mesh.load("/Users/alex/Desktop/ship.obj")
    # @mesh = Mesh.new([
    #   # south
    #   Tri.new(0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0),
    #   Tri.new(0.0, 0.0, 0.0, 1.0, 1.0, 0.0, 1.0, 0.0, 0.0),
    #
    #   # east
    #   Tri.new(1.0, 0.0, 0.0, 1.0, 1.0, 0.0, 1.0, 1.0, 1.0),
    #   Tri.new(1.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 0.0, 1.0),
    #
    #   # north
    #   Tri.new(1.0, 0.0, 1.0, 1.0, 1.0, 1.0, 0.0, 1.0, 1.0),
    #   Tri.new(1.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 0.0, 1.0),
    #
    #   # west
    #   Tri.new(0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0, 0.0),
    #   Tri.new(0.0, 0.0, 1.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0),
    #
    #   # top
    #   Tri.new(0.0, 1.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0),
    #   Tri.new(0.0, 1.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0),
    #
    #   # bottom
    #   Tri.new(1.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0),
    #   Tri.new(1.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0),
    # ])
  end

  def update(dt : Float64)
    @mat_rz[0, 0] = Math.cos(@rotation.z)
    @mat_rz[0, 1] = Math.sin(@rotation.z)
    @mat_rz[1, 0] = -Math.sin(@rotation.z)
    @mat_rz[1, 1] = Math.cos(@rotation.z)
    @mat_rz[2, 2] = 1.0
    @mat_rz[3, 3] = 1.0

    @mat_rx[0, 0] = 1.0
    @mat_rx[1, 1] = Math.cos(@rotation.x)
    @mat_rx[1, 2] = Math.sin(@rotation.x)
    @mat_rx[2, 1] = -Math.sin(@rotation.x)
    @mat_rx[2, 2] = Math.cos(@rotation.x)
    @mat_rx[3, 3] = 1.0

    @mat_ry[0, 0] = Math.cos(@rotation.y)
    @mat_ry[0, 2] = Math.sin(@rotation.y)
    @mat_ry[1, 1] = 1.0
    @mat_ry[2, 0] = -Math.sin(@rotation.y)
    @mat_ry[2, 2] = Math.cos(@rotation.y)
    @mat_ry[3, 3] = 1.0
  end

  def draw(engine : PF::Game, mat_proj, camera, light)
    # Translation and rotation
    tris = @mesh.tris.map do |tri|
      tri.p1 *= @mat_rx
      tri.p2 *= @mat_rx
      tri.p3 *= @mat_rx

      tri.p1 *= @mat_ry
      tri.p2 *= @mat_ry
      tri.p3 *= @mat_ry

      tri.p1 *= @mat_rz
      tri.p2 *= @mat_rz
      tri.p3 *= @mat_rz

      tri.p1.z = tri.p1.z + 8.0
      tri.p2.z = tri.p2.z + 8.0
      tri.p3.z = tri.p3.z + 8.0

      tri
    end

    # only draw triangles facing the camera
    tris = tris.select do |tri|
      tri.normal.dot(tri.p1 - camera) < 0
    end

    # sort triangles
    tris = tris.sort { |a, b| b.z <=> a.z }

    tris.each do |tri|
      shade : UInt8 = (tri.normal.dot(light) * 255.0).clamp(0.0..255.0).to_u8

      tri.p1 *= mat_proj
      tri.p2 *= mat_proj
      tri.p3 *= mat_proj

      tri.p1 += 1.0
      tri.p2 += 1.0
      tri.p3 += 1.0

      tri.p1 *= 0.5 * engine.width
      tri.p2 *= 0.5 * engine.width
      tri.p3 *= 0.5 * engine.width

      engine.fill_triangle(
        PF::Point.new(tri.p1.x.to_i, tri.p1.y.to_i),
        PF::Point.new(tri.p2.x.to_i, tri.p2.y.to_i),
        PF::Point.new(tri.p3.x.to_i, tri.p3.y.to_i),
        pixel: PF::Pixel.new(shade, shade, shade, 255)
      )
    end
  end
end

class CubeGame < PF::Game
  @cube : Cube
  @paused = false

  @aspect_ratio : Float64
  @fov : Float64
  @fov_rad : Float64
  @near : Float64
  @far : Float64
  @camera : Vec3d(Float64)
  @light : Vec3d(Float64) = Vec3d.new(0.0, 0.0, -1.0).normalized

  @mat_proj : Mat4
  @speed = 3.0

  def initialize(@width, @height, @scale)
    super(@width, @height, @scale)

    @cube = Cube.new

    @controller = PF::Controller(LibSDL::Keycode).new({
      LibSDL::Keycode::RIGHT => "Rotate Right",
      LibSDL::Keycode::LEFT  => "Rotate Left",
      LibSDL::Keycode::UP    => "Rotate Up",
      LibSDL::Keycode::DOWN  => "Rotate Down",
      LibSDL::Keycode::SPACE => "Pause",
    })

    @near = 0.1
    @far = 1000.0
    @fov = 90.0
    @aspect_ratio = @height / @width
    @fov_rad = 1.0 / Math.tan(@fov * 0.5 / 180.0 * Math::PI)
    @camera = Vec3d.new(0.0, 0.0, 0.0)

    @mat_proj = Mat4.new
    @mat_proj[0, 0] = @aspect_ratio * @fov_rad
    @mat_proj[1, 1] = @fov_rad
    @mat_proj[2, 2] = @far / (@far - @near)
    @mat_proj[3, 2] = (-@far * @near) / (@far - @near)
    @mat_proj[2, 3] = 1.0
    @mat_proj[3, 3] = 0.0

    @theta = 0.0
  end

  def update(dt)
    @paused = !@paused if @controller.pressed?("Pause")

    if @controller.action?("Rotate Right")
      @cube.rotation = Vec3d.new(@cube.rotation.x + @speed * dt, @cube.rotation.y, @cube.rotation.z)
    end

    if @controller.action?("Rotate Left")
      @cube.rotation = Vec3d.new(@cube.rotation.x - @speed * dt, @cube.rotation.y, @cube.rotation.z)
    end

    if @controller.action?("Rotate Up")
      @cube.rotation = Vec3d.new(@cube.rotation.x, @cube.rotation.y, @cube.rotation.z - @speed * dt)
    end

    if @controller.action?("Rotate Down")
      @cube.rotation = Vec3d.new(@cube.rotation.x, @cube.rotation.y, @cube.rotation.z + @speed * dt)
    end

    unless @paused
      @theta += dt
      @cube.rotation = Vec3d.new(@cube.rotation.x, @cube.rotation.y + 1.0 * dt, @cube.rotation.z)
    end

    @cube.update(dt)
  end

  def draw
    clear(0, 0, 100)
    @cube.draw(self, @mat_proj, @camera, @light)
  end
end

engine = CubeGame.new(200, 200, 3)
engine.run!
