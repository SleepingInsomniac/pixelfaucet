module PF
  class Sound
    private TWO_PI = 2 * Math::PI
    # Params: time, hertz
    alias Wave = Float32, Float32 -> Float32

    # Calculate a sine wave ~~~~~~~~
    def self.sin_wave(lfo_hertz : Float = 0.0, lfo_amp : Float = 0.0) : Wave
      ->(time : Float32, hertz : Float32) do
        amp = Math.sin(TWO_PI * hertz * time +
                 lfo_amp * hertz * Math.sin(TWO_PI * lfo_hertz * time))
        amp.to_f32
      end
    end

    # # Calculate a square wave _|-|_|-|_
    def self.square_wave(lfo_hertz : Float = 0.0, lfo_amp : Float = 0.0) : Wave
      ->(time : Float32, hertz : Float32) do
        amp = Math.sin(TWO_PI * hertz * time +
                 lfo_amp * hertz * Math.sin(TWO_PI * lfo_hertz * time)) > 0 ? 0.7 : -0.7
        amp.to_f32
      end
    end

    # Calculate a triangle wave /\/\/\/\/
    def self.triangle_wave(lfo_hertz : Float = 0.0, lfo_amp : Float = 0.0) : Wave
      ->(time : Float32, hertz : Float32) do
        amp = Math.asin(Math.sin(
          TWO_PI * hertz * time +
          lfo_amp * hertz * Math.sin(TWO_PI * lfo_hertz * time)
        )) * (2 / Math::PI)
        amp.to_f32
      end
    end

    # Calculate a sawtooth wave by addition of sine waves
    # the more *sins* specified, the closer the waveform will
    # match a straight sawtooth wave
    # /|/|/|/|
    def self.saw_wave(sins : Int, lfo_hertz : Float = 0.0, lfo_amp : Float = 0.0) : Wave
      ->(time : Float32, hertz : Float32) do
        value = 0.0
        n = 0.0
        while (n += 1.0) < sins
          value += Math.sin(TWO_PI * hertz * time + lfo_amp * hertz * Math.sin(TWO_PI * lfo_hertz * time)) / n
        end
        amp = value * (2.0 / Math::PI)
        amp.to_f32
      end
    end

    # Calculate a sawtooth wave
    # /|/|/|/|
    def self.saw_wave(lfo_hertz : Float = 0.0, lfo_amp : Float = 0.0) : Wave
      ->(time : Float32, hertz : Float32) do
        amp = (2.0 / Math::PI) * (hertz * Math::PI * (time % (1.0 / hertz)) - (Math::PI / 2.0))
        amp.to_f32
      end
    end

    property hertz : Float32
    property lfo_hertz : Float32 = 7.0_f32
    property lfo_amp : Float32 = 0.002_f32
    property envelope : Envelope
    property started_at : Float64
    property wave : Wave
    property released_at : Float64? = nil
    property volume : Float64 = 1.0

    def initialize(@hertz, @envelope, @started_at, @volume = 1.0, @wave = Sound.sin_wave)
    end

    def sample(time : Float)
      @wave.call(time.to_f32 - @started_at, @hertz) *
        @envelope.amplitude(time.to_f64, @started_at, @released_at) *
        @volume
    end

    def release!(time : Float)
      @released_at = time
    end

    def finished?(time : Float)
      return false unless release_time = @released_at
      (time - release_time) > @envelope.release.duration
    end
  end
end
