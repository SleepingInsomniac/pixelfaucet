module PF
  class Audio
    alias Spec = Sdl3::Audio::Spec
    alias Format = Sdl3::Audio::Format
    alias Device = Sdl3::Audio::Device
    alias Stream = Sdl3::Audio::Stream

    DEFAULT_SPEC = Spec.new(
      channels: 2,
      format: Format::F32,
      freq: 48000
    )

    @spec : Spec
    @device : Device
    @callback : Float32, Int32 -> Float32
    @sample = 0u64
    @buffer : Slice(Float32)
    @target : Time::Span
    @time_per_sample : Time::Span
    @refill_bytes : Int32
    @target_bytes : Int32

    def self.playback_devices
      Device.playback_devices
    end

    def initialize(
      @spec = DEFAULT_SPEC,
      @device = Device.default_playback,
      @chunk = 3.milliseconds,
      @target = 25.milliseconds,
      @refill_at = 10.milliseconds,
      &@callback : Float32, Int32 -> Float32
    )
      @stream = Stream.open(@device, @spec)
      @time_per_sample = (1.0 / @spec.freq).seconds
      @buffer_frames = (@chunk / @time_per_sample).ceil.to_i
      @buffer = Slice(Float32).new(@buffer_frames * @spec.channels)

      @refill_bytes = (@refill_at / @time_per_sample).ceil.to_i * @spec.channels * Sdl3::Audio.bytes_per_sample(@spec.format)
      @target_bytes = (@target / @time_per_sample).ceil.to_i * @spec.channels * Sdl3::Audio.bytes_per_sample(@spec.format)

      spawn do
        fill_buffer
        loop do
          fill unless @stream.paused?
          Fiber.yield
        end
      end
    end

    def pause
      @stream.pause
    end

    def paused?
      @stream.paused?
    end

    def resume
      @stream.resume
    end

    def queued_time
      samples = (@stream.queued // Sdl3::Audio.bytes_per_sample(@spec.format) // @spec.channels)
      @time_per_sample * samples
    end

    def fill
      if @stream.queued < @refill_bytes
        while @stream.queued < @target_bytes
          fill_buffer
        end
      end
    end

    def time
      @sample / @spec.freq
    end

    private def fill_buffer
      i = 0
      (0...@buffer_frames).each do |f|
        (0...@spec.channels).each do |c|
          @buffer[i] = @callback.call(time.to_f32, c)
          i += 1
        end
        @sample += 1
      end

      @stream.put_data(@buffer)
    end
  end
end
