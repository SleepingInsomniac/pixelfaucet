require "../src/pixelfaucet"

class AnimatedSprite < PF::Game
  include PF
  include PF2d

  def initialize(*args, **kwargs)
    super
    @person = Animation.new("assets/walking.png", 32, 64, 10)
    @cat = Animation.new("assets/black-cat.png", 18, 14, 15)
    @font = Pixelfont::Font.new("#{__DIR__}/../lib/pixelfont/fonts/pixel-5x7.txt")
  end

  def update(delta_time)
    @person.update(delta_time)
    @cat.update(delta_time)
  end

  def frame(delta_time)
    window.draw do
      window.clear(60, 120, 200)
      window.draw_string("Frame: #{@person.frame}", 5, 5, @font, Colors::White)
      window.fill_rect(0, 65, window.width - 1, window.height - 1, RGBA.new(100, 100, 100))
      window.draw_sprite(@person.current_frame, (window.size // 2) - @person.size // 2)
      window.draw_sprite(@cat.current_frame, Vec[30, 56])
    end
  end
end

game = AnimatedSprite.new(120, 80, 5, fps_limit: 120.0)
game.run!
