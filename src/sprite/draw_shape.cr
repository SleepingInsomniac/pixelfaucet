module PF
  class Sprite
    # Draw lines enclosing a shape
    def draw_shape(frame : Enumerable(Point), pixel : Pixel = Pixel.new)
      0.upto(frame.size - 1) do |n|
        draw_line(frame[n], frame[(n + 1) % frame.size], pixel)
      end
    end
  end
end
