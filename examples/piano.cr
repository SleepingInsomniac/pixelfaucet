require "../src/game"
require "../src/controller"
require "../src/audio"
require "../src/audio/*"

module PF
  enum Instrument : UInt8
    RetroVoice
    PianoVoice
    DrumVoice
  end

  class RetroVoice < Voice
    def initialize(@note, time)
      @envelope = Envelope.new(time,
        attack_time: 0.01,
        decay_time: 0.1,
        sustain_level: 0.5,
        release_time: 0.5
      )
    end

    def hertz(time)
      envelope.amplitude(time) * (
        Oscilator.square(note.hertz, time, 7.0, 0.001)
      )
    end
  end

  class PianoVoice < Voice
    def initialize(@note, time)
      @envelope = Envelope.new(time,
        attack_time: 0.001,
        decay_time: 0.7,
        sustain_level: 0.0,
        release_time: 1.0
      )
    end

    def hertz(time)
      envelope.amplitude(time) * (
        Oscilator.triangle(note.hertz - 1.5, time - 0.33)
        Oscilator.saw(note.hertz, time, 5, 3.0, 0.000001) +
        Oscilator.triangle(note.hertz + 1.5, time + 0.33)
      ) / 3.0
    end
  end

  class DrumVoice < Voice
    def initialize(@note, time)
      @envelope = Envelope.new(time,
        attack_time: 0.01,
        decay_time: 1.0,
        sustain_level: 0.0,
        release_time: 0.1
      )
    end

    def hertz(time)
      envelope.amplitude(time) * (
        Oscilator.noise(note.hertz + Math.sin(time / 10), time)
      )
    end
  end

  class Piano < Game
    @key_size : Int32
    @key_width : Int32
    @middle : Int32
    @keys : UInt32 = 15
    @base_octave : Int8 = 4
    @accidentals : StaticArray(UInt8, 12) = StaticArray[0u8, 1u8, 0u8, 0u8, 1u8, 0u8, 1u8, 0u8, 0u8, 1u8, 0u8, 1u8]
    @highlight : Pixel = Pixel.new(120, 120, 120)
    @text_hl : Pixel = Pixel.new(0, 200, 255)
    @instrument : Instrument = Instrument::RetroVoice

    def initialize(*args, **kwargs)
      super

      @key_size = height // 2 - 25
      @key_width = width // 10
      @middle = (height // 2) + 25

      @text_color = Pixel.new(127, 127, 127)
      @controller = PF::Controller(Keys).new({
        Keys::UP     => "up",
        Keys::DOWN   => "down",
        Keys::KEY_1  => "1",
        Keys::KEY_2  => "2",
        Keys::KEY_3  => "3",
        Keys::KEY_4  => "4",
        Keys::KEY_5  => "5",
        Keys::KEY_6  => "6",
        Keys::KEY_7  => "7",
        Keys::KEY_8  => "8",
        Keys::KEY_9  => "9",
        Keys::KEY_0  => "0",
        Keys::Z      => "A",
        Keys::S      => "AS",
        Keys::X      => "B",
        Keys::C      => "C",
        Keys::F      => "CS",
        Keys::V      => "D",
        Keys::G      => "DS",
        Keys::B      => "E",
        Keys::N      => "F",
        Keys::J      => "FS",
        Keys::M      => "G",
        Keys::K      => "GS",
        Keys::COMMA  => "A+",
        Keys::L      => "AS+",
        Keys::PERIOD => "B+",
        Keys::SLASH  => "C+",
      })

      @sounds = [] of Voice
      @keysdown = {} of String => Voice

      @audio = Audio.new(channels: 1) do |time, channel|
        @sounds.reduce(0.0) do |total, sound|
          total + sound.hertz(time)
        end
      end

      @audio.play

      @white_keys = [] of Tuple(Vector2(Int32), Vector2(Int32), String)
      @black_keys = [] of Tuple(Vector2(Int32), Vector2(Int32), String)

      pos = 0
      (Note::NOTES + %w[A+ AS+ B+ C+]).map_with_index do |name, i|
        if @accidentals[i % 12] == 0
          top_left = Vector[@key_width * pos, @middle - @key_size]
          bottom_right = Vector[(@key_width * pos) + @key_width, @middle + @key_size]
          @white_keys << {top_left, bottom_right, name}
          pos += 1
        else
          shrinkage = (@key_width // 8)
          left = (@key_width * pos) - (@key_width // 2) + shrinkage
          top_left = Vector[left, @middle - @key_size]
          bottom_right = Vector[left + @key_width - (shrinkage * 2), @middle]
          @black_keys << {top_left, bottom_right, name}
        end
      end
    end

    def update(dt, event)
      @controller.map_event(event)

      @base_octave = ((@base_octave + 1) % 8) if @controller.pressed?("up")
      @base_octave = ((@base_octave - 1) % 8) if @controller.pressed?("down")
      @instrument = Instrument::RetroVoice if @controller.pressed?("1")
      @instrument = Instrument::PianoVoice if @controller.pressed?("2")
      @instrument = Instrument::DrumVoice if @controller.pressed?("3")

      {% for name, n in Note::NOTES + %w[A+ AS+ B+ C+] %}
        if @controller.pressed?({{name}})
          voice = case @instrument
          when Instrument::RetroVoice
            RetroVoice.new(Note.new({{n}}_i8, @base_octave), @audio.time)
          when Instrument::PianoVoice
            PianoVoice.new(Note.new({{n}}_i8, @base_octave), @audio.time)
          when Instrument::DrumVoice
            DrumVoice.new(Note.new({{n}}_i8, @base_octave), @audio.time)
          else
            PianoVoice.new(Note.new({{n}}_i8, @base_octave), @audio.time)
          end
          @keysdown[{{name}}] = voice
          @sounds << voice
        end

        if @controller.released?({{name}})
          @keysdown[{{name}}].release(@audio.time)
          @keysdown.delete({{name}})
        end
      {% end %}

      @sounds.reject!(&.finished?)
    end

    def draw
      clear

      text = <<-TEXT
      Press up/down to change octave, Bottom row of keyboard plays notes
      1 : RetroVoice, 2 : PianoVoice
      Octave: #{@base_octave}, Voice : #{@instrument}
      TEXT
      draw_string(text, 5, 5, @text_color)

      @white_keys.each do |key|
        top_left, bottom_right, name = key
        fill_rect(top_left, bottom_right, @keysdown[name]? ? @highlight : Pixel.white)
        draw_rect(top_left, bottom_right, Pixel.new(127, 127, 127))
        draw_string(name, top_left.x + 2, top_left.y + (@key_size * 2) - Sprite::CHAR_HEIGHT - 2, @keysdown[name]? ? @text_hl : @text_color)
      end

      @black_keys.each do |key|
        top_left, bottom_right, name = key
        fill_rect(top_left, bottom_right, @keysdown[name]? ? @highlight : Pixel.black)
        draw_rect(top_left, bottom_right, Pixel.new(127, 127, 127))
        draw_string(name, top_left.x + 2, top_left.y + @key_size - Sprite::CHAR_HEIGHT - 2, @keysdown[name]? ? @text_hl : @text_color)
      end

      fill_rect(0, @middle - @key_size - 2, width, @middle - @key_size, Pixel.new(200, 20, 20))
    end
  end
end

game = PF::Piano.new(500, 200, 2)
game.run!
