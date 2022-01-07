require "../src/game"
require "../src/sprite"

module PF
  class SpriteExample < Game
    @bricks : Sprite

    def initialize(*args, **kwargs)
      super
      @bricks = Sprite.new("./assets/pf-font.png")
    end

    def update(dt, event)
    end

    def draw
      clear(255, 255, 255)
      @bricks.draw_to(@screen, width // 2 - @bricks.width // 2, height // 2 - @bricks.height // 2)
    end
  end
end

game = PF::SpriteExample.new(200, 200, 2)
game.run!
