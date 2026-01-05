require "../src/pixelfaucet"
require "../src/emitter"

class Particles < PF::Game
  @emitter = PF::Emitter.new

  def initialize(*args, **kwargs)
    super

    @emitter.position = viewport / 2
  end

  def update(delta_time)
    @emitter.update(delta_time.total_seconds)
  end

  def frame(delta_time)
    draw do
      clear(0, 0, 0)
      @emitter.draw(self)
    end
  end
end

example = Particles.new(200, 200, 2)
example.run!
