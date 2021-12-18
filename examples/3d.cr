require "../src/game"
require "../src/controller"
require "../src/sprite"
require "../src/sprite/vector_sprite"
require "../src/pixel"
require "../src/point"

require "../src/3d/*"

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
    up = Vec3d.new(0.0, 1.0, 0.0)
    target = camera + look_direction

    mat_camera = engine.point_at(camera, target, up)
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

    clipping_plane_near = Vec3d.new(0.0, 0.0, 0.1)
    near_plane_normal = Vec3d.new(0.0, 0.0, 1.0)

    0.upto(tris.size - 1) do
      tri = tris.pop
      shade : UInt8 = (tri.normal.dot(light.normalized) * 255.0).clamp(0.0..255.0).to_u8
      tri.color = PF::Pixel.new(shade, shade, shade, 255)

      tri.p1 *= mat_view
      tri.p2 *= mat_view
      tri.p3 *= mat_view

      tri.clip(plane: clipping_plane_near, plane_normal: near_plane_normal).each do |tri|
        tri.p1 *= mat_proj
        tri.p2 *= mat_proj
        tri.p3 *= mat_proj

        tri.p1.x = tri.p1.x * -1.0
        tri.p2.x = tri.p2.x * -1.0
        tri.p3.x = tri.p3.x * -1.0

        tri.p1.y = tri.p1.y * -1.0
        tri.p2.y = tri.p2.y * -1.0
        tri.p3.y = tri.p3.y * -1.0

        tri.p1 += 1.0
        tri.p2 += 1.0
        tri.p3 += 1.0

        tri.p1.x = tri.p1.x * 0.5 * engine.width
        tri.p1.y = tri.p1.y * 0.5 * engine.height
        tri.p2.x = tri.p2.x * 0.5 * engine.width
        tri.p2.y = tri.p2.y * 0.5 * engine.height
        tri.p3.x = tri.p3.x * 0.5 * engine.width
        tri.p3.y = tri.p3.y * 0.5 * engine.height

        tris.unshift(tri)
      end
    end

    # Clip against the edges of the screen
    {
      {Vec3d.new(0.0, 0.0, 0.0), Vec3d.new(0.0, 1.0, 0.0)},
      {Vec3d.new(0.0, engine.height - 1.0, 0.0), Vec3d.new(0.0, -1.0, 0.0)},
      {Vec3d.new(0.0, 0.0, 0.0), Vec3d.new(1.0, 0.0, 0.0)},
      {Vec3d.new(engine.width - 1.0, 0.0, 0.0), Vec3d.new(-1.0, 0.0, 0.0)},
    }.each do |clip|
      0.upto(tris.size - 1) do
        tri = tris.pop
        tri.clip(plane: clip[0], plane_normal: clip[1]).each do |tri|
          tris.unshift(tri)
        end
      end
    end

    # Rasterize all triangles
    tris.each do |tri|
      engine.fill_triangle(
        PF::Point.new(tri.p1.x.to_i, tri.p1.y.to_i),
        PF::Point.new(tri.p2.x.to_i, tri.p2.y.to_i),
        PF::Point.new(tri.p3.x.to_i, tri.p3.y.to_i),
        pixel: tri.color
      )

      engine.draw_triangle(
        PF::Point.new(tri.p1.x.to_i, tri.p1.y.to_i),
        PF::Point.new(tri.p2.x.to_i, tri.p2.y.to_i),
        PF::Point.new(tri.p3.x.to_i, tri.p3.y.to_i),
        pixel: PF::Pixel.green
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

  @yaw : Float64 = 0.0

  @mat_proj : Mat4
  @speed = 5.0
  @mat_cam_rotation : Mat4 = Mat4.new

  def initialize(@width, @height, @scale)
    super(@width, @height, @scale)

    @cube = Model.new("examples/cube.obj")
    @cube.position.z = @cube.position.z + 3.0

    @controller = PF::Controller(LibSDL::Keycode).new({
      LibSDL::Keycode::RIGHT => "Rotate Right",
      LibSDL::Keycode::LEFT  => "Rotate Left",
      LibSDL::Keycode::UP    => "Up",
      LibSDL::Keycode::DOWN  => "Down",
      LibSDL::Keycode::A     => "Left",
      LibSDL::Keycode::E     => "Right",
      LibSDL::Keycode::COMMA => "Forward",
      LibSDL::Keycode::O     => "Backward",
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

    @mat_cam_rotation.set({
      {Math.cos(@yaw), 0.0, Math.sin(@yaw), 0.0},
      {0.0, 1.0, 0.0, 0.0},
      {-Math.sin(@yaw), 0.0, Math.cos(@yaw), 0.0},
      {0.0, 0.0, 0.0, 1.0},
    })

    target = Vec3d.new(0.0, 0.0, 1.0)
    @look_direction = target * @mat_cam_rotation
    strafe = Vec3d.new(1.0, 0.0, 0.0) * @mat_cam_rotation

    if @controller.action?("Right")
      @camera = @camera - (strafe * @speed * dt)
    end

    if @controller.action?("Left")
      @camera = @camera + (strafe * @speed * dt)
    end

    if @controller.action?("Up")
      @camera.y = @camera.y + @speed * dt
    end

    if @controller.action?("Down")
      @camera.y = @camera.y - @speed * dt
    end

    if @controller.action?("Rotate Left")
      @yaw -= (@speed / 2) * dt
    end

    if @controller.action?("Rotate Right")
      @yaw += (@speed / 2) * dt
    end

    if @controller.action?("Forward")
      @camera = @camera + (@look_direction * @speed * dt)
    end

    if @controller.action?("Backward")
      @camera = @camera - (@look_direction * @speed * dt)
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

engine = CubeGame.new(800, 600, 1)
engine.run!
