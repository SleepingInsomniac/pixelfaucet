module PF
  # Manage the timing of frames in an animation
  class FrameTimer
    getter frame : Int32
    @frame_time : Float64
    @frame_count : Int32
    @sub_frame : Float64 = 0.0

    def initialize(fps : Float64, @frame_count, @frame = 0)
      @frame_time = 1.0 / fps
    end

    # Update the timing given a delta time *dt*
    def update(dt : Float64)
      @sub_frame += dt
      if @sub_frame > @frame_time
        @sub_frame = @sub_frame % @frame_time
        @frame = (@frame + 1) % @frame_count
      end
    end
  end
end
