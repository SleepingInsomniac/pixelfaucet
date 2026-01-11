require "../src/pixelfaucet"

module PF
  class SpriteExample < Game
    @sprite : Sprite

    def initialize(*args, **kwargs)
      super
      @sprite = Sprite.new("./assets/walking.png")
    end

    def update(delta_time)
    end

    def frame(delta_time)
      window.draw do
        window.clear(20, 20, 20)
        window.draw(@sprite, @sprite.rect, PF2d::Rect.new(PF2d::Vec[0, 0], @sprite.size)) { |d, s| s.blend(d) }
      end
    end
  end
end

game = PF::SpriteExample.new(200, 200, 2)
game.run!
