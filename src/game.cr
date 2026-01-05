module PF
  include PF2d

  # App must implement 2 methods:
  # - #update(delta_time : Time::Span) # Game state, Physics calculations, etc.
  # - #draw(delta_time : Time::Span) # Frame rendering, and drawing
  #
  abstract class Game
    include Drawable(RGBA)

    PIXEL_FORMAT = Sdl3::PixelFormat::Rgba8888
    DEFAULT_INIT_FLAGS = Sdl3::InitFlags::Video | Sdl3::InitFlags::Audio
    DEFAULT_WINDOW_FLAGS = Sdl3::Window::Flags::None
    DEFAULT_LOGICAL_PRESENTATION = Sdl3::Renderer::LogicalPresentation::Letterbox

    getter width : Int32
    getter height : Int32
    getter scale : Float32 = 1.0
    getter started_at : Float64 = Time.monotonic.total_milliseconds
    getter last_drawn = 0.0.milliseconds
    getter last_updated = 0.0.milliseconds
    getter window : Sdl3::Window
    getter renderer : Sdl3::Renderer
    getter width : Int32
    getter height : Int32
    getter fps : Float64 = 60f64
    setter fps_limit : Float64
    getter? locked = false
    @pixels = Pointer(UInt32).null
    @keymaps = [] of Keymap

    def initialize(width : Number, height : Number, scale : Number = 1, title = self.class.name,
      init_flags : Sdl3::InitFlags = DEFAULT_INIT_FLAGS,
      window_flags : Sdl3::Window::Flags = DEFAULT_WINDOW_FLAGS,
      logical_presentation : Sdl3::Renderer::LogicalPresentation = DEFAULT_LOGICAL_PRESENTATION,
      @fps_limit = Float64::INFINITY
    )
      Sdl3.init(init_flags)
      @width = width.to_i32
      @height = height.to_i32
      @scale = scale.to_f32
      @window = Sdl3::Window.new(title, (@width * @scale).round.to_i, (@height * @scale).round.to_i, window_flags)
      @renderer = Sdl3::Renderer.new(@window)
      @renderer.scale = { @scale, @scale }
      @renderer.logical_presentation = { @width, @height, logical_presentation }
      begin
        @renderer.vsync = true
      rescue e : Sdl3::Error
        STDERR.puts e.message
      end
      @texture = Sdl3::Texture.new(@renderer, PIXEL_FORMAT, Sdl3::Texture::Access::Streaming, @width, @height)
      @texture.scale_mode = Sdl3::ScaleMode::Nearest
    end

    # User implementation requirements
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    # User method for updating game state and logic
    abstract def update(delta_time : Time::Span)

    # User method for frame rendering
    abstract def frame(delta_time : Time::Span)

    # Lifecycle
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    # This starts the application loop and runs a loop until a condition causes the app to close.
    def run!
      @started_at = Time.monotonic.total_milliseconds
      @last_drawn = @last_updated = elapsed_time
      @window.show
      @running = true
      loop do
        engine_update
        break unless @running
        engine_frame
        Fiber.yield
      end
    ensure
      on_exit
      Sdl3.quit
    end

    # Return the total milliseconds since the app started
    def elapsed_time
      (Time.monotonic.total_milliseconds - @started_at).milliseconds
    end

    # Hooks
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    def on_key_down(event : Sdl3::Event)
    end

    def on_key_repeat(event : Sdl3::Event)
    end

    def on_key_up(event : Sdl3::Event)
    end

    # Called when the mouse is moved
    # override in your subclass to hook into this behavior
    def on_mouse_motion(cursor : PF2d::Vec, event : Sdl3::Event)
    end

    # Called when the mouse is clicked
    # override in your subclass to hook into this behavior
    def on_mouse_down(cursor : Vec, event : Sdl3::Event)
    end

    def on_mouse_up(cursor : Vec, event : Sdl3::Event)
    end

    # Called for all other events
    # override in your subclass to hook into this behavior
    def on_event(event : Sdl3::Event)
    end

    # Called just before a frame is presented, but after the texture is locked
    def before_present(delta_time : Time::Span)
    end

    # Override for exit callbacks
    def on_exit
    end

    # Other
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    # Stops the run loop, and gracefully exits
    def quit!
      @running = false
    end

    def key_held?(key : Sdl3::Key)
    end

    def keymap(map : Hash(Scancode, String)) : Keymap
      Keymap.new(map).tap do |km|
        @keymaps << km
      end
    end

    def viewport
      PF2d::Vec[width, height]
    end

    # Drawing
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    # All pixel drawing must be done within this method
    def draw(& : ->)
      @texture.unsafe_lock do |pixels|
        @locked = true
        @pixels = pixels.as(Pointer(UInt32))
        yield
        @locked = false
      end
    end

    def clear(color : RGBA)
      raise "drawing must be done within the #draw block" unless locked?
      Slice(UInt32).new(@pixels.as(Pointer(UInt32)), width * height).fill(color.value)
    end

    def clear(red : UInt8 = 0u8, green : UInt8 = 0u8, blue : UInt8 = 0u8, alpha : UInt8 = 255u8)
      color = RGBA.new(red, green, blue, alpha)
      clear(color)
    end

    private def pixel_pointer(x, y)
      @pixels + y.to_i * width + x.to_i
    end

    def draw_point(x, y, value : RGBA)
      raise "drawing must be done within the #draw block" unless locked?
      return unless x >= 0 && x < width && y >= 0 && y < height

      pixel_pointer(x, y).value = value.value
    end

    def get_point(x, y)
      raise "drawing must be done within the #draw block" unless locked?
      return unless x >= 0 && x < width && y >= 0 && y < height

      pixel_pointer(x, y).value
    end

    def draw_string(string : String, x : Number, y : Number, font : Pixelfont::Font, fore = RGBA.new(255, 255, 255, 255), back : RGBA? = nil)
      font.draw(string) do |px, py, on|
        if on
          draw_point(px + x, py + y, fore)
        else
          back.try { |b| draw_point(px + x, py + y, b) }
        end
      end
    end

    # TODO: Move this to pf2d?
    # TODO: faster case for 1:1 scale
    def draw_sprite(sprite : Sprite, src_rect : PF2d::Rect(Number), dst_rect : PF2d::Rect(Number))
      sprite_pixels = Slice(UInt32).new(sprite.surface.pixels.to_unsafe.as(UInt32*), sprite.width * sprite.height)
      pixels = Slice(UInt32).new(@pixels.as(UInt32*), width * height)

      scale = dst_rect.size / src_rect.size

      0.upto(dst_rect.size.y - 1) do |y|
        sy = ((y * scale.y) + src_rect.top_left.y).to_i32
        dy = y + dst_rect.top_left.y
        next if sy >= sprite.height || dy >= height
        0.upto(dst_rect.size.x - 1) do |x|
          sx = ((x * scale.x) + src_rect.top_left.x).to_i32
          dx = x + dst_rect.top_left.x
          next if sx >= sprite.width || dx >= width
          source_color = RGBA.new(sprite_pixels[sy * sprite.width + sx])
          dest_color = RGBA.new(pixels[dy * width + dx])
          draw_point(dx, dy, source_color.blend(dest_color))
        end
      end
    end

    def draw_sprite(sprite  : Sprite, pos : PF2d::Vec = PF2d::Vec[0, 0])
      draw_sprite(sprite,
                  PF2d::Rect.new(PF2d::Vec[0,0], sprite.size),
                  PF2d::Rect.new(pos, sprite.size))
    end

    # Private
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    # :nodoc:
    private def update_fps(delta_time : Time::Span, alpha = 0.01)
      frames = 1.0.seconds / delta_time
      # Calculate the exponential moving average for FPS
      @fps = alpha * frames + (1.0 - alpha) * @fps
    end

    # :nodoc:
    private def engine_update
      engine_poll_events
      delta_time = elapsed_time - @last_updated
      update(delta_time)
      @last_updated = elapsed_time
    end

    # :nodoc:
    private def engine_frame
      delta_time = elapsed_time - @last_drawn
      return unless delta_time > (1.0.seconds / @fps_limit) # Target FPS
      @last_drawn = elapsed_time

      # TODO: move this logic to a window like object, and call window.draw to lock the texture
      draw do
        update_fps(delta_time)
        frame(delta_time)
      end
      @renderer.render_texture(@texture)
      before_present(delta_time)
      @renderer.present
    end

    # :nodoc:
    private def engine_poll_events
      event = Sdl3::Events.poll
      case event
      when Sdl3::Event::Quit
        quit!
      when Sdl3::Event::MouseMotion
        location = Vec[event.x, event.y] / scale
        on_mouse_motion(location, event)
      when Sdl3::Event::MouseButton
        dispatch_mouse_event(event)
      when Sdl3::Event::Keyboard
        dispatch_keyboard_event(event)
      else
        on_event(event)
      end
    end

    # :nodoc:
    private def dispatch_keyboard_event(event : Sdl3::Event::Keyboard)
      if event.down?
        if event.repeat?
          on_key_repeat(event)
        else
          @keymaps.each { |k| k.press(event.scancode) }
          on_key_down(event)
        end
      else
        @keymaps.each { |k| k.release(event.scancode) }
        on_key_up(event)
      end
    end

    # :nodoc:
    private def dispatch_mouse_event(event : Sdl3::Event::MouseButton)
      location = Vec[event.x, event.y] / scale
      if event.down?
        on_mouse_down(location, event)
      else
        on_mouse_up(location, event)
      end
    end
  end
end
