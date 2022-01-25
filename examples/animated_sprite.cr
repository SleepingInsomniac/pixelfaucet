require "../src/game"
require "../src/sprite"
require "../src/pixel_text"

module PF
  class SpriteExample < Game
    @text : PixelText = PixelText.new("assets/pf-font.png")

    @tiles : Array(Sprite)
    @frame = 0
    @sub_frame = 0.0
    @frame_time = 0.1

    def initialize(*args, **kwargs)
      super
      @tiles = Sprite.load_tiles("assets/walking.png", 32, 64)
    end

    def update(dt, event)
      @sub_frame += dt
      if @sub_frame > @frame_time
        @sub_frame = @sub_frame % @frame_time
        @frame = (@frame + 1) % @tiles.size
      end
    end

    def draw
      clear(60, 120, 200)
      @text.draw_to(screen, "Frame: #{@frame}", 5, 5)
      @tiles[@frame].draw_to(screen, (viewport // 2) - @tiles[@frame].size // 2)
    end
  end
end

game = PF::SpriteExample.new(120, 80, 5)
game.run!
