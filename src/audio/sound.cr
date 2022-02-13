module PF
  class Sound
    private TWO_PI = 2 * Math::PI
    # Params: time, hertz
    alias Wave = Float64, Float64 -> Float64

    # Calculate a sine wave ~~~~~~~~
    def self.sin_wave(lfo_hertz : Float64 = 0.0, lfo_amp : Float64 = 0.0) : Wave
      ->(time : Float64, hertz : Float64) do
        Math.sin(TWO_PI * hertz * time +
                 lfo_amp * hertz * Math.sin(TWO_PI * lfo_hertz * time))
      end
    end

    # # Calculate a square wave _|-|_|-|_
    def self.square_wave(lfo_hertz : Float64 = 0.0, lfo_amp : Float64 = 0.0) : Wave
      ->(time : Float64, hertz : Float64) do
        Math.sin(TWO_PI * hertz * time +
                 lfo_amp * hertz * Math.sin(TWO_PI * lfo_hertz * time)) > 0 ? 0.7 : -0.7
      end
    end

    # Calculate a triangle wave /\/\/\/\/
    def self.triangle_wave(lfo_hertz : Float64 = 0.0, lfo_amp : Float64 = 0.0) : Wave
      ->(time : Float64, hertz : Float64) do
        Math.asin(Math.sin(
          TWO_PI * hertz * time +
          lfo_amp * hertz * Math.sin(TWO_PI * lfo_hertz * time)
        )) * (2 / Math::PI)
      end
    end

    # Calculate a sawtooth wave by addition of sine waves
    # the more *sins* specified, the closer the waveform will
    # match a straight sawtooth wave
    # /|/|/|/|
    def self.saw_wave(sins : Int, lfo_hertz : Float64 = 0.0, lfo_amp : Float64 = 0.0) : Wave
      ->(time : Float64, hertz : Float64) do
        value = 0.0
        n = 0.0
        while (n += 1.0) < sins
          value += Math.sin(TWO_PI * hertz * time + lfo_amp * hertz * Math.sin(TWO_PI * lfo_hertz * time)) / n
        end
        value * (2.0 / Math::PI)
      end
    end

    # Calculate a sawtooth wave
    # /|/|/|/|
    def self.saw_wave(lfo_hertz : Float64 = 0.0, lfo_amp : Float64 = 0.0) : Wave
      ->(time : Float64, hertz : Float64) do
        (2.0 / Math::PI) * (hertz * Math::PI * (time % (1.0 / hertz)) - (Math::PI / 2.0))
      end
    end

    property hertz : Float64
    property lfo_hertz : Float64 = 7.0
    property lfo_amp : Float64 = 0.002
    property envelope : Envelope
    property started_at : Float64
    property wave : Wave
    property released_at : Float64? = nil

    def initialize(@hertz, @envelope, @started_at, @wave = Sound.sin_wave)
    end

    def sample(time : Float64)
      @wave.call(time - @started_at, @hertz) *
        @envelope.amplitude(time, @started_at, @released_at)
    end

    def release!(time : Float64)
      @released_at = time
    end

    def finished?(time : Float64)
      return false unless release_time = @released_at
      (time - release_time) > @envelope.release.duration
    end
  end
end
