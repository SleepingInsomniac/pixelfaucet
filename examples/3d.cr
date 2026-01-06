require "pf3d"

require "../src/pixelfaucet"

class ThreeDee < PF::Game
  @projector : PF3d::Projector
  @camera : PF3d::Camera
  @paused = false
  @speed = 10.0
  @controls : PF::Keymap
  @depth_buffer : PF3d::DepthBuffer
  @font = Pixelfont::Font.new("#{__DIR__}/../lib/pixelfont/fonts/pixel-5x7.txt")
  @fps_string = ""
  @fps_timer = PF::Interval.new(1.0.seconds)

  def initialize(*args, **kwargs)
    super

    @projector = PF3d::Projector.new(window.width, window.height)
    @depth_buffer = PF3d::DepthBuffer.new(window.width, window.height)

    @camera = @projector.camera

    @model = PF3d::Mesh.load_obj("./assets/pixelfaucet.obj")
    @model_texture = PF::Sprite.new("./assets/bricks.png")
    @model.position.z = @model.position.z + 2.0

    @cube_model = PF3d::Mesh.load_obj("./assets/cube.obj")
    @cube_model_texture = PF::Sprite.new("./assets/bricks.png")
    @cube_model.position.z = @cube_model.position.z + 2.5

    @controls = keymap({
      PF::Scancode::Right => "Rotate Right",
      PF::Scancode::Left  => "Rotate Left",
      PF::Scancode::Up    => "Up",
      PF::Scancode::Down  => "Down",
      PF::Scancode::A     => "Left",
      PF::Scancode::D     => "Right",
      PF::Scancode::W     => "Forward",
      PF::Scancode::S     => "Backward",
      PF::Scancode::Space => "Pause",
    })
  end

  def update(delta_time)
    @fps_timer.update(delta_time) { @fps_string = "#{window.fps.round.to_i} FPS" }
    dt = delta_time.total_seconds
    @paused = !@paused if @controls.pressed?("Pause")

    forward = @camera.forward_vector
    strafe = @camera.strafe_vector

    if @controls.held?("Right")
      @camera.position = @camera.position + (strafe * @speed * dt)
    end

    if @controls.held?("Left")
      @camera.position = @camera.position - (strafe * @speed * dt)
    end

    if @controls.held?("Up")
      @camera.position.y = @camera.position.y + @speed * dt
    end

    if @controls.held?("Down")
      @camera.position.y = @camera.position.y - @speed * dt
    end

    # Control the camera pitch instead of elevation
    # TODO: this needs to account for where the camera is pointing

    # if @controls.held?("Up")
    #   @camera.pitch = @camera.pitch + (@speed / 5) * dt
    # end
    #
    # if @controls.held?("Down")
    #   @camera.pitch = @camera.pitch - (@speed / 5) * dt
    # end

    if @controls.held?("Rotate Left")
      @camera.yaw = @camera.yaw - (@speed / 3) * dt
    end

    if @controls.held?("Rotate Right")
      @camera.yaw = @camera.yaw + (@speed / 3) * dt
    end

    if @controls.held?("Forward")
      @camera.position = @camera.position + (forward * @speed * dt)
    end

    if @controls.held?("Backward")
      @camera.position = @camera.position - (forward * @speed * dt)
    end

    # @model.rotation.x = @model.rotation.x + 1.0 * dt
    @cube_model.rotation.x = @cube_model.rotation.x + 1.0 * dt
  end

  def frame(delta_time)
    window.draw do
      window.clear(25, 50, 25)

      @depth_buffer.clear
      tri_count = 0

      @projector.project(@cube_model.tris).each do |tri|
        tri_count += 1

        window.paint_triangle(
          tri.p1.to_i, tri.p2.to_i, tri.p3.to_i, # Points
          tri.t1, tri.t2, tri.t3,                # Texture Points
          @cube_model_texture,
          @depth_buffer,
          PF::Colors::White * tri.shade
        )
      end

      @projector.project(@model.tris).each do |tri|
        tri_count += 1

        window.paint_triangle(
          tri.p1.to_i, tri.p2.to_i, tri.p3.to_i, # Points
          tri.t1, tri.t2, tri.t3,                # Texture Points
          nil,
          @depth_buffer,
          PF::Colors::White * tri.shade
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
        io << "\n" << @fps_string
      end

      window.draw_string(string, 3, 3, @font, PF::Colors::White)
    end
  end
end

# engine = ThreeDee.new(256, 240, 4)
engine = ThreeDee.new(256 * 2, 240 * 2, 2)
engine.run!
