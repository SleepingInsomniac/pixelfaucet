require "./frame_timer"

module PF
  class Animation
    getter frames : Array(Sprite)
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

    def update(delta_time)
      @frame_timer.update(delta_time)
    end
  end
end
