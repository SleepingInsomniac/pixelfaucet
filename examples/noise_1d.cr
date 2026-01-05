require "../src/pixelfaucet.cr"
require "../src/noise"

class Noise1d < PF::Game
  include PF

  @noise : Noise = Noise.new
  @noise_scale : Float64
  @noise_zoom : Float64

  @controls = Keymap.new({
    Scancode::Up    => "scale up",
    Scancode::Down  => "scale down",
    Scancode::Right => "zoom up",
    Scancode::Left  => "zoom down",
  })

  def initialize(*args, **kwargs)
    super

    @noise_scale = height / 4
    @noise_zoom = width / 4
    @xpos = 0.0

    register_keymap @controls
  end

  def update(delta_time)
    dt = delta_time.total_seconds
    @noise_scale += (@noise_scale * 0.8) * dt if @controls.held?("scale up")
    @noise_scale -= (@noise_scale * 0.8) * dt if @controls.held?("scale down")
    @noise_zoom  += (@noise_zoom  * 0.8) * dt if @controls.held?("zoom up")
    @noise_zoom  -= (@noise_zoom  * 0.8) * dt if @controls.held?("zoom down")
    @xpos += 20.0 * dt
  end

  def frame(delta_time)
    draw do
      clear(50, 127, 200)
      step = width // 15
      mid = height // 2

      0.upto(width) do |x|
        y = mid + (@noise.get((x + @xpos) / @noise_zoom) * @noise_scale).to_i
        draw_point(x, y, Colors::Yellow)
      end
    end
  end
end

game = Noise1d.new(300, 200, 2, fps_limit: 120.0)
game.run!
