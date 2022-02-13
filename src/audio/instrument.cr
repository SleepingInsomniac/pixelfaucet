module PF
  class Instrument
    property name : String = "Unnamed Instrument"
    property envelope : Envelope
    property wave : Sound::Wave

    getter sounds : Array(Sound) = [] of Sound
    @notes : Hash(UInt32, Sound) = {} of UInt32 => Sound
    @note_id = 0_u32

    def initialize(@envelope, @wave)
    end

    def on(hertz : Float64, time : Float64)
      @note_id += 1_u32
      sound = Sound.new(hertz, @envelope, time, @wave)
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
      @envelope = Envelope.new(
        attack: Envelope::Stage.new(0.001, 0.0, 1.0),
        decay: Envelope::Stage.new(0.7, 1.0, 0.0),
        sustain: Envelope::Stage.new(0.0, 0.0, 0.0),
        release: Envelope::Stage.new(0.5, 1.0, 0.0)
      )
      @wave = Sound.triangle_wave(6.0, 0.0005)
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
end
