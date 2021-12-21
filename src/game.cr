require "crystaledge"
require "./lib_sdl"
require "./pixel"
require "./point"
require "./controller"
require "./game/fill_triangle"

module PF
  abstract class Game
    include CrystalEdge
    FPS_INTERVAL = 1.0

    property width : Int32
    property height : Int32
    property scale : Int32
    property title : String
    property running = true
    property screen : SDL::Surface

    @fps_lasttime : Float64 = Time.monotonic.total_milliseconds # the last recorded time.
    @fps_current : UInt32 = 0                                   # the current FPS.
    @fps_frames : UInt32 = 0                                    # frames passed since the last recorded fps.
    @last_time : Float64 = Time.monotonic.total_milliseconds
    @controller : Controller(LibSDL::Keycode)

    def initialize(@width, @height, @scale = 1, @title = self.class.name, flags = SDL::Renderer::Flags::ACCELERATED)
      SDL.init(SDL::Init::VIDEO)
      @window = SDL::Window.new(@title, @width * @scale, @height * @scale)
      @renderer = SDL::Renderer.new(@window, flags: flags)
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
      @screen.fill(r, g, b)
    end

    def pixel_pointer(x : Int32, y : Int32, surface = @screen)
      target = surface.pixels + (y * surface.pitch) + (x * 4)
      target.as(Pointer(UInt32))
    end

    # =================
    # Drawing functions
    # =================

    # Draw a single point
    def draw_point(x : Int32, y : Int32, pixel : Pixel = Pixel.new, surface = @screen)
      if x >= 0 && x < @width && y >= 0 && y < @height
        pixel_pointer(x, y, surface).value = pixel.format(surface.format)
      end
    end

    # Draw a single point
    def draw_point(vector : Vector2, pixel : Pixel = Pixel.new, surface = @screen)
      draw_point(vector.x.to_i32, vector.y.to_i32, pixel, surface)
    end

    # Draw a single point
    def draw_point(point, pixel : Pixel = Pixel.new, surface = @screen)
      draw_point(point.x, point.y, pixel, surface)
    end

    # Draw a line using Bresenham’s Algorithm
    def draw_line(x1 : Int, y1 : Int, x2 : Int, y2 : Int, pixel : Pixel = Pixel.new, surface = @screen)
      # The slope for each axis
      slope = Point.new((x2 - x1).abs, -(y2 - y1).abs)

      # The step direction in both axis
      step = Point.new(x1 < x2 ? 1 : -1, y1 < y2 ? 1 : -1)

      # The final decision accumulation
      # Initialized to the height of x and y
      decision = slope.x + slope.y

      point = Point.new(x1, y1)

      loop do
        draw_point(point.x, point.y, pixel, surface)
        # Break if we've reached the ending point
        break if point.x == x2 && point.y == y2

        # Square the decision to avoid floating point calculations
        decision_squared = decision + decision

        # if decision_squared is greater than
        if decision_squared >= slope.y
          decision += slope.y
          point.x += step.x
        end

        if decision_squared <= slope.x
          decision += slope.x
          point.y += step.y
        end
      end
    end

    # Draw a line using Bresenham’s Algorithm
    def draw_line(p1 : Vector2, p2 : Vector2, pixel : Pixel = Pixel.new, surface = @screen)
      draw_line(p1.x.to_i, p1.y.to_i, p2.x.to_i, p2.y.to_i, pixel, surface)
    end

    def draw_line(p1 : Point, p2 : Point, pixel : Pixel = Pixel.new, surface = @screen)
      draw_line(p1.x, p1.y, p2.x, p2.y, pixel, surface)
    end

    # Draw the outline of a square rect
    def draw_rect(x1 : Int, y1 : Int, x2 : Int, y2 : Int, pixel : Pixel = Pixel.new, surface = @screen)
      # draw from top left to bottom right
      y1, y2 = y2, y1 if y1 > y2
      x1, x2 = x2, x1 if x1 > x2

      x1.upto(x2) do |x|
        draw_point(x, y1, pixel, surface)
        draw_point(x, y2, pixel, surface)
      end

      y1.upto(y2) do |y|
        draw_point(x1, y, pixel, surface)
        draw_point(x2, y, pixel, surface)
      end
    end

    def draw_rect(p1 : PF::Point(Int), p2 : PF::Point(Int), pixel : Pixel = Pixel.new, surface = @screen)
      draw_rect(p1.x, p1.y, p2.x, p2.y, pixel, surface)
    end

    # Draw lines enclosing a shape
    def draw_shape(frame : Array(Vector2), pixel : Pixel = Pixel.new, surface = @screen)
      0.upto(frame.size - 1) do |n|
        draw_line(frame[n], frame[(n + 1) % frame.size], pixel, surface)
      end
    end

    # Draw a circle using Bresenham’s Algorithm
    def draw_circle(cx : Int, cy : Int, r : Int, pixel : Pixel = Pixel.new, surface = @screen)
      x, y = 0, r
      d = 3 - 2 * r

      loop do
        draw_point(cx + x, cy + y, pixel)
        draw_point(cx - x, cy + y, pixel)
        draw_point(cx + x, cy - y, pixel)
        draw_point(cx - x, cy - y, pixel)
        draw_point(cx + y, cy + x, pixel)
        draw_point(cx - y, cy + x, pixel)
        draw_point(cx + y, cy - x, pixel)
        draw_point(cx - y, cy - x, pixel)

        break if x > y

        x += 1

        if d > 0
          y -= 1
          d = d + 4 * (x - y) + 10
        else
          d = d + 4 * x + 6
        end
      end
    end

    def draw_circle(c : Point(Int), r : Int, pixel : Pixel = Pixel.new, surface = @screen)
      draw_circle(c.x, c.y, r, pixel, surface)
    end

    def draw_triangle(p1 : Point, p2 : Point, p3 : Point, pixel : Pixel = Pixel.new, surface = @screen)
      draw_line(p1, p2, pixel, surface)
      draw_line(p2, p3, pixel, surface)
      draw_line(p3, p1, pixel, surface)
    end

    def draw_triangle(p1 : Vector2, p2 : Vector2, p3 : Vector2, pixel : Pixel = Pixel.new, surface = @screen)
      p1 = Point(Int32).new(x: p1.x.to_i, y: p1.y.to_i)
      p2 = Point(Int32).new(x: p2.x.to_i, y: p2.y.to_i)
      p3 = Point(Int32).new(x: p3.x.to_i, y: p3.y.to_i)
      draw_triangle(p1, p2, p3, pixel, surface)
    end

    # Fill a rect
    def fill_rect(x1 : Int, y1 : Int, x2 : Int, y2 : Int, pixel : Pixel = Pixel.new, surface = @screen)
      # draw from top left to bottom right
      y1, y2 = y2, y1 if y1 > y2
      x1, x2 = x2, x1 if x1 > x2

      y1.upto(y2) do |y|
        x1.upto(x2) do |x|
          draw_point(x, y, pixel, surface)
        end
      end
    end

    # END drawing functions ========================

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

      @renderer.copy(@screen)
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
