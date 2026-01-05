require "../src/pixelfaucet"

module PF
  class Static < Game
    @font = Pixelfont::Font.new("#{__DIR__}/../lib/pixelfont/fonts/pixel-3x5.txt")
    @fps_string = ""
    @fps_timer = PF::Interval.new(1.0.seconds)

    def update(delta_time)
      @fps_timer.update(delta_time) { @fps_string = "#{fps.round.to_i} FPS" }
    end

    def frame(delta_time)
      draw do
        0.upto(height - 1) do |y|
          0.upto(width - 1) do |x|
            color = RGBA.new(rand(0u32..UInt32::MAX) | 0xFFu8)
            draw_point(x, y, color)
          end
        end
        draw_string(@fps_string, 1, 1, @font, fore: PF::Colors::White)
      end
    end
  end
end

PF::Static.new(50, 50, 6).run!
