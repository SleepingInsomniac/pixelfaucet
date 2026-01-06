require "../src/pixelfaucet"
require "../src/emitter"

class Particles < PF::Game
  @emitter = PF::Emitter.new

  def initialize(*args, **kwargs)
    super

    @emitter.position = window.size / 2
  end

  def update(delta_time)
    @emitter.update(delta_time.total_seconds)
  end

  def frame(delta_time)
    window.draw do
      window.clear(0, 0, 0)
      @emitter.draw(window)
    end
  end
end

example = Particles.new(200, 200, 2)
example.run!
