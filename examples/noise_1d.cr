require "../src/pixelfaucet.cr"
require "../src/noise"

class Noise1d < PF::Game
  include PF

  @noise : Noise = Noise.new
  @noise_scale : Float64
  @noise_zoom : Float64

  def initialize(*args, **kwargs)
    super

    @noise_scale = window.height / 4
    @noise_zoom  = window.width / 4
    @xpos = 0.0

    keys.map({
      Scancode::Up    => "scale up",
      Scancode::Down  => "scale down",
      Scancode::Right => "zoom up",
      Scancode::Left  => "zoom down",
    })
  end

  def update(delta_time)
    dt = delta_time.total_seconds
    @noise_scale += (@noise_scale * 0.8) * dt if keys["scale up"].held?
    @noise_scale -= (@noise_scale * 0.8) * dt if keys["scale down"].held?
    @noise_zoom  += (@noise_zoom  * 0.8) * dt if keys["zoom up"].held?
    @noise_zoom  -= (@noise_zoom  * 0.8) * dt if keys["zoom down"].held?
    @xpos += 20.0 * dt
  end

  def frame(delta_time)
    window.draw do
      window.clear(50, 127, 200)
      step = window.width // 15
      mid = window.height // 2

      0.upto(window.width - 1) do |x|
        y = mid + (@noise.get((x + @xpos) / @noise_zoom) * @noise_scale).to_i
        window.draw_point(x, y, Colors::Yellow)
      end
    end
  end
end

game = Noise1d.new(300, 200, 2, fps_limit: 120.0)
game.run!
