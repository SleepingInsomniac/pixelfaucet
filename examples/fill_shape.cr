require "../src/game"
require "../src/pixel"

class FillShape < PF::Game
  @color = PF::Pixel.random

  def initialize(*args, **kwargs)
    super
  end

  def update(dt)
    if elapsed_milliseconds.to_i % 100 == 1
      @color = PF::Pixel.random
    end
  end

  def draw
    clear(0, 0, 100)
    fill_shape({PF2d::Vec[15, 15], PF2d::Vec[50, 10], PF2d::Vec[60, 55], PF2d::Vec[10, 60]}, @color)
    fill_shape({PF2d::Vec[100, 10], PF2d::Vec[150, 10], PF2d::Vec[150, 60], PF2d::Vec[100, 60]}, @color)
    fill_shape({
      PF2d::Vec[10, 100],
      PF2d::Vec[20, 110],
      PF2d::Vec[30, 100],
      PF2d::Vec[40, 110],
      PF2d::Vec[50, 100],
      PF2d::Vec[50, 150],
      PF2d::Vec[10, 150],
    }, @color)
    fill_shape({PF2d::Vec[115, 115], PF2d::Vec[150, 120], PF2d::Vec[160, 155], PF2d::Vec[110, 160]}, @color)
  end
end

engine = FillShape.new(200, 200, 3)
engine.run!
