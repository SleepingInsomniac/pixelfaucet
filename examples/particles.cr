require "../src/game"
require "../src/emitter"

module PF
  class Example < Game
    @emitter : Emitter

    def initialize(*args, **kwargs)
      super

      @emitter = Emitter.new
      @emitter.position = viewport / 2
    end

    def update(dt)
      @emitter.update(dt)
    end

    def draw
      clear(0, 0, 0)
      @emitter.draw(self)
    end
  end
end

example = PF::Example.new(200, 200, 2)
example.run!
