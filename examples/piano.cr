require "../src/pixelfaucet"
require "../src/audio"
require "../src/audio/*"

class Piano < PF::Game
  include PF

  @font = Pixelfont::Font.new("#{__DIR__}/../lib/pixelfont/fonts/pixel-5x7.txt")
  @instrument : UInt8 = 0
  @base_note : UInt8 = 69 # (in MIDI) - A4 / 440.0Hz

  # Variables for drawing the piano keys
  @highlight : RGBA = RGBA.new(120, 120, 120)
  @text_hl : RGBA = RGBA.new(0, 200, 255)
  @key_size : Int32
  @key_width : Int32
  @middle : Int32
  @keys : UInt32 = 16
  @white_keys = [] of Tuple(PF2d::Vec2(Int32), PF2d::Vec2(Int32), String)
  @black_keys = [] of Tuple(PF2d::Vec2(Int32), PF2d::Vec2(Int32), String)
  @keymap : Keymap

  @instruments : Array(Instrument) = [RetroVoice.new, SineVoice.new, PianoVoice.new, Flute.new, KickDrum.new, SnareDrum.new, Harmonica.new]

  def initialize(*args, **kwargs)
    super

    @keymap = keymap({
      Scancode::E     => "echo",
      Scancode::Up    => "octave up",
      Scancode::Down  => "octave down",
      Scancode::Left  => "prev inst",
      Scancode::Right => "next inst",

      Scancode::Z          => "A",
      Scancode::S          => "A#/Bb",
      Scancode::X          => "B",
      Scancode::C          => "C",
      Scancode::F          => "C#/Db",
      Scancode::V          => "D",
      Scancode::G          => "D#/Eb",
      Scancode::B          => "E",
      Scancode::N          => "F",
      Scancode::J          => "F#/Gb",
      Scancode::M          => "G",
      Scancode::K          => "G#/Ab",
      Scancode::Comma      => "A+",
      Scancode::L          => "A#/Bb+",
      Scancode::Period     => "B+",
      Scancode::Slash      => "C+",
      Scancode::Apostrophe => "C#/Db+",
    })

    @text_color = RGBA.new(127, 127, 127)
    @sounds = [] of Sound
    @keysdown = {} of String => Tuple(Instrument, UInt32)
    @echo = false

    echo_effect = EchoEffect.new(Audio::DEFAULT_SPEC.freq // 3)

    # Initialize an audio handler
    # - the given Proc will be called at the sample rate/freq param (44.1Khz is standard)
    # - the channel variable describes which speaker the sample is for
    @audio = Audio.new do |time, channel|
      value = 0.0

      @instruments.each do |instrument|
        instrument.sounds.each do |sound|
          value += sound.sample(time.to_f)
        end
      end

      if @echo
        echo_effect.apply(value).to_f32
      else
        value.to_f32
      end * 0.5
    end

    @key_size = window.height // 2 - 25
    @key_width = window.width // 10
    @middle = (window.height // 2) + 25

    calculate_keys

    # Without this, the audio will not make noise
    @audio.resume
  end

  def calculate_keys(base : UInt8 = @base_note)
    pos = 0

    while @white_keys.size > 0
      @white_keys.pop
    end

    while @black_keys.size > 0
      @black_keys.pop
    end

    0.upto(@keys) do |n|
      note = Note.new(@base_note + n)
      name = n > 11 ? note.name + "+" : note.name

      unless note.accidental?
        # Calculate the position of a white key
        top_left = PF2d::Vec[@key_width * pos, @middle - @key_size]
        bottom_right = PF2d::Vec[(@key_width * pos) + @key_width, @middle + @key_size]
        @white_keys << {top_left, bottom_right, name}
        # position from the left is increased by 1 for every white key
        pos += 1
      else
        # Calculate the position of a black key
        # Black keys are thinner than white keys (space in between the black keys)
        shrinkage = (@key_width // 8)
        # black keys are at the same position as the last, but half as tall and offset by half the width.
        left = (@key_width * pos) - (@key_width // 2) + shrinkage
        top_left = PF2d::Vec[left, @middle - @key_size]
        bottom_right = PF2d::Vec[left + @key_width - (shrinkage * 2), @middle]
        @black_keys << {top_left, bottom_right, name}
      end
    end
  end

  def update(delta_time)
    @base_note += 12 if @keymap.pressed?("octave up") && @base_note <= 112
    @base_note -= 12 if @keymap.pressed?("octave down") && @base_note >= 21 + 12

    if @keymap.pressed?("echo")
      @echo = !@echo
    end

    if @keymap.pressed?("next inst")
      @instrument = (@instrument + 1) % @instruments.size
    end

    if @keymap.pressed?("prev inst")
      @instrument = @instruments.size.to_u8 if @instrument == 0
      @instrument -= 1
    end

    0.upto(@keys) do |n|
      note = Note.new(n + @base_note)
      name = n > 11 ? note.name + "+" : note.name

      if @keymap.pressed?(name)
        note_id = @instruments[@instrument].on(note.hertz, @audio.time)
        @keysdown[name] = {@instruments[@instrument], note_id}
      end

      if @keymap.released?(name)
        if tuple = @keysdown.[name]?
          instrument, note_id = tuple
          instrument.off(note_id, @audio.time)
          @keysdown.delete(name)
        end
      end
    end
  end

  def frame(delta_time)
    window.draw do
      window.clear

      window.draw_string(<<-TEXT, 5, 5, @font, @text_color)
        Press up/down to change octave, Bottom row of keyboard plays notes
        #{@instruments.map(&.name).join(", ")}
        Octave: #{@base_note // 12 - 1}, Voice: #{@instruments[@instrument].name}, Echo: #{@echo ? "on" : "off"}
        #{@instruments[@instrument].sounds.map { |s| s.hertz.round(2) }}
      TEXT

      @white_keys.each do |key|
        top_left, bottom_right, name = key
        window.fill_rect(top_left, bottom_right, @keysdown[name]? ? @highlight : Colors::White)
        window.draw_rect(top_left, bottom_right, RGBA.new(127, 127, 127))
        window.draw_string(name, top_left.x + 2, top_left.y + (@key_size * 2) - @font.line_height - 2, @font, @keysdown[name]? ? @text_hl : @text_color)
      end

      @black_keys.each do |key|
        top_left, bottom_right, name = key
        window.fill_rect(top_left, bottom_right, @keysdown[name]? ? @highlight : Colors::Black)
        window.draw_rect(top_left, bottom_right, RGBA.new(127, 127, 127))
        window.draw_string(name, top_left.x + 2, top_left.y + @key_size - @font.line_height - 2, @font, @keysdown[name]? ? @text_hl : @text_color)
      end

      window.fill_rect(0, @middle - @key_size - 2, window.width, @middle - @key_size, RGBA.new(200, 20, 20))
    end
  end
end

game = Piano.new(500, 200, 2)
game.run!
