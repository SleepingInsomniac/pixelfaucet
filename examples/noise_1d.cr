require "../src/game"
require "../src/controller"
require "../src/noise"

module PF
  class Noise1d < Game
    @noise : Noise = Noise.new
    @noise_scale : Float64
    @noise_zoom : Float64

    def initialize(*args, **kwargs)
      super

      @noise_scale = height / 4
      @noise_zoom = width / 4
      @xpos = 0.0

      @controller = PF::Controller(LibSDL::Scancode).new({
        LibSDL::Scancode::UP    => "scale up",
        LibSDL::Scancode::DOWN  => "scale down",
        LibSDL::Scancode::RIGHT => "zoom up",
        LibSDL::Scancode::LEFT  => "zoom down",
      })
    end

    def update(dt, event)
      @controller.map_event(event)
      @noise_scale += (@noise_scale * 0.8) * dt if @controller.held?("scale up")
      @noise_scale -= (@noise_scale * 0.8) * dt if @controller.held?("scale down")
      @noise_zoom += (@noise_zoom * 0.8) * dt if @controller.held?("zoom up")
      @noise_zoom -= (@noise_zoom * 0.8) * dt if @controller.held?("zoom down")
      @xpos += 20.0 * dt
    end

    def draw
      clear(50, 127, 200)
      step = width // 15
      mid = height // 2

      0.upto(width) do |x|
        y = mid + (@noise.get((x + @xpos) / @noise_zoom) * @noise_scale).to_i
        draw_point(x, y, Pixel.yellow)
      end
    end
  end
end

game = PF::Noise1d.new(300, 200, 2)
game.run!
