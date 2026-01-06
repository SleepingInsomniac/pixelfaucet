require "../src/pixelfaucet"

class FillPoly < PF::Game
  include PF
  include PF2d

  @color = RGBA.new(rand(0u32..UInt32::MAX) | 0xFFu8)
  @color_change = Interval.new(0.3.seconds)

  def update(delta_time)
    @color_change.update(delta_time) do
      @color = RGBA.new(rand(0u32..UInt32::MAX) | 0xFFu8)
    end
  end

  def frame(delta_time)
    window.draw do
      window.clear(0, 0, 100)
      window.fill_poly({Vec[15, 15], Vec[50, 10], Vec[60, 55], Vec[10, 60]}, @color)
      window.fill_poly({Vec[100, 10], Vec[150, 10], Vec[150, 60], Vec[100, 60]}, @color)
      window.fill_poly({
        Vec[10, 100],
        Vec[20, 110],
        Vec[30, 100],
        Vec[40, 110],
        Vec[50, 100],
        Vec[50, 150],
        Vec[10, 150],
      }, @color)
      window.fill_poly({Vec[115, 115], Vec[150, 120], Vec[160, 155], Vec[110, 160]}, @color)
    end
  end
end

engine = FillPoly.new(200, 200, 3)
engine.run!
