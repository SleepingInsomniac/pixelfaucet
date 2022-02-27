require "./lib_sdl"
require "./flags"
require "./fps"
require "./pixel"
require "./sprite"
require "./controller"

module PF
  alias Event = SDL::Event

  abstract class Game
    SHOW_FPS = true

    property title : String
    property viewport : Vector2(Int32) = Vector[0, 0]
    getter scale : Vector2(Int32) = Vector[1, 1]
    getter window : SDL::Window
    getter renderer : SDL::Renderer

    property running = true
    property screen : Sprite
    property controllers = [] of PF::Controller(Keys)

    delegate :draw_point, :draw_line, :draw_curve, :scan_line, :draw_circle, :draw_triangle, :draw_rect, :draw_shape,
      :fill_triangle, :fill_rect, :fill_circle, :fill_shape, :draw_string, to: @screen

    @milliseconds : Float64 = Time.monotonic.total_milliseconds
    @last_ms : Float64 = Time.monotonic.total_milliseconds
    @engine_started_at : Float64 = Time.monotonic.total_milliseconds
    getter frame_seconds : Float64 = 0.0

    @fps : Fps

    def initialize(
      width : Int32, height : Int32, scale : Int32 = 1, @title : String = self.class.name,
      render_flags = Flags::Render::ACCELERATED, window_flags = Flags::Window::SHOWN
    )
      SDL.init(SDL::Init::EVERYTHING)
      @scale = Vector[scale, scale]
      @viewport = Vector[width, height]
      winsize = @viewport * @scale
      @window = SDL::Window.new(@title, winsize.x, winsize.y, flags: window_flags)
      @renderer = SDL::Renderer.new(@window, flags: render_flags)
      @renderer.scale = {@scale.x, @scale.y}
      @screen = Sprite.new(@viewport.x, @viewport.y)

      @fps = Fps.new do |frame_rate|
        @window.title = String.build { |io| io << @title << " - " << frame_rate << " fps" }
      end
    end

    abstract def update(dt : Float64)
    abstract def draw

    # Returns the width of the window and render area
    def width
      @viewport.x
    end

    # Returns the height of the window and render area
    def height
      @viewport.y
    end

    # Register a controller to be aware of Events
    #
    # ```
    # @controller = PF::Controller.new({
    #   PF::Keys::RIGHT => "Move Right",
    #   PF::Keys::LEFT  => "Move Left",
    # })
    # plug_in @controller
    # ```
    def plug_in(controller : Controller)
      @controllers << controller
    end

    def total_milliseconds
      Time.monotonic.total_milliseconds
    end

    # Get the time (in milliseconds) since the engine started
    def elapsed_milliseconds
      total_milliseconds - @engine_started_at
    end

    # Get the time (in seconds) since the engine started
    def elapsed_seconds
      elapsed_milliseconds / 1000
    end

    # Clear the screen to black, or optionally an RGB color
    def clear(r = 0, g = 0, b = 0)
      @screen.fill(r, g, b)
    end

    # Returns the time taken in seconds since the last frame
    def frame_seconds
      @frame_seconds
    end

    # Start the Game loop
    def run!
      @engine_started_at = total_milliseconds

      loop do
        engine_update
        engine_draw
        break unless @running
      end
    ensure
      on_exit
      SDL.quit
    end

    # Stop the game loop
    def quit!
      @running = false
    end

    def on_event(event : Event)
    end

    # Called when the mouse is moved
    # override in your subclass to hook into this behavior
    def on_mouse_motion(cursor : Vector2(Int32))
    end

    # Called when the mouse is clicked
    # override in your subclass to hook into this behavior
    def on_mouse_button(event : Event)
    end

    # Called when the controller has input
    # override in your subclass to hook into this behavior
    def on_controller_input(dt : Float64)
    end

    # This method is called when the game loop has terminated
    # override in your subclass to hook into this behavior
    def on_exit
    end

    private def engine_update
      _milliseconds = total_milliseconds
      {% if SHOW_FPS %}
        @fps.update(_milliseconds)
      {% end %}
      @frame_seconds = (_milliseconds - @last_ms) / 1000.0
      @last_ms = _milliseconds

      while event = Event.poll
        case event
        when Event::MouseMotion
          on_mouse_motion(Vector[event.x, event.y] // scale)
        when Event::MouseButton
          on_mouse_button(event)
        when Event::Keyboard
          # keys_array = LibSDL.get_keyboard_state(out len)
          @controllers.each(&.map_event(event))
          on_controller_input(@frame_seconds)
        when Event::Quit
          @running = false
          break
        else
          on_event(event) if event
        end
      end

      update(@frame_seconds)
      Fiber.yield
      GC.collect
    end

    private def engine_draw
      @screen.lock do
        draw
      end
      @renderer.copy(@screen.surface)
      @renderer.present
    end
  end
end
