require "../src/pixelfaucet"

class SpriteExample < PF::Game
  @sprite : PF::Sprite

  def initialize(*args, **kwargs)
    super
    @sprite = PF::Sprite.new("./assets/walking.png")
  end

  def update(delta_time)
  end

  def frame(delta_time)
    window.lock do
      window.clear(20, 20, 20)
      window.draw(@sprite, @sprite.rect, @sprite.rect) { |src, dst| src.blend(dst) }
    end
  end
end

game = SpriteExample.new(320, 64, 2)
game.run!
