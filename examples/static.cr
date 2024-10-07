require "../src/game"

module PF
  class Static < Game
    def update(dt)
    end

    def draw
      screen.pixels.fill { PF::Pixel.random.to_u32 }
    end
  end
end

PF::Static.new(400, 300, 3).run!
