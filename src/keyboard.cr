require "./key"

module PF
  class Keyboard
    macro [](*args)
      {{@type}}.instance[{{args.splat}}]
    end

    @@instance : self?

    def self.instance
      @@instance ||= new
    end

    getter keys = {} of Key::Code | String => Key
    property keymap = {} of Key::Code => String

    private def initialize
    end

    def map(code : Key::Code, string : String)
      keymap[code] = string
    end

    def map(mappings : Hash(Key::Code, String))
      mappings.each { |code, string| map(code, string) }
    end

    def register(event : Sdl3::Event::Keyboard)
      lookup = keymap[event.scancode]? || event.scancode
      key = self[lookup]
      if event.repeat?
        key.repeat = event.repeat?
      else
        key.down = event.down?
      end
    end

    def any_held?
      keys.values.any?(&.held?)
    end

    def [](code : Key::Code | String)
      keys[code] ||= Key.new
    end
  end
end
