require "../src/game"

class Life < PF::Game
  CELL_ON  = PF::Pixel.new(255, 255, 0)
  CELL_OFF = PF::Pixel.new(0, 0, 100)

  @last_pos : PF2d::Vec2(Int32)? = nil
  @mouse_down = false
  @simulation = false
  @sim_speed = 0.1
  @sub_frame = 0.0

  def initialize(*args, **kwargs)
    super

    @controller = PF::Controller(PF::Keys).new({
      PF::Keys::SPACE => "Play/Pause",
      PF::Keys::UP    => "Faster",
      PF::Keys::DOWN  => "Slower",
    })
    plug_in @controller
    clear(CELL_OFF)
  end

  def update(dt)
    if @simulation
      @sub_frame += dt

      if @sub_frame >= @sim_speed
        @sub_frame -= @sim_speed
        changes = Array(Tuple(Int32, Int32, PF::Pixel)).new

        0.upto(height) do |y|
          0.upto(width) do |x|
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
          draw_point(x, y, pixel)
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
      @screen.get_point(x + dx, y + dy)
    end
  end

  def toggle_cell(pos)
    pixel = @screen.get_point(pos)

    if pixel != CELL_ON
      draw_point(pos, CELL_ON)
    else
      draw_point(pos, CELL_OFF)
    end
  end

  def on_mouse_motion(cursor)
    if @mouse_down && @last_pos != cursor
      @last_pos = cursor
      toggle_cell(cursor)
    end
  end

  def on_mouse_button(event)
    if event.button == 1 # left click
      if event.pressed?
        pos = PF2d::Vec[event.x // @scale.x, event.y // @scale.y]
        @last_pos = pos
        toggle_cell(pos)
      else
        @last_pos = nil
      end

      @mouse_down = event.pressed?
    end
  end

  def on_controller_input(event)
    if @controller.pressed?("Play/Pause")
      @simulation = !@simulation
    end

    if @controller.pressed?("Faster")
      @sim_speed /= 2.0
    end

    if @controller.pressed?("Slower")
      @sim_speed *= 2.0
    end
  end

  def draw
  end
end

engine = Life.new(50, 50, 10)
engine.run!
