require "../src/game"
require "../src/controller"
require "../src/sprite"
require "../src/sprite/vector_sprite"
require "../src/pixel"
require "../src/point"
require "../src/pixel_text"

require "../src/3d/*"

class ThreeDee < PF::Game
  @projector : PF::Projector
  @camera : PF::Camera
  @paused = false
  @speed = 5.0
  @text = PF::PixelText.new("./assets/pf-font.png")

  def initialize(*args, **kwargs)
    super

    @projector = PF::Projector.new(@width, @height)
    @camera = @projector.camera
    @model = PF::Mesh.load_obj("./assets/pixelfaucet.obj")
    @model.position.z = @model.position.z + 2.0

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
      @camera.position = @camera.position + (strafe * @speed * dt)
    end

    if @controller.action?("Left")
      @camera.position = @camera.position - (strafe * @speed * dt)
    end

    if @controller.action?("Up")
      @camera.position.y = @camera.position.y + @speed * dt
    end

    if @controller.action?("Down")
      @camera.position.y = @camera.position.y - @speed * dt
    end

    # Controll the camera pitch instead of aft -

    # if @controller.action?("Up")
    #   @camera.pitch = @camera.pitch + (@speed / 2) * dt
    # end

    # if @controller.action?("Down")
    #   @camera.pitch = @camera.pitch - (@speed / 2) * dt
    # end

    if @controller.action?("Rotate Left")
      @camera.yaw = @camera.yaw - (@speed / 2) * dt
    end

    if @controller.action?("Rotate Right")
      @camera.yaw = @camera.yaw + (@speed / 2) * dt
    end

    if @controller.action?("Forward")
      @camera.position = @camera.position + (forward * @speed * dt)
    end

    if @controller.action?("Backward")
      @camera.position = @camera.position - (forward * @speed * dt)
    end

    @model.rotation.x = @model.rotation.x + 3.0 * dt
  end

  def draw
    clear(25, 50, 25)
    tris = @projector.project(@model.tris)
    @text.draw(@screen, "Triangles: #{tris.size}")

    tris.each do |tri|
      # Rasterize all triangles
      fill_triangle(
        PF::Point.new(tri.p1.x.to_i, tri.p1.y.to_i),
        PF::Point.new(tri.p2.x.to_i, tri.p2.y.to_i),
        PF::Point.new(tri.p3.x.to_i, tri.p3.y.to_i),
        pixel: tri.color
      )

      # engine.draw_triangle(
      #   PF::Point.new(tri.p1.x.to_i, tri.p1.y.to_i),
      #   PF::Point.new(tri.p2.x.to_i, tri.p2.y.to_i),
      #   PF::Point.new(tri.p3.x.to_i, tri.p3.y.to_i),
      #   pixel: PF::Pixel.blue
      # )
    end
  end
end

engine = ThreeDee.new(320, 200, 4)
engine.run!
