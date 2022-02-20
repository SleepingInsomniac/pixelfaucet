module PF
  class Instrument
    property name : String = "Unnamed Instrument"
    property envelope : Envelope
    property wave : Sound::Wave
    property volume : Float64 = 1.0

    getter sounds : Array(Sound) = [] of Sound
    @notes : Hash(UInt32, Sound) = {} of UInt32 => Sound
    @note_id = 0_u32

    def initialize(@envelope, @wave)
    end

    def on(hertz : Float64, time : Float64)
      @note_id += 1_u32
      sound = Sound.new(hertz, @envelope, time, @volume, @wave)
      @notes[@note_id] = sound
      @sounds << sound
      @note_id
    end

    def off(note_id : UInt32, time : Float64)
      sound = @notes[note_id]
      sound.release!(time)

      spawn do
        sleep @envelope.release.duration
        @sounds.delete(sound)
        @notes.delete(note_id)
      end
    end
  end

  class RetroVoice < Instrument
    def initialize
      @name = "Retro"
      @envelope = Envelope.new(
        attack: Envelope::Stage.new(0.01, 0.0, 1.0),
        decay: Envelope::Stage.new(0.1, 1.0, 0.5),
        sustain: Envelope::Stage.new(Float64::INFINITY, 0.5, 0.5),
        release: Envelope::Stage.new(0.5, 1.0, 0.0)
      )
      @wave = Sound.saw_wave(7.0, 0.001)
    end
  end

  class PianoVoice < Instrument
    def initialize
      @name = "Piano"

      exp_interpolation = ->(time : Float64, duration : Float64, initial : Float64, level : Float64) do
        # https://www.desmos.com/calculator/r2jn9wurwv
        curve = 1000
        (initial - level) * ((curve ** -(time / duration)) * (1 + (1 / curve)) - (1 / curve)) + level
      end

      @envelope = Envelope.new(
        attack: Envelope::Stage.new(0.001, 0.0, 1.0, exp_interpolation),
        decay: Envelope::Stage.new(3.0, 1.0, 0.0, exp_interpolation),
        sustain: Envelope::Stage.new(0.0, 0.0, 0.0),
        release: Envelope::Stage.new(0.3, 1.0, 0.0)
      )

      @wave = ->(time : Float64, hertz : Float64) do
        # https://www.desmos.com/calculator/mnxargxllk
        av = 2 * Math::PI * hertz * time
        y = (Math.sin(Math::PI * (av / Math::PI)) ** 3) + Math.sin(Math::PI * ((av / Math::PI) + (2 / 3)))
        y = (Math.sin(av) ** 3) + Math.sin(av + 0.6666)
        y += y / 2
        y += y / 4
        y += y / 8
        y += y / 16
        y += y / 32
        y /= 5
      end
    end
  end

  class Flute < Instrument
    def initialize
      @name = "Flute"
      @envelope = Envelope.new(
        attack: Envelope::Stage.new(0.1, 0.0, 1.0),
        decay: Envelope::Stage.new(0.3, 1.0, 0.7),
        sustain: Envelope::Stage.new(5.0, 0.7, 0.0),
        release: Envelope::Stage.new(0.5, 1.0, 0.0)
      )
      @wave = Sound.sin_wave(5.0, 0.001)
    end
  end

  class KickDrum < Instrument
    def initialize
      @name = "KickDrum"
      @envelope = Envelope.new(
        attack: Envelope::Stage.new(0.0005, 0.0, 1.0),
        decay: Envelope::Stage.new(0.052, 1.0, 0.0, Envelope::Stage.wavy_lerp(60, 1.0)),
        sustain: Envelope::Stage.new(0.0, 0.0, 0.0),
        release: Envelope::Stage.new(0.3, 1.0, 0.0)
      )
      @wave = ->(time : Float64, hertz : Float64) do
        hertz = 180.31
        av = 2 * Math::PI * (hertz / 2.0) * time
        drop_time = 10.0
        drop = (drop_time - time) / drop_time
        Math.cos(av * drop - 1.0) * 3.0
      end
    end
  end

  class SnareDrum < Instrument
    def initialize
      @name = "SnareDrum"
      @envelope = Envelope.new(
        attack: Envelope::Stage.new(0.0005, 0.0, 1.0),
        decay: Envelope::Stage.new(0.052, 1.0, 0.0, Envelope::Stage.wavy_lerp(60, 1.0)),
        sustain: Envelope::Stage.new(0.0, 0.0, 0.0),
        release: Envelope::Stage.new(0.3, 1.0, 0.0)
      )
      @wave = ->(time : Float64, hertz : Float64) do
        av = 2 * Math::PI * (hertz / 2.0) * time
        drop_time = 10.0
        drop = (drop_time - time) / drop_time
        Math.cos(av * drop - 1.0) * 3.0 + rand(-0.2..0.2)
      end
    end
  end

  class Harmonica < Instrument
    def initialize
      @name = "Harmonica"
      @envelope = Envelope.new(
        attack: Envelope::Stage.new(0.1, 0.0, 1.0),
        decay: Envelope::Stage.new(0.3, 1.0, 0.8),
        sustain: Envelope::Stage.new(Float64::INFINITY, 0.8, 0.8),
        release: Envelope::Stage.new(0.3, 1.0, 0.0)
      )
      @volume = 0.5
      wave = Sound.square_wave
      @wave = ->(time : Float64, hertz : Float64) do
        0.5 * wave.call(time + 0.1, hertz * 2) +
        wave.call(time, hertz) +
        rand(-0.05..0.05)
      end
    end
  end
end
