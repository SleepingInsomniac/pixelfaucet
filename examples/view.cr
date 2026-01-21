require "../src/pixelfaucet"

require "../src/view"

class ViewExample < PF::Game
  include PF
  @view : View = View.new
  @speed = 50.0
  @mousedown : Bool = false
  @image = Sprite.new("./assets/checkers.png")
  @font = Pixelfont::Font.new("#{__DIR__}/../lib/pixelfont/fonts/pixel-5x7.txt")
  @show_lines = false
  @use_affine = false

  def initialize(*args, **kwargs)
    super

    @view.zoom = 10.0
    @view.origin = -((window.size / @view.zoom) / 2) # center

    keys.map({
      Scancode::Left  => "left",
      Scancode::Right => "right",
      Scancode::Up    => "up",
      Scancode::Down  => "down",
      Scancode::W     => "zoom in",
      Scancode::S     => "zoom out",
      Scancode::Space => "toggle lines",
      Scancode::Num1  => "toggle affine",
    })
  end

  def on_mouse_motion(direction, event)
    @view.pan(direction) if PF::Mouse["left"].held?
  end

  def on_mouse_wheel(direction : PF2d::Vec, inverted : Bool, window_id, event : Sdl3::Event)
    @view.zoom_at(PF::Mouse.pos, direction.y)
  end

  def update(delta_time)
    dt = delta_time.total_seconds
    dpan = PF2d::Vec[0.0, 0.0]
    dzoom = 0.0
    dpan.x -= @speed * dt if keys["left"].held?
    dpan.x += @speed * dt if keys["right"].held?
    dpan.y -= @speed * dt if keys["up"].held?
    dpan.y += @speed * dt if keys["down"].held?
    dzoom  += 1.0 * dt if keys["zoom in"].held?
    dzoom  -= 1.0 * dt if keys["zoom out"].held?

    @show_lines = !@show_lines if keys["toggle lines"].pressed?
    @use_affine = !@use_affine if keys["toggle affine"].pressed?

    @view.pan(dpan).zoom(dzoom)
  end

  def frame(delta_time)
    lock do
      clear(50, 127, 200)

      if @use_affine
        td1, td2 = Rect[@view.map(-10.0, -10.0), Vec[20.0, 20.0] * @view.zoom].tris
        ts1, ts2 = @image.rect.tris(Float64)

        td1.map_points(ts1) do |src, dst|
          if sample = @image[src]?
            draw_point(dst, sample)
          end
        end

        td2.map_points(ts2) do |src, dst|
          if sample = @image[src]?
            draw_point(dst, sample)
          end
        end
      else
        dst = Rect[
          @view.map(-10.0, -10.0),
          Vec[20.0, 20.0] * @view.zoom,
        ]

        draw(@image, src_rect: @image.rect, dst_rect: dst) { |s, d| s.blend(d) }
      end

      if @show_lines
        g = {-10, 10}
        g[0].upto(g[1]) do |x|
          ly_1 = @view.map(x.to_f, g[0])
          ly_2 = @view.map(x.to_f, g[1])
          lx_1 = @view.map(g[0], x.to_f)
          lx_2 = @view.map(g[1], x.to_f)

          draw_line(ly_1, ly_2, PF::Colors::White)
          draw_line(lx_1, lx_2, PF::Colors::White)
        end
      end

      zz = @view.map(PF::Vec[0.0, 0.0]).to_i32

      draw_line(0, zz.y, width, zz.y, PF::Colors::Red)
      draw_line(zz.x, 0, zz.x, height, PF::Colors::Green)

      draw_circle(PF::Mouse.pos, 5, PF::Colors::Yellow)

      draw_string(<<-TEXT, 1, 1, @font, PF::Colors::White)
      (x:#{@view.pan.x.round(2)}, y:#{@view.pan.y.round(2)})
      zoom: #{@view.zoom.round(2)}
      TEXT
    end
  end
end

game = ViewExample.new(640 // 2, 480 // 2, 2)
game.run!
