require "../src/game"
require "../src/controller"
require "../src/sprite"
require "../src/sprite/vector_sprite"
require "../src/pixel"
require "../src/point"

require "../src/3d/*"

class Model
  property mesh : PF::Mesh
  property position = PF::Vec3d(Float64).new(0.0, 0.0, 0.0)
  property rotation = PF::Vec3d(Float64).new(0.0, 0.0, 0.0)

  def initialize(obj_path : String)
    @mesh = PF::Mesh.load_obj(obj_path)
  end

  def update(dt : Float64)
    @rotation.x += 0.33 * dt
    @rotation.y += 0.66 * dt
  end

  def draw(engine : PF::Game, projector : PF::Projector)
    projector.project(@mesh.tris, rotation: @rotation, position: @position).each do |tri|
      # Rasterize all triangles
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
  @projector : PF::Projector
  @paused = false
  @light : PF::Vec3d(Float64) = PF::Vec3d.new(0.0, 0.0, -1.0).normalized
  @speed = 5.0
  @camera : PF::Camera

  def initialize(@width, @height, @scale)
    super(@width, @height, @scale)

    @projector = PF::Projector.new(@width, @height)
    @camera = @projector.camera
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
  end

  def update(dt)
    @paused = !@paused if @controller.pressed?("Pause")

    forward = @camera.forward_vector
    strafe = @camera.strafe_vector

    if @controller.action?("Right")
      @camera.position = @camera.position - (strafe * @speed * dt)
    end

    if @controller.action?("Left")
      @camera.position = @camera.position + (strafe * @speed * dt)
    end

    if @controller.action?("Up")
      @camera.position.y = @camera.position.y + @speed * dt
    end

    if @controller.action?("Down")
      @camera.position.y = @camera.position.y - @speed * dt
    end

    if @controller.action?("Rotate Left")
      @camera.yaw = @camera.yaw + (@speed / 2) * dt
    end

    if @controller.action?("Rotate Right")
      @camera.yaw = @camera.yaw - (@speed / 2) * dt
    end

    if @controller.action?("Forward")
      @camera.position = @camera.position + (forward * @speed * dt)
    end

    if @controller.action?("Backward")
      @camera.position = @camera.position - (forward * @speed * dt)
    end

    @cube.update(dt)
  end

  def draw
    clear(0, 0, 100)
    @cube.draw(self, @projector)
  end
end

engine = CubeGame.new(400, 300, 2)
engine.run!
