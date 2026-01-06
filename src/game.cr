require "./window"

module PF
  alias Event = Sdl3::Event
  include PF2d

  # App must implement 2 methods:
  # - #update(delta_time : Time::Span) # Game state, Physics calculations, etc.
  # - #frame(delta_time : Time::Span) # Frame rendering, and drawing
  #
  abstract class Game
    PIXEL_FORMAT = Sdl3::PixelFormat::Rgba8888
    DEFAULT_INIT_FLAGS = Sdl3::InitFlags::Video | Sdl3::InitFlags::Audio
    DEFAULT_WINDOW_FLAGS = Sdl3::Window::Flags::None
    DEFAULT_LOGICAL_PRESENTATION = Sdl3::Renderer::LogicalPresentation::Letterbox
    DEFAULT_FPS_LIMIT = Float64::INFINITY
    DEFAULT_SCALE_MODE = Sdl3::ScaleMode::Nearest

    getter started_at : Float64 = Time.monotonic.total_milliseconds
    getter last_updated = 0.0.milliseconds
    getter window : Window
    @keymaps = [] of Keymap

    def initialize(width : Number, height : Number, scale : Number = 1, title = self.class.name,
      init_flags : Sdl3::InitFlags = DEFAULT_INIT_FLAGS,
      window_flags : Sdl3::Window::Flags = DEFAULT_WINDOW_FLAGS,
      logical_presentation : Sdl3::Renderer::LogicalPresentation = DEFAULT_LOGICAL_PRESENTATION,
      @fps_limit = DEFAULT_FPS_LIMIT
    )
      Sdl3.init(init_flags)
      @window = Window.new(width, height, scale, title, window_flags, logical_presentation, fps_limit)
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
      @window.open
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

    def on_window_event(event : Sdl3::Event::Window)
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

    def keymap(map : Hash(Scancode, String)) : Keymap
      Keymap.new(map).tap do |km|
        @keymaps << km
      end
    end

    def keymap(map : Keymap)
      map.tap { @keymaps << map }
    end

    def viewport
      PF2d::Vec[width, height]
    end

    # Private
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    # :nodoc:
    private def engine_update
      engine_poll_events
      delta_time = elapsed_time - @last_updated
      @last_updated = elapsed_time
      update(delta_time)
    end

    # :nodoc:
    private def engine_frame
      @window.frame do |delta_time|
        frame(delta_time)
      end
    end

    # :nodoc:
    private def engine_poll_events
      event = Sdl3::Events.poll
      case event
      when Sdl3::Event::Quit
        quit!
      when Sdl3::Event::Window
        on_window_event(event)
      when Sdl3::Event::MouseMotion
        location = Vec[event.x, event.y] / @window.scale
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
      location = Vec[event.x, event.y] / @window.scale
      if event.down?
        on_mouse_down(location, event)
      else
        on_mouse_up(location, event)
      end
    end
  end
end
