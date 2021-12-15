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
  property w : T

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

  # Return the normal assuming clockwise pointing winding
  def normal
    line1 = @p2 - @p1
    line2 = @p3 - @p1
    @normal ||= line1.cross_product(line2).normalized
  end

  # Get the average x value
  def x
    (@p1.x + @p2.x + @p3.x) / 3.0
  end

  # Get the average y value
  def y
    (@p1.y + @p2.y + @p3.y) / 3.0
  end

  # Get the average z value
  def z
    (@p1.z + @p2.z + @p3.z) / 3.0
  end

  # Multiply all points by a Mat4, returning a new Tri
  def *(mat : Mat4)
    Tri.new(@p1 * mat, @p2 * mat, @p3 * mat)
  end
end

class Mesh
  property tris = [] of Tri

  def initialize(@tris)
  end

  def self.load(path)
    verticies = [] of Vec3d(Float64)
    tris = [] of Tri

    line_no = 0
    File.open(path) do |file|
      file.each_line do |line|
        line_no += 1
        next if line =~ /^\s*$/
        parts = line.split(/\s+/)
        case parts[0]
        when "v"
          verticies << Vec3d.new(parts[1].to_f64, parts[2].to_f64, parts[3].to_f64)
        when "f"
          face_verts = [] of Vec3d(Float64)
          parts[1..3].each do |part|
            face = part.split('/')
            face_verts << verticies[face[0].to_i - 1]
          end
          tris << Tri.new(face_verts[0], face_verts[1], face_verts[2])
        end
      end
    end

    new(tris)
  end
end

class Model
  property mesh : Mesh
  property position = Vec3d(Float64).new(0.0, 0.0, 0.0)
  property rotation = Vec3d(Float64).new(0.0, 0.0, 0.0)

  @mat_rx = Mat4.new
  @mat_ry = Mat4.new
  @mat_rz = Mat4.new
  @mat_translation = Mat4.new

  def initialize(obj : String)
    @mesh = Mesh.load(obj)
  end

  def update(dt : Float64)
    cox = Math.cos(@rotation.x)
    sox = Math.sin(@rotation.x)
    coy = Math.cos(@rotation.y)
    soy = Math.sin(@rotation.y)
    coz = Math.cos(@rotation.z)
    siz = Math.sin(@rotation.z)

    @mat_rx.set({
      {1.0, 0.0, 0.0, 0.0},
      {0.0, cox, sox, 0.0},
      {0.0, -sox, cox, 0.0},
      {0.0, 0.0, 0.0, 1.0},
    })

    @mat_ry.set({
      {coy, 0.0, soy, 0.0},
      {0.0, 1.0, 0.0, 0.0},
      {-soy, 0.0, coy, 0.0},
      {0.0, 0.0, 0.0, 1.0},
    })

    @mat_rz.set({
      {coz, siz, 0.0, 0.0},
      {-siz, coz, 0.0, 0.0},
      {0.0, 0.0, 1.0, 0.0},
      {0.0, 0.0, 0.0, 1.0},
    })

    @mat_translation.set({
      {1.0, 0.0, 0.0, 0.0},
      {0.0, 1.0, 0.0, 0.0},
      {0.0, 0.0, 1.0, 0.0},
      {@position.x, @position.y, @position.z, 1.0},
    })
  end

  def draw(engine : PF::Game, mat_proj, camera, light, look_direction)
    target = camera + look_direction
    mat_camera = engine.point_at(camera, target, Vec3d.new(0.0, 1.0, 0.0))
    mat_view = mat_camera.quick_inverse

    # Translation and rotation
    tris = @mesh.tris.map do |tri|
      tri *= @mat_rx
      tri *= @mat_ry
      tri *= @mat_rz
      tri *= @mat_translation

      tri
    end

    # only draw triangles facing the camera
    tris = tris.select do |tri|
      tri.normal.dot(tri.p1 - camera) < 0.0
    end

    # sort triangles
    tris = tris.sort { |a, b| b.z <=> a.z }

    tris.each do |tri|
      shade : UInt8 = (tri.normal.dot(light.normalized) * 255.0).clamp(0.0..255.0).to_u8

      tri.p1 *= mat_view
      tri.p2 *= mat_view
      tri.p3 *= mat_view

      tri.p1 *= mat_proj
      tri.p2 *= mat_proj
      tri.p3 *= mat_proj

      tri.p1 += 1.0
      tri.p2 += 1.0
      tri.p3 += 1.0

      tri.p1.x = tri.p1.x * 0.5 * engine.width
      tri.p1.y = tri.p1.y * 0.5 * engine.height
      tri.p2.x = tri.p2.x * 0.5 * engine.width
      tri.p2.y = tri.p2.y * 0.5 * engine.height
      tri.p3.x = tri.p3.x * 0.5 * engine.width
      tri.p3.y = tri.p3.y * 0.5 * engine.height

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
  @cube : Model
  @paused = false

  @aspect_ratio : Float64
  @fov : Float64
  @fov_rad : Float64
  @near : Float64
  @far : Float64
  @camera : Vec3d(Float64)
  @light : Vec3d(Float64) = Vec3d.new(0.0, 0.0, -1.0).normalized
  @look_direction : Vec3d(Float64)

  @mat_proj : Mat4
  @speed = 3.0

  def initialize(@width, @height, @scale)
    super(@width, @height, @scale)

    # @cube = Model.new("examples/cube.obj")
    @cube = Model.new("/Users/alex/Desktop/axis.obj")
    @cube.position.z = @cube.position.z + 20.0

    @controller = PF::Controller(LibSDL::Keycode).new({
      LibSDL::Keycode::RIGHT => "Right",
      LibSDL::Keycode::LEFT  => "Left",
      LibSDL::Keycode::UP    => "Up",
      LibSDL::Keycode::DOWN  => "Down",
      LibSDL::Keycode::SPACE => "Pause",
    })

    @near = 0.1
    @far = 1000.0
    @fov = 90.0
    @aspect_ratio = @height / @width
    @fov_rad = 1.0 / Math.tan(@fov * 0.5 / 180.0 * Math::PI)
    @camera = Vec3d.new(0.0, 0.0, 0.0)
    @look_direction = Vec3d.new(0.0, 0.0, 1.0)

    @mat_proj = Mat4.new
    @mat_proj[0, 0] = @aspect_ratio * @fov_rad
    @mat_proj[1, 1] = @fov_rad
    @mat_proj[2, 2] = @far / (@far - @near)
    @mat_proj[3, 2] = (-@far * @near) / (@far - @near)
    @mat_proj[2, 3] = 1.0
    @mat_proj[3, 3] = 0.0

    @theta = 0.0
  end

  def point_at(position : Vec3d, target : Vec3d, up : Vec3d = Vec3d.new(0.0, 1.0, 0.0))
    new_forward = (target - position).normalized
    new_up = (up - new_forward * up.dot(new_forward)).normalized
    new_right = new_up.cross_product(new_forward)

    matrix = Mat4.new
    matrix[0, 0] = new_right.x; matrix[0, 1] = new_right.y; matrix[0, 2] = new_right.z; matrix[0, 3] = 0.0
    matrix[1, 0] = new_up.x; matrix[1, 1] = new_up.y; matrix[1, 2] = new_up.z; matrix[1, 3] = 0.0
    matrix[2, 0] = new_forward.x; matrix[2, 1] = new_forward.y; matrix[2, 2] = new_forward.z; matrix[2, 3] = 0.0
    matrix[3, 0] = position.x; matrix[3, 1] = position.y; matrix[3, 2] = position.z; matrix[3, 3] = 1.0
    matrix
  end

  def update(dt)
    @paused = !@paused if @controller.pressed?("Pause")

    if @controller.action?("Right")
      @camera.x = @camera.x + @speed * dt
    end

    if @controller.action?("Left")
      @camera.x = @camera.x - @speed * dt
    end

    if @controller.action?("Up")
      @camera.y = @camera.y - @speed * dt
    end

    if @controller.action?("Down")
      @camera.y = @camera.y + @speed * dt
    end

    unless @paused
      # @cube.rotation.y = @cube.rotation.y + 1.0 * dt
    end

    @cube.update(dt)
  end

  def draw
    clear(0, 0, 100)
    @cube.draw(self, @mat_proj, @camera, @light, @look_direction)
  end
end

engine = CubeGame.new(400, 300, 2)
engine.run!
