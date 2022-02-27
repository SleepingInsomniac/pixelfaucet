module PF
  # Measures the Frames Per Second
  class Fps
    # the current FPS
    getter rate : UInt32 = 0
    # FPS calculated over this interval (in milliseconds)
    property interval : Float64 = 1000.0

    # The last recorded time
    @last_time : Float64 = Time.monotonic.total_milliseconds
    # Frames passed since the last recorded fps
    @count : UInt32 = 0
    # Called when the frame rate is updated
    @on_update : UInt32 -> = ->(rate : UInt32) {}

    def initialize(&@on_update : UInt32 ->)
    end

    def update(elapsed_time : Float64)
      @count += 1

      if @last_time < elapsed_time - @interval
        @last_time = elapsed_time
        @rate = @count
        @count = 0
        @on_update.call(@rate)
      end
    end
  end
end
