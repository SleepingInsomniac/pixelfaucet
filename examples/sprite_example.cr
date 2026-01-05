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

    def draw(delta_time)
      clear(20, 20, 20)
      draw_sprite(@sprite, @sprite.rect, PF2d::Rect.new(PF2d::Vec[0, 0], @sprite.size))
    end
  end
end

game = PF::SpriteExample.new(200, 200, 2)
game.run!
