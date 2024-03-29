module PF
  class Audio
    alias Callback = Float64, UInt8 -> Float64
    # stored as a class variable to avoid garbage collection, since it's passed to a C function
    @@box : Pointer(Void)?
    @spec : LibSDL::AudioSpec
    @device_id : LibSDL::AudioDeviceID
    property volume = 0.5
    # https://dsp.stackexchange.com/questions/3581/algorithms-to-mix-audio-signals-without-clipping
    property headroom = 0.3
    delegate :freq, to: @spec
    @playing : Bool = false
    getter time : Float64 = 0.0
    @channel : UInt8 = 0u8

    def initialize(freq : Int32 = 44100, channels : UInt8 = 2, samples : UInt16 = 512, &callback : Callback)
      # Information to be passed to the audio callback
      boxed_data = Box.box({
        callback,
        (1 / freq) / channels, # the time per sample
        pointerof(@volume),
        pointerof(@time),
        pointerof(@channel),
        channels,
        pointerof(@headroom),
      })
      @@box = boxed_data

      @spec = LibSDL::AudioSpec.new(
        freq: freq,
        format: LibSDL::AUDIO_S16SYS,
        channels: channels,
        samples: samples,
        callback: ->(userdata : Void*, stream : UInt8*, len : Int32) {
          # Convert the stream into the correct type, AUDIO_S16SYS is a signed 16 bit integer
          stream = stream.as(Pointer(Int16))
          # Calculate the correct length in size of Int16 (according to audio spec AUDIO_S16SYS)
          length = len // (sizeof(Int16) // sizeof(UInt8))
          # Unbox the user callback and other data
          unboxed_data = Box(Tuple(typeof(callback), Float64, Float64*, Float64*, UInt8*, UInt8, Float64*)).unbox(userdata)
          user_callback, time_step, volume, time, channel, channel_count, headroom = unboxed_data
          # Iterate over the size of the buffer
          0.upto(length - 1) do |x|
            # Call the user callback and recieve the sample
            sample = user_callback.call(time.value, channel.value)
            # Channel is incremented every sample, because samples are interlaced
            channel.value = (channel.value + 1) % channel_count
            # Increment the time, time_step was calculated as 1 out of the audio frequency divided by number of channels
            time.value += time_step
            # Fill the buffer location with the sample
            # Make sure to convert the Float64 into a signed Int16 for compatability with the audio format
            (stream + x).value = (sample * Int16::MAX * volume.value * headroom.value).clamp(Int16::MIN, Int16::MAX).to_i16
          end
        },
        userdata: boxed_data
      )

      @device_id = LibSDL.open_audio_device(nil, 0, pointerof(@spec), pointerof(@spec), 0)
    end

    def playing?
      @playing
    end

    def play
      LibSDL.pause_audio_device(@device_id, 0)
      @playing = true
    end

    def pause
      LibSDL.pause_audio_device(@device_id, 1)
      @playing = false
    end

    def queue(sample : Int16)
      queue(pointerof(sample), 1)
    end

    def queue(sample : Int16*, length = 1)
      LibSDL.queue_audio(@device_id, sample, sizeof(typeof(sample)) * length)
    end

    def finalize
      LibSDL.close_audio(@device_id)
    end
  end
end
