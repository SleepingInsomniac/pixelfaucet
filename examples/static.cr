require "../src/pixelfaucet"

class Static < PF::Game
  def update(delta_time)
  end

  def frame(delta_time)
    window.draw do
      0.upto(window.height - 1) do |y|
        0.upto(window.width - 1) do |x|
          color = PF::RGBA.new(rand(0u32..UInt32::MAX) | 0xFFu8)
          window.draw_point(x, y, color)
        end
      end
    end
  end
end

Static.new(64, 64, 6).run!
