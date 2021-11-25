require "./lib_sdl"
require "./pixel"
require "./controller"

module PF
  abstract class Game
    FPS_INTERVAL = 1.0

    property width : Int32
    property height : Int32
    property scale : Int32
    property title : String
    property running = true

    @fps_lasttime : Float64 = Time.monotonic.total_milliseconds # the last recorded time.
    @fps_current : UInt32 = 0                                   # the current FPS.
    @fps_frames : UInt32 = 0                                    # frames passed since the last recorded fps.
    @last_time : Float64 = Time.monotonic.total_milliseconds
    @controller : Controller(LibSDL::Keycode)

    def initialize(@width, @height, @scale = 1, @title = self.class.name)
      SDL.init(SDL::Init::VIDEO)
      @window = SDL::Window.new(@title, @width * @scale, @height * @scale)
      @renderer = SDL::Renderer.new(@window, flags: SDL::Renderer::Flags::PRESENTVSYNC) # , flags: SDL::Renderer::Flags::SOFTWARE)
      @renderer.scale = {@scale, @scale}
      @screen = SDL::Surface.new(LibSDL.create_rgb_surface(
        flags: 0, width: @width, height: @height, depth: 32,
        r_mask: 0xFF000000, g_mask: 0x00FF0000, b_mask: 0x0000FF00, a_mask: 0x000000FF
      ))
      @controller = Controller(LibSDL::Keycode).new({} of LibSDL::Keycode => String)
    end

    abstract def update(dt : Float64)
    abstract def draw

    def elapsed_time
      Time.monotonic.total_milliseconds
    end

    def clear(r = 0, g = 0, b = 0)
      @screen.fill(0, 0, 0)
    end

    def pixel_pointer(x : Int32, y : Int32, surface = @screen)
      target = surface.pixels + (y * surface.pitch) + (x * 4)
      target.as(Pointer(UInt32))
    end

    def draw_point(x : Int32, y : Int32, pixel : Pixel, surface = @screen)
      pixel_pointer(x, y, surface).value = pixel.format(surface.format)
    end

    # Draw a line using Bresenham’s Algorithm
    def draw_line(p1 : Vector2, p2 : Vector2, pixel : Pixel, surface = @screen)
      return draw_line(p2, p1, pixel, surface) if p1.x > p2.x
      x1, y1, x2, y2 = p1.x.to_i, p1.y.to_i, p2.x.to_i, p2.y.to_i

      dx = (x2 - x1).abs
      dy = -(y2 - y1).abs

      sx = x1 < x2 ? 1 : -1
      sy = y1 < y2 ? 1 : -1

      d = dx + dy
      x, y = x1, y1

      loop do
        draw_point(x, y, pixel, surface)
        break if x == x2 && y == y2

        d2 = d + d

        if d2 >= dy
          d += dy
          x += sx
        end

        if d2 <= dx
          d += dx
          y += sy
        end
      end
    end

    private def engine_update
      @fps_frames += 1
      et = elapsed_time

      if @fps_lasttime < et - FPS_INTERVAL * 1000
        @fps_lasttime = et
        @fps_current = @fps_frames
        @fps_frames = 0
        @window.title = String.build { |io| io << @title << " - " << @fps_current << " fps" }
      end

      update((et - @last_time) / 1000.0)
      @last_time = et
    end

    private def engine_draw
      @screen.lock do
        draw
      end

      @renderer.copy(SDL::Texture.from(@screen, @renderer))
      @renderer.present
    end

    def run!
      loop do
        case event = SDL::Event.poll
        when SDL::Event::Keyboard
          if event.keydown?
            @controller.press(event.sym)
          elsif event.keyup?
            @controller.release(event.sym)
          end
        when SDL::Event::Quit
          break
        end

        engine_update
        engine_draw

        break unless @running
      end
    ensure
      SDL.quit
    end
  end
end
