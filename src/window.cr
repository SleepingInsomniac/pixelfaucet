module PF
  module Windows
    @@windows = {} of Sdl3::Window::ID => Window

    def self.all
      @@windows
    end

    def self.[]?(id : Sdl3::Window::ID)
      @@windows[id]?
    end

    def self.[]=(id : Sdl3::Window::ID, window : Window)
      @@windows[id] = window
    end

    def self.delete(id)
      @@windows.delete(id)
    end
  end

  class Window
    include PF2d
    include PF2d::Canvas(RGBA)
    include PF::Drawable

    @sdl_window : Sdl3::Window
    getter width : Int32
    getter height : Int32
    getter scale : Float32 = 1.0
    @renderer : Sdl3::Renderer
    @texture : Sdl3::Texture
    getter? closed : Bool = false
    @window_flags : Sdl3::Window::Flags = Game::DEFAULT_WINDOW_FLAGS
    @logical_presentation : Sdl3::Renderer::LogicalPresentation = Game::DEFAULT_LOGICAL_PRESENTATION

    # Only use pixels when locked
    getter? locked = false
    @pixels = Pointer(UInt32).null
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~

    property started_at : Float64 = Time.monotonic.total_milliseconds
    getter fps : Float64 = 60f64
    property fps_limit : Float64
    getter last_drawn = 0.0.milliseconds

    delegate ::show, to: @sdl_window

    def initialize(width : Number, height : Number, scale : Number = 1.0, @title = "New Window",
      @window_flags : Sdl3::Window::Flags = Game::DEFAULT_WINDOW_FLAGS,
      @logical_presentation : Sdl3::Renderer::LogicalPresentation = Game::DEFAULT_LOGICAL_PRESENTATION,
      @fps_limit = Float64::INFINITY
    )
      @width, @height, @scale = width.to_i32, height.to_i32, scale.to_f32
      @started_at = Time.monotonic.total_milliseconds
      @last_drawn = elapsed_time
      @sdl_window = Sdl3::Window.new(@title, (width * @scale).round.to_i, (height * @scale).round.to_i, @window_flags)

      @renderer = Sdl3::Renderer.new(@sdl_window)
      @renderer.logical_presentation = { @width, @height, @logical_presentation }
      @renderer.scale = { @scale, @scale }
      begin
        @renderer.vsync = true
      rescue e : Sdl3::Error
        STDERR.puts e.message
      end

      @texture = Sdl3::Texture.new(@renderer, Game::PIXEL_FORMAT, Sdl3::Texture::Access::Streaming, @width, @height)
      @texture.scale_mode = Game::DEFAULT_SCALE_MODE
      Windows[@sdl_window.id] = self
    end

    def id
      closed? ? nil : @sdl_window.id
    end

    def title
      @title
    end

    def title=(value)
      @title = value
      unless closed?
        @sdl_window.title = value
      end
    end

    def scale=(value)
      @scale = value
      @renderer.scale = { @scale, @scale }
    end

    def elapsed_time
      (Time.monotonic.total_milliseconds - @started_at).milliseconds
    end

    # Lifecycle ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    # Override
    def before_present(delta_time)
    end

    def open
      return false unless closed?
      @closed = false

      @started_at = Time.monotonic.total_milliseconds
      @last_drawn = elapsed_time
      @sdl_window = Sdl3::Window.new(@title, (width * @scale).round.to_i, (height * @scale).round.to_i, @window_flags)

      @renderer = Sdl3::Renderer.new(@sdl_window)
      @renderer.logical_presentation = { @width, @height, @logical_presentation }
      @renderer.scale = { @scale, @scale }
      begin
        @renderer.vsync = true
      rescue e : Sdl3::Error
        STDERR.puts e.message
      end

      @texture = Sdl3::Texture.new(@renderer, Game::PIXEL_FORMAT, Sdl3::Texture::Access::Streaming, @width, @height)
      @texture.scale_mode = Game::DEFAULT_SCALE_MODE
      Windows[@sdl_window.id] = self
    end

    def close
      return false if closed?

      Windows.delete(@sdl_window.id)
      @closed = true
      @texture.sdl_finalize
      @renderer.sdl_finalize
      @sdl_window.sdl_finalize
    end

    # Drawing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    # All pixel drawing must be done within this method
    def draw(&block : ->)
      lock(&block)
    end

    # All pixel drawing must be done within this method
    def lock(& : ->)
      return false if closed?
      @texture.unsafe_lock do |pixels|
        @locked = true
        @pixels = pixels.as(Pointer(UInt32))
        yield
        @locked = false
      end
    end

    private def pixel_pointer(x, y)
      @pixels + y.to_i * width + x.to_i
    end

    # PF2d::Drawable(RGBA)
    def draw_point(x, y, value : RGBA)
      raise "drawing must be done within the #lock block" unless locked?
      return unless in_bounds?(x, y)

      pixel_pointer(x, y).value = value.value
    end

    # PF2d::Viewable(RGBA)
    def get_point?(x, y) : RGBA?
      raise "#get_point may only be called within the #lock block" unless locked?
      return nil unless in_bounds?(x, y)

      RGBA.new(pixel_pointer(x, y).value)
    end

    # ~~~~

    def clear(color : RGBA)
      raise "drawing must be done within the #draw block" unless locked?
      Slice(UInt32).new(@pixels.as(Pointer(UInt32)), width * height).fill(color.value)
    end

    def clear(red : UInt8 = 0u8, green : UInt8 = 0u8, blue : UInt8 = 0u8, alpha : UInt8 = 255u8)
      color = RGBA.new(red, green, blue, alpha)
      clear(color)
    end

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    # :nodoc:
    private def update_fps(delta_time : Time::Span, alpha = 0.01)
      frames = 1.0.seconds / delta_time
      # Calculate the exponential moving average for FPS
      @fps = alpha * frames + (1.0 - alpha) * @fps
    end

    def frame
      delta_time = elapsed_time - @last_drawn
      return unless delta_time >= (1.0.seconds / @fps_limit) # Target FPS
      @last_drawn = elapsed_time

      update_fps(delta_time)
      yield(delta_time)

      @renderer.render_texture(@texture)
      before_present(delta_time)
      @renderer.present
    end
  end
end
