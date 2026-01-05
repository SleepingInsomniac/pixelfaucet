module PF
  # Manage the timing of frames in an animation
  class FrameTimer
    getter frame : Int32
    getter frame_count : Int32
    getter interval : Interval

    def initialize(fps : Float64, @frame_count, @frame = 0)
      @interval = Interval.new(1.0.seconds / fps)
    end

    # Update the timing given a delta time
    def update(delta_time : Time::Span)
      @interval.update(delta_time) { @frame = (@frame + 1) % @frame_count }
    end
  end
end
