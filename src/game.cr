require "./lib_sdl"
require "./pixel"
require "./sprite"
require "./controller"

module PF
  abstract class Game
    FPS_INTERVAL = 1.0
    SHOW_FPS     = true

    getter title : String
    getter width : Int32
    getter height : Int32
    getter scale : Int32
    @viewport : Vector2(Int32)? = nil

    property running = true
    property screen : Sprite

    delegate :draw_point, :draw_line, :scan_line, :draw_circle, :draw_triangle, :draw_rect, :draw_shape,
      :fill_triangle, :fill_rect, :fill_circle, :fill_shape, :draw_string, to: @screen

    @fps_lasttime : Float64 = Time.monotonic.total_milliseconds # the last recorded time.
    @fps_current : UInt32 = 0                                   # the current FPS.
    @fps_frames : UInt32 = 0                                    # frames passed since the last recorded fps.
    @last_time : Float64 = Time.monotonic.total_milliseconds
    @engine_started_at : Float64 = Time.monotonic.total_milliseconds

    def initialize(@width, @height, @scale = 1, @title = self.class.name,
                   flags = SDL::Renderer::Flags::ACCELERATED,
                   window_flags : SDL::Window::Flags = SDL::Window::Flags::SHOWN)
      SDL.init(SDL::Init::EVERYTHING)
      @window = SDL::Window.new(@title, @width * @scale, @height * @scale, flags: window_flags)
      @renderer = SDL::Renderer.new(@window, flags: flags)
      @renderer.scale = {@scale, @scale}
      @screen = Sprite.new(@width, @height)
    end

    abstract def update(dt : Float64, event : SDL::Event)
    abstract def draw

    # To be overridden
    def on_exit
    end

    def width=(value : Int32)
      @viewport = nil
      @width = value
      # TODO: Resize window
    end

    def height=(value : Int32)
      @viewport = nil
      @height = value
      # TODO: Resize window
    end

    def viewport
      @viewport ||= Vector[@width, @height]
    end

    def elapsed_time
      Time.monotonic.total_milliseconds - @engine_started_at
    end

    def elapsed_seconds
      elapsed_time / 1000
    end

    def clear(r = 0, g = 0, b = 0)
      @screen.fill(r, g, b)
    end

    def run!
      loop do
        case event = SDL::Event.poll
        when SDL::Event::Quit
          break
        end

        engine_update(event)
        engine_draw

        break unless @running
      end
    ensure
      on_exit
      SDL.quit
    end

    private def engine_update(event)
      et = Time.monotonic.total_milliseconds
      calculate_fps(et)
      update((et - @last_time) / 1000.0, event)
      @last_time = et
      Fiber.yield
      GC.collect
    end

    private def calculate_fps(et)
      return unless SHOW_FPS
      @fps_frames += 1
      if @fps_lasttime < et - FPS_INTERVAL * 1000
        @fps_lasttime = et
        @fps_current = @fps_frames
        @fps_frames = 0
        @window.title = String.build { |io| io << @title << " - " << @fps_current << " fps" }
      end
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
