require "crystaledge"
require "./lib_sdl"
require "./pixel"
require "./point"
require "./controller"

module PF
  abstract class Game
    include CrystalEdge
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

    def initialize(@width, @height, @scale = 1, @title = self.class.name, flags = SDL::Renderer::Flags::PRESENTVSYNC)
      SDL.init(SDL::Init::VIDEO)
      @window = SDL::Window.new(@title, @width * @scale, @height * @scale)
      @renderer = SDL::Renderer.new(@window, flags: flags) # , flags: SDL::Renderer::Flags::SOFTWARE)
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
      if x >= 0 && x <= @width && y >= 0 && y <= @height
        pixel_pointer(x, y, surface).value = pixel.format(surface.format)
      end
    end

    # Draw a single point
    def draw_point(vector : Vector2, pixel : Pixel = Pixel.new, surface = @screen)
      draw_point(vector.x.to_i32, vector.y.to_i32, pixel, surface)
    end

    # Draw a line using Bresenham’s Algorithm
    def draw_line(x1 : Int, y1 : Int, x2 : Int, y2 : Int, pixel : Pixel = Pixel.new, surface = @screen)
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

    # Draw a line using Bresenham’s Algorithm
    def draw_line(p1 : Vector2, p2 : Vector2, pixel : Pixel = Pixel.new, surface = @screen)
      draw_line(p1.x.to_i, p1.y.to_i, p2.x.to_i, p2.y.to_i, pixel, surface)
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

    def fill_triangle(p1 : Vector2, p2 : Vector2, p3 : Vector2, pixel : Pixel = Pixel.new, surface = @screen)
      p1 = Point(Int32).new(x: p1.x.to_i, y: p1.y.to_i)
      p2 = Point(Int32).new(x: p2.x.to_i, y: p2.y.to_i)
      p3 = Point(Int32).new(x: p3.x.to_i, y: p3.y.to_i)
      # sort from top to bottom
      p_top, p2, p3 = [p1, p2, p3].sort { |a, b| a.y <=> b.y }

      y_step = 0

      # find the lower left and right points
      p_left, p_right = p2.x < p3.x ? [p2, p3] : [p3, p2]

      edge_left = get_tri_edge(p_top.x, p_top.y, p_left.x, p_left.y)
      edge_right = get_tri_edge(p_top.x, p_top.y, p_right.x, p_right.y)

      if edge_left.size < edge_right.size
        rest = get_tri_edge(p_left.x, p_left.y, p_right.x, p_right.y)
        rest.shift
        edge_left.concat(rest)
      end

      if edge_left.size > edge_right.size
        rest = get_tri_edge(p_right.x, p_right.y, p_left.x, p_left.y)
        rest.shift
        edge_right.concat(rest)
      end

      0.upto(edge_left.size - 1) do |i|
        pl = edge_left[i]
        pr = edge_right[i]

        (pl.x + 1).upto(pr.x - 1) do |x|
          draw_point(x, pl.y, pixel, surface)
        end
      end
    end

    private def get_tri_edge(x1 : Int, y1 : Int, x2 : Int, y2 : Int)
      line = [] of Point(Int32)
      dx = (x2 - x1).abs
      dy = -(y2 - y1).abs

      sx = x1 < x2 ? 1 : -1
      sy = y1 < y2 ? 1 : -1

      d = dx + dy
      x, y = x1, y1
      xp = x

      line << Point.new(x, y)

      loop do
        break if x == x2 && y == y2
        d2 = d + d

        if d2 >= dy
          d += dy
          x += sx
        end

        if d2 <= dx
          d += dx
          line << Point.new(x, y)
          y += sy
        end
      end

      line
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
