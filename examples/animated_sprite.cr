require "../src/game"
require "../src/sprite"
require "../src/animation"

module PF
  class SpriteExample < Game
    def initialize(*args, **kwargs)
      super
      @person = Animation.new("assets/walking.png", 32, 64, 10)
      @cat = Animation.new("assets/black-cat.png", 18, 14, 15)
      @font = Pixelfont::Font.new("#{__DIR__}/../lib/pixelfont/fonts/pixel-5x7.txt")
    end

    def update(dt)
      @person.update(dt)
      @cat.update(dt)
    end

    def draw
      clear(60, 120, 200)
      draw_string("Frame: #{@person.frame}", 5, 5, @font, Pixel::White)
      fill_rect(0, 65, width - 1, height - 1, Pixel.new(100, 100, 100))
      @person.draw_to(screen, (viewport // 2) - @person.size // 2)
      @cat.draw_to(screen, 30, 56)
    end
  end
end

game = PF::SpriteExample.new(120, 80, 5)
game.run!
