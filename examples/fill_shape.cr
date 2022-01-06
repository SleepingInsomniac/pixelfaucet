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
    fill_shape(PF::Vector[15, 15], PF::Vector[50, 10], PF::Vector[60, 55], PF::Vector[10, 60])
    fill_shape(PF::Vector[100, 10], PF::Vector[150, 10], PF::Vector[150, 60], PF::Vector[100, 60])
    fill_shape(
      PF::Vector[10, 100],
      PF::Vector[20, 110],
      PF::Vector[30, 100],
      PF::Vector[40, 110],
      PF::Vector[50, 100],
      PF::Vector[50, 150],
      PF::Vector[10, 150],
    )
    fill_shape(PF::Vector[115, 115], PF::Vector[150, 120], PF::Vector[160, 155], PF::Vector[110, 160])
  end
end

engine = FillShape.new(200, 200, 3)
engine.run!
