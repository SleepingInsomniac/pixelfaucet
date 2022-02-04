module PF
  struct Envelope
    @attack_time : Float64 = 0.05
    @decay_time : Float64 = 0.1
    @sustain_level : Float64 = 0.8
    @release_time : Float64 = 0.5
    @initial_level : Float64 = 1.0

    @started_at : Float64 = 0.0
    @released_at : Float64? = nil
    @released : Bool = false
    @finished : Bool = false

    def initialize(@started_at : Float64, @attack_time = 0.05, @decay_time = 0.1, @sustain_level = 0.8, @release_time = 0.5)
    end

    def finished?
      @finished
    end

    def amplitude(time : Float64)
      amp = 0.0

      duration = time - @started_at

      if duration <= @attack_time
        # Attack phase
        amp = (duration / @attack_time) * @initial_level
      elsif duration > @attack_time && duration <= (@attack_time + @decay_time)
        # Decay phase
        amp = ((duration - @attack_time) / @decay_time) * (@sustain_level - @initial_level) + @initial_level
      else
        if released_at = @released_at
          duration = time - released_at

          if duration <= @release_time
            # Release phase
            amp = ((duration / @release_time) * (-@sustain_level)) + @sustain_level
          else
            @finished = true
            amp = 0.0
          end
        else
          # Sustain phase
          amp = @sustain_level
        end
      end

      amp < 0.0001 ? 0.0 : amp
    end

    def held?
      @released_at.nil?
    end

    def released?
      !@released_at.nil?
    end

    def release(time : Float64)
      @released_at = time
    end
  end
end
