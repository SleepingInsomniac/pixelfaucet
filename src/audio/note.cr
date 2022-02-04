module PF
  struct Note
    TWELFTH_ROOT = 2 ** (1 / 12)
    NOTES        = %w[A AS B C CS D DS E F FS G GS]

    property note : Int8 = 0
    property octave : Int8 = 4

    def initialize
    end

    def initialize(@note, @octave = 4i8)
    end

    def name
      NOTES[@note % 12]
    end

    def base_hertz
      27.5 * (2 ** @octave)
    end

    def hertz
      base_hertz * (TWELFTH_ROOT ** @note)
    end

    def +(value : UInt8)
      octave_shift, note = (@note.to_i + value).divmod(12)
      octave = (@octave + octave_shift).clamp(0i8, 8i8)
      Note.new(@note + value, @octave)
    end

    def -(value : Int)
      octave_shift, note = (@note.to_i - value).divmod(12)
      octave = (@octave + octave_shift).clamp(0i8, 8i8)
      Note.new(note.to_i8, octave.to_i8)
    end

    # # Decabells to volume
    # def db_to_volume(db : Float64)
    #   10.0 ** (0.05 * db)
    # end
    #
    # # Volume to decabells
    # def volume_to_db(volume : Float64)
    #   20.0 * Math.log10f(volume)
    # end
  end
end
