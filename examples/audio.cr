require "../src/pixelfaucet"
require "../src/audio"
require "../src/audio/note"

class Audio < PF::Game
  def initialize(*args, **kwargs)
    super(*args, **kwargs)

    @note = PF::Note.new(60)

    keymap({
      PF::Scancode::Up => "up",
      PF::Scancode::Down => "down"
    })

    @audio = PF::Audio.new do |time, channel|
      Math.sin(2 * Math::PI * @note.hertz * time).to_f32
    end

    @audio.resume
  end

  def update(delta_time)
    if pressed?("up")
      @note = PF::Note.new(@note.number + 1)
    end

    if pressed?("down")
      @note = PF::Note.new(@note.number - 1)
    end
  end

  def frame(delta_time)
    draw do
      color = PF::RGBA.from_hsva((@note.number / 127) * 360.0, 1.0, 1.0, 1.0)
      clear(color)
    end
  end
end

Audio.new(640, 480).run!
