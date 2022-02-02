require "../src/game"
require "../src/controller"
require "../src/sprite"
require "../src/pixel"
require "../src/pixel_text"
require "../src/vector"

require "../src/3d/*"

class ThreeDee < PF::Game
  @projector : PF::Projector
  @camera : PF::Camera
  @paused = false
  @speed = 5.0
  @text = PF::PixelText.new("./assets/pf-font.png")
  @controller : PF::Controller(PF::Keys)

  def initialize(*args, **kwargs)
    super

    @projector = PF::Projector.new(@width, @height)
    @camera = @projector.camera
    @model = PF::Mesh.load_obj("./assets/pixelfaucet.obj")
    @model.position.z = @model.position.z + 2.0

    @controller = PF::Controller(PF::Keys).new({
      PF::Keys::RIGHT => "Rotate Right",
      PF::Keys::LEFT  => "Rotate Left",
      PF::Keys::UP    => "Up",
      PF::Keys::DOWN  => "Down",
      PF::Keys::A     => "Left",
      PF::Keys::D     => "Right",
      PF::Keys::W     => "Forward",
      PF::Keys::S     => "Backward",
      PF::Keys::SPACE => "Pause",
    })
  end

  def update(dt, event)
    case event
    when SDL::Event::Keyboard
      @controller.press(event.scancode) if event.keydown?
      @controller.release(event.scancode) if event.keyup?
    end

    @paused = !@paused if @controller.pressed?("Pause")

    forward = @camera.forward_vector
    strafe = @camera.strafe_vector

    if @controller.held?("Right")
      @camera.position = @camera.position + (strafe * @speed * dt)
    end

    if @controller.held?("Left")
      @camera.position = @camera.position - (strafe * @speed * dt)
    end

    if @controller.held?("Up")
      @camera.position.y = @camera.position.y + @speed * dt
    end

    if @controller.held?("Down")
      @camera.position.y = @camera.position.y - @speed * dt
    end

    # Controll the camera pitch instead of aft -

    # if @controller.held?("Up")
    #   @camera.pitch = @camera.pitch + (@speed / 2) * dt
    # end

    # if @controller.held?("Down")
    #   @camera.pitch = @camera.pitch - (@speed / 2) * dt
    # end

    if @controller.held?("Rotate Left")
      @camera.yaw = @camera.yaw - (@speed / 2) * dt
    end

    if @controller.held?("Rotate Right")
      @camera.yaw = @camera.yaw + (@speed / 2) * dt
    end

    if @controller.held?("Forward")
      @camera.position = @camera.position + (forward * @speed * dt)
    end

    if @controller.held?("Backward")
      @camera.position = @camera.position - (forward * @speed * dt)
    end

    @model.rotation.x = @model.rotation.x + 3.0 * dt
  end

  def draw
    clear(25, 50, 25)
    tris = @projector.project(@model.tris)
    @text.draw_to(screen, "Triangles: #{tris.size}")

    tris.each do |tri|
      # Rasterize all triangles
      fill_triangle(
        PF::Vector[tri.p1.x.to_i, tri.p1.y.to_i],
        PF::Vector[tri.p2.x.to_i, tri.p2.y.to_i],
        PF::Vector[tri.p3.x.to_i, tri.p3.y.to_i],
        pixel: tri.color
      )

      # draw_triangle(
      #   PF::Vector[tri.p1.x.to_i, tri.p1.y.to_i],
      #   PF::Vector[tri.p2.x.to_i, tri.p2.y.to_i],
      #   PF::Vector[tri.p3.x.to_i, tri.p3.y.to_i],
      #   pixel: PF::Pixel.blue
      # )
    end
  end
end

# engine = ThreeDee.new(256, 240, 4)
engine = ThreeDee.new(640, 480, 2)
engine.run!
