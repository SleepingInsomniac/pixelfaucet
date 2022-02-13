module PF
  # Enevelope represents an ADSR cycle to control the amplitude of a sound throughout its lifecycle
  class Envelope
    # An Envelope::Stage is a slice of time within an enveleope (Either A,D,S, or R)
    struct Stage
      # Linear interpolation function
      def self.lerp
        ->(time : Float64, duration : Float64, initial : Float64, level : Float64) do
          initial + (time / duration) * (level - initial)
        end
      end

      # Pulsating linear interpolation
      def self.wavy_lerp(hertz : Float64 = 50, amount : Float64 = 0.7)
        ->(time : Float64, duration : Float64, initial : Float64, level : Float64) do
          lerp = (initial + (time / duration) * (level - initial))
          (1.0 - amount) * lerp * Math.sin(time * hertz) + (amount * lerp)
        end
      end

      # The length of time in seconds that this stage lasts
      property duration : Float64

      # The initial level of the amplitude
      property initial : Float64 = 0.0

      # The finial level of the amplitude
      property level : Float64 = 1.0

      # This function determines the shape of this stage (defaults to linear)
      # params: time, duration, initial, level
      property shape : Float64, Float64, Float64, Float64 -> Float64 = Stage.lerp

      def initialize(@duration, @initial = 1.0, @level = 1.0)
      end

      def initialize(@duration, @initial, @level, @shape)
      end

      def initialize(@duration, @initial = 1.0, @level = 1.0, &@shape : Float64, Float64, Float64, Float64 -> Float64)
      end

      # Get the amplitude for this stage for *time*
      # *time* should be relative to the start of this stage
      def amplitude(time : Float64)
        return 0.0 if time > @duration
        shape.call(time, @duration, @initial, @level)
      end
    end

    property attack : Stage = Stage.new(0.5, 0.0, 1.0)
    property decay : Stage = Stage.new(0.1, 1.0, 0.8)
    property sustain : Stage = Stage.new(Float64::INFINITY, 0.8, 0.8)
    property release : Stage = Stage.new(0.5, 1.0, 0.0)

    def initialize
    end

    def initialize(@attack, @decay, @sustain, @release)
    end

    # The length of time this envelope should last for
    # note: might be inifinite if sustain has an infinite duration
    def duration
      attack.duration + decay.duration + sustain.duration + release.duration
    end

    # Given a *relative_time* to when the current stage of the envelope was started,
    # returns the current stage (ADSR), along with the relative_time into that stage
    def stage(relative_time : Float64)
      return {@attack, relative_time} if relative_time < @attack.duration
      relative_time -= @attack.duration
      return {@decay, relative_time} if relative_time < @decay.duration
      relative_time -= @decay.duration
      return {@sustain, relative_time}
    end

    # Givin an absolute *time*, along with when the envelope was *started_at*, and *released_at?*
    # returns the current aplitude of the enveloped sound
    def amplitude(time : Float64, started_at : Float64, released_at : Float64? = nil)
      current_stage, relative_time = stage(time - started_at)
      amp = current_stage.amplitude(relative_time)

      if released_at
        # The release stage is calculated based on the time into the current stage
        amp * @release.amplitude(time - released_at)
      else
        amp
      end
    end
  end
end
