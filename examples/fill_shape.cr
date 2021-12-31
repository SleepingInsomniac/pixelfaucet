require "../src/game"
require "../src/pixel"

class FillShape < PF::Game
  def initialize(*args, **kwargs)
    super
  end

  def update(dt, event)
  end

  def draw
    clear(0, 0, 100)
    fill_shape(PF::Point.new(15, 15), PF::Point.new(50, 10), PF::Point.new(60, 55), PF::Point.new(10, 60))
    fill_shape(PF::Point.new(100, 10), PF::Point.new(150, 10), PF::Point.new(150, 60), PF::Point.new(100, 60))
    fill_shape(
      PF::Point.new(10, 100),
      PF::Point.new(20, 110),
      PF::Point.new(30, 100),
      PF::Point.new(40, 110),
      PF::Point.new(50, 100),
      PF::Point.new(50, 150),
      PF::Point.new(10, 150),
    )
    fill_shape(PF::Point.new(115, 115), PF::Point.new(150, 120), PF::Point.new(160, 155), PF::Point.new(110, 160))
  end
end

engine = FillShape.new(200, 200, 3)
engine.run!
