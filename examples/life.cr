require "../src/pixelfaucet"

class Life < PF::Game
  CELL_ON  = PF::RGBA.new(255, 255, 0)
  CELL_OFF = PF::RGBA.new(0, 0, 100)

  @last_pos : PF2d::Vec2(Float32)? = nil
  @mouse_down = false
  @simulation = false
  @screen : PF::Sprite
  @sim = PF::Interval.new(100.0.milliseconds)

  def initialize(*args, **kwargs)
    super

    @screen = PF::Sprite.new(width, height)
    @screen.clear(CELL_OFF)
    @keymap = PF::Keymap.new({
      PF::Scancode::Space => "Play/Pause",
      PF::Scancode::Up    => "Faster",
      PF::Scancode::Down  => "Slower",
    })
    register_keymap @keymap
  end

  def update(delta_time)
    dt = delta_time.total_seconds
    if @keymap.pressed?("Play/Pause")
      @simulation = !@simulation
    end

    if @keymap.pressed?("Faster")
      @sim.every /= 2.0
    end

    if @keymap.pressed?("Slower")
      @sim.every *= 2.0
    end

    if @simulation
      @sim.update(delta_time) do
        changes = Array(Tuple(Int32, Int32, PF::RGBA)).new

        0.upto(height - 1) do |y|
          0.upto(width - 1) do |x|
            neighbors_alive = neighbors(x, y).count { |pixel| pixel == CELL_ON }
            cell_alive = @screen.get_point(x, y) == CELL_ON

            if cell_alive && neighbors_alive < 2
              changes << {x, y, CELL_OFF}
            end

            if cell_alive && neighbors_alive > 3
              changes << {x, y, CELL_OFF}
            end

            if !cell_alive && neighbors_alive == 3
              changes << {x, y, CELL_ON}
            end
          end
        end

        changes.each do |(x, y, pixel)|
          @screen.draw_point(x, y, pixel)
        end
      end
    end
  end

  def neighbors(x, y)
    {
      {-1, -1}, {0, -1}, {1, -1},
      {-1, 0}, {1, 0},
      {-1, 1}, {0, 1}, {1, 1},
    }.map do |(dx, dy)|
      nx, ny = x + dx, y + dy
      if nx >= 0 && nx < width && ny >= 0 && ny < height
        @screen.get_point(nx, ny)
      else
        CELL_OFF
      end
    end
  end

  def toggle_cell(pos)
    pixel = @screen.get_point(pos.to_i32)

    if pixel != CELL_ON
      @screen.draw_point(pos.to_i32, CELL_ON)
    else
      @screen.draw_point(pos.to_i32, CELL_OFF)
    end
  end

  def on_mouse_motion(cursor, event)
    if @mouse_down && @last_pos != cursor
      @last_pos = cursor
      toggle_cell(cursor)
    end
  end

  def on_mouse_down(cursor, event)
    if event.button == 1 # left click
      @last_pos = cursor
      toggle_cell(cursor)
      @mouse_down = true
    end
  end

  def on_mouse_up(cursor, event)
    @last_pos = nil
    @mouse_down = false
  end

  def frame(delta_time)
    draw do
      draw_sprite(@screen, PF2d::Vec[0,0])
    end
  end
end

engine = Life.new(50, 50, 10, fps_limit: 60.0)
engine.run!
