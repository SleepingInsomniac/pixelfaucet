require "./frame_timer"

module PF
  class Animation
    @frames : Array(Sprite)
    @frame_timer : FrameTimer
    getter width : Int32
    getter height : Int32

    def initialize(sheet : String, @width, @height, fps : Float64)
      @frames = Sprite.load_tiles(sheet, width, height)
      @frame_timer = FrameTimer.new(fps: fps, frame_count: @frames.size)
    end

    def size
      current_frame.size
    end

    def frame
      @frame_timer.frame
    end

    def current_frame
      @frames[frame]
    end

    def update(dt : Float64)
      @frame_timer.update(dt)
    end

    def draw_to(sprite : Sprite, x : Int, y : Int)
      current_frame.draw_to(sprite, x, y)
    end

    def draw_to(sprite : Sprite, pos : Vector2(Int))
      draw_to(sprite, pos.x, pos.y)
    end
  end
end
