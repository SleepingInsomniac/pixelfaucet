module PF
  alias Event = Sdl3::Event
  include PF2d

  # App must implement 2 methods:
  # - #update(delta_time : Time::Span) # Game state, Physics calculations, etc.
  # - #frame(delta_time : Time::Span) # Frame rendering, and drawing
  #
  abstract class Game
    include Canvas(RGBA)
    include Drawable
    include BirthTime

    PIXEL_FORMAT = Sdl3::PixelFormat::Rgba8888
    DEFAULT_INIT_FLAGS = Sdl3::InitFlags::Video | Sdl3::InitFlags::Audio
    DEFAULT_WINDOW_FLAGS = Sdl3::Window::Flags::None
    DEFAULT_LOGICAL_PRESENTATION = Sdl3::Renderer::LogicalPresentation::Letterbox
    DEFAULT_FPS_LIMIT = Float64::INFINITY
    DEFAULT_SCALE_MODE = Sdl3::ScaleMode::Nearest

    getter last_updated = 0.0.milliseconds
    getter window : Window
    getter keys : Keyboard = Keyboard.instance
    # TODO: Remove when keymaps are removed
    @keymaps = [] of Keymap

    def initialize(width : Number, height : Number, scale : Number = 1, title = self.class.name,
      init_flags : Sdl3::InitFlags = DEFAULT_INIT_FLAGS,
      window_flags : Sdl3::Window::Flags = DEFAULT_WINDOW_FLAGS,
      logical_presentation : Sdl3::Renderer::LogicalPresentation = DEFAULT_LOGICAL_PRESENTATION,
      @fps_limit = DEFAULT_FPS_LIMIT
    )
      Sdl3.init(init_flags)
      @window = Window.new(width, height, scale, title, window_flags, logical_presentation, fps_limit)
      after_initialize
    end

    delegate lock, width, height, clear, to: @window

    def draw_point(x, y, value : RGBA)
      window.draw_point(x, y, value)
    end

    def get_point?(x, y) : RGBA?
      window.get_point?(x, y)
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
      reset_birthtime
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

    # Hooks
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    def after_initialize
    end

    # Called when a key is pressed. Use `keys[ScanCode].pressed?` to check keys.
    def on_key_down(event : PF::Event)
    end

    # Called when a key is repeated. Use `keys[ScanCode].repeat?` to check keys.
    def on_key_repeat(event : PF::Event)
    end

    # Called when a key is pressed. Use `keys[ScanCode].released?` to check keys.
    def on_key_up(event : PF::Event)
    end

    # Called when the mouse is moved
    # *direction* is the delta vector in position.
    def on_mouse_motion(direction : PF2d::Vec, event : PF::Event)
    end

    # *direction* is the delta vector in position.
    def on_mouse_wheel(direction : PF2d::Vec, inverted : Bool, window_id, event : PF::Event)
    end

    # Called when the mouse is clicked
    # override in your subclass to hook into this behavior
    def on_mouse_down(event : PF::Event)
    end

    # Called when the mouse button is released
    def on_mouse_up(event : PF::Event)
    end

    # Called for all other events
    # override in your subclass to hook into this behavior
    def on_event(event : PF::Event)
    end

    def on_window_event(event : PF::Event::Window)
    end

    # Called just before a frame is presented, but after the window texture is locked
    def before_present(delta_time : Time::Span)
    end

    # Override for exit callbacks
    def on_exit
    end

    # Other
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    @[Deprecated("Prefer PF::Game#keys.map(). #keymap will be removed")]
    def keymap(map : Hash(Scancode, String)) : Keymap
      Keymap.new(map).tap do |km|
        @keymaps << km
      end
    end

    @[Deprecated("Prefer PF::Game#keys.map(). #keymap will be removed")]
    def keymap(map : Keymap)
      map.tap { @keymaps << map }
    end

    # Returns the width and height as a Vec
    def viewport
      Vec[width, height]
    end

    # Stops the run loop, and gracefully exits
    def quit!
      @running = false
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
      while event = Sdl3::Events.poll
        case event
        when Sdl3::Event::Quit
          quit!
        when Sdl3::Event::Window
          on_window_event(event)
        when Sdl3::Event::MouseMotion
          engine_update_mouse
          relative_pos = Vec[event.xrel, event.yrel] / @window.scale
          on_mouse_motion(relative_pos, event)
        when Sdl3::Event::MouseWheel
          direction = Vec[event.x, event.y].to_f64
          inverted = event.direction == Sdl3::Mouse::WheelDirection::Flipped
          window_id = event.window_id
          on_mouse_wheel(direction, inverted, window_id, event)
        when Sdl3::Event::MouseButton
          engine_update_mouse
          dispatch_mouse_event(event)
        when Sdl3::Event::Keyboard
          Keyboard.instance.register(event)
          dispatch_keyboard_event(event)
        else
          on_event(event)
        end
      end
    end

    private def engine_update_mouse
      state = Sdl3::Mouse.state
      cursor = Vec[state[:x], state[:y]] / @window.scale
      Mouse.instance.update_state(cursor.to_f64, state[:button_flags])
    end

    # :nodoc:
    private def dispatch_keyboard_event(event : Sdl3::Event::Keyboard)
      if event.down?
        if event.repeat?
          on_key_repeat(event)
        else
          # TODO Remove when #keymap is removed
          @keymaps.each { |k| k.press(event.scancode) }
          on_key_down(event)
        end
      else
        # TODO Remove when #keymap is removed
        @keymaps.each { |k| k.release(event.scancode) }
        on_key_up(event)
      end
    end

    # :nodoc:
    private def dispatch_mouse_event(event : Sdl3::Event::MouseButton)
      if event.down?
        on_mouse_down(event)
      else
        on_mouse_up(event)
      end
    end
  end
end
