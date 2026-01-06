require "../src/pixelfaucet"

class Audio < PF::Game
  @keys : PF::Keymap

  def initialize(*args, **kwargs)
    super(*args, **kwargs)

    @note = PF::Note.new(60)

    @keys = keymap({
      PF::Scancode::Up => "up",
      PF::Scancode::Down => "down"
    })

    @audio = PF::Audio.new do |time, channel|
      volume = 0.4
      Math.sin(2 * Math::PI * @note.hertz * time).to_f32 * volume
    end

    @audio.resume
  end

  def update(delta_time)
    if @keys.pressed?("up")
      @note = PF::Note.new(@note.number + 1)
    end

    if @keys.pressed?("down")
      @note = PF::Note.new(@note.number - 1)
    end
  end

  def frame(delta_time)
    window.draw do
      color = PF::RGBA.from_hsva((@note.number / 127) * 360.0, 1.0, 1.0, 1.0)
      window.clear(color)
    end
  end
end

Audio.new(640, 480).run!
