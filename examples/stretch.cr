require "../src/pixelfaucet"

class Stretch < PF::Game
  @sprite : PF2d::Clip(PF::RGBA)
  @stretch : PF2d::Rect(Int32) = PF2d::Rect[0, 0, 32, 64]
  @vel : PF2d::Vec2(Float64) = PF2d::Vec[0.25, 0.25]

  def initialize(*args, **kwargs)
    super
    # Clip the animation sheet
    @sprite = PF2d::Clip.new(@stretch, PF::Sprite.new("./assets/walking.png"))
  end

  def update(delta_time)
    @vel.x = -@vel.x if @stretch.size.x >= window.size.x || @stretch.size.x <= 0
    @vel.y = -@vel.y if @stretch.size.y >= window.size.y || @stretch.size.y <= 0

    @stretch.size = @stretch.size + (@vel * delta_time.total_milliseconds).to(Int32)
  end

  def frame(delta_time)
    window.draw do
      window.clear(20, 20, 20)
      window.draw(@sprite, @sprite.rect, @stretch)
      window.draw_rect(@stretch, PF::Colors::Gray)
    end
  end
end

Stretch.new(200, 200, 2).run!
