module PF
  struct Note
    TWELFTH_ROOT = 2 ** (1 / 12)
    NAMES        = %w[C C#/Db D D#/Eb E F F#/Gb G G#/Ab A A#/Bb B]
    ACCIDENTALS  = StaticArray[1u8, 3u8, 6u8, 8u8, 10u8]

    getter tuning : Float64 = 440.0
    getter number : Float64
    @hertz : Float64? = nil
    @index : UInt8? = nil
    @name : String? = nil
    @is_accidental : Bool? = nil

    def initialize(@number, @tuning = 440.0)
    end

    def initialize(number : Number, tuning : Number = 440.0)
      @number, @tuning = number.to_f, tuning.to_f
    end

    def name
      @name ||= NAMES[index]
    end

    def index
      @index ||= @number.to_u8 % 12
    end

    def octave
      (@number.to_i // 12) - 1
    end

    def accidental?
      @is_accidental ||= ACCIDENTALS.includes?(index)
    end

    def hertz
      @hertz ||= tuning * ((2 ** ((@number - 69) / 12)))
    end

    def tuning=(value : Float64)
      Note.new(@number, value)
    end

    def note=(value : Float64)
      Note.new(value, @tuning)
    end

    def +(value : Float64)
      Note.new(@number + value, tuning)
    end

    def -(value : Float64)
      Note.new(@number - value, tuning)
    end

    def *(value : Float64)
      Note.new(@number * value, tuning)
    end

    def /(value : Float64)
      Note.new(@number / value, tuning)
    end

    # # Decabells to volume
    # def db_to_volume(db : Float64)
    #   10.0 ** (0.05 * db)
    # end

    # # Volume to decabells
    # def volume_to_db(volume : Float64)
    #   20.0 * Math.log(volume, 10)
    # end
  end
end
