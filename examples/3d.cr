require "pf3d"

require "../src/game"
require "../src/controller"
require "../src/sprite"
require "../src/pixel"
require "../src/sprite"

class ThreeDee < PF::Game
  @projector : PF3d::Projector
  @camera : PF3d::Camera
  @paused = false
  @speed = 10.0
  @controller : PF::Controller(PF::Keys)
  @depth_buffer : PF3d::DepthBuffer
  @font = Pixelfont::Font.new("#{__DIR__}/../lib/pixelfont/fonts/pixel-5x7.txt")

  def initialize(*args, **kwargs)
    super

    @projector = PF3d::Projector.new(width, height)
    @depth_buffer = PF3d::DepthBuffer.new(width, height)

    @camera = @projector.camera

    @model = PF3d::Mesh.load_obj("./assets/pixelfaucet.obj")
    @model_texture = PF::Sprite.new("./assets/bricks.png")
    @model.position.z = @model.position.z + 2.0

    @cube_model = PF3d::Mesh.load_obj("./assets/cube.obj")
    @cube_model_texture = PF::Sprite.new("./assets/bricks.png")
    @cube_model.position.z = @cube_model.position.z + 2.5

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

    plug_in @controller
  end

  def update(dt)
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

    # Control the camera pitch instead of elevation
    # TODO: this needs to account for where the camera is pointing

    # if @controller.held?("Up")
    #   @camera.pitch = @camera.pitch + (@speed / 5) * dt
    # end
    #
    # if @controller.held?("Down")
    #   @camera.pitch = @camera.pitch - (@speed / 5) * dt
    # end

    if @controller.held?("Rotate Left")
      @camera.yaw = @camera.yaw - (@speed / 3) * dt
    end

    if @controller.held?("Rotate Right")
      @camera.yaw = @camera.yaw + (@speed / 3) * dt
    end

    if @controller.held?("Forward")
      @camera.position = @camera.position + (forward * @speed * dt)
    end

    if @controller.held?("Backward")
      @camera.position = @camera.position - (forward * @speed * dt)
    end

    # @model.rotation.x = @model.rotation.x + 1.0 * dt
    @cube_model.rotation.x = @cube_model.rotation.x + 1.0 * dt
  end

  def draw
    clear(25, 50, 25)
    # clear

    @depth_buffer.clear
    tri_count = 0

    @projector.project(@cube_model.tris).each do |tri|
      tri_count += 1

      paint_triangle(
        tri.p1.to_i, tri.p2.to_i, tri.p3.to_i, # Points
        tri.t1, tri.t2, tri.t3,                # Texture Points
        @cube_model_texture,
        @depth_buffer,
        PF::Pixel::White * tri.shade
      )
    end

    @projector.project(@model.tris).each do |tri|
      tri_count += 1

      paint_triangle(
        tri.p1.to_i, tri.p2.to_i, tri.p3.to_i, # Points
        tri.t1, tri.t2, tri.t3,                # Texture Points
        nil,
        @depth_buffer,
        PF::Pixel::White * tri.shade
      )
    end

    string = String.build do |io|
      io << "Triangles: " << tri_count
      io << "\nPosition: "
      io << "x: " << @camera.position.x.round(2)
      io << "y: " << @camera.position.y.round(2)
      io << "z: " << @camera.position.z.round(2)
      io << "\nRotation: "
      io << "x: " << @camera.rotation.x.round(2)
      io << "y: " << @camera.rotation.y.round(2)
      io << "z: " << @camera.rotation.z.round(2)
    end

    draw_string(string, 3, 3, @font, PF::Pixel::White)
  end
end

# engine = ThreeDee.new(256, 240, 4)
engine = ThreeDee.new(256 * 2, 240 * 2, 2)
engine.run!
