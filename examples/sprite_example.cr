require "../src/game"
require "../src/sprite"

module PF
  class SpriteExample < Game
    @sprite : Sprite

    def initialize(*args, **kwargs)
      super
      @sprite = Sprite.new("./assets/walking.png")
    end

    def update(dt)
    end

    def draw
      clear(255, 255, 255)
      @sprite.draw_to(screen, (viewport // 2) - @sprite.size // 2)
    end
  end
end

game = PF::SpriteExample.new(200, 200, 2)
game.run!
