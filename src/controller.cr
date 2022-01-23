require "./lib_sdl"

module PF
  # Handle button to action mapping in a dynamic way
  class Controller(T)
    PRESSED = 0b0000001_u8
    READ    = 0b0000010_u8

    # Detect the current keyboard layout
    def self.detect_layout
      keys = String.build do |io|
        {
          LibSDL::Keycode::Q,
          LibSDL::Keycode::W,
          LibSDL::Keycode::Y,
        }.each do |key_code|
          scan_code = LibSDL.get_scancode_from_key(key_code)
          key_name = LibSDL.get_scancode_name(scan_code)
          io << String.new(key_name)
        end
      end

      case keys
      when "QWY"
        :qwerty
      when "X,T"
        :dvorak
      else
        :unknown
      end
    end

    def initialize(@mapping : Hash(T, String))
      @keysdown = {} of String => UInt8

      @mapping.values.each do |key|
        @keysdown[key] = 0
      end
    end

    # Map
    def map_event(event : SDL::Event?)
      case event
      when SDL::Event::Keyboard
        {% if T == LibSDL::Scancode %}
          press(event.scancode) if event.keydown?
          release(event.scancode) if event.keyup?
        {% elsif T == LibSDL::Keycode %}
          press(event.code) if event.keydown?
          release(event.code) if event.keyup?
        {% end %}
      end
    end

    def registered?(button)
      @mapping.keys.includes?(button)
    end

    def press(button)
      return nil unless registered?(button)
      @keysdown[@mapping[button]] |= PRESSED
    end

    def release(button)
      return nil unless registered?(button)
      @keysdown[@mapping[button]] = 0
    end

    # ===============

    def pressed?(name)
      return false if @keysdown[name] & READ != 0
      return false unless @keysdown[name] & PRESSED != 0
      @keysdown[name] |= READ
      true
    end

    def action?(name)
      @keysdown[name] & PRESSED > 0
    end

    def held?(name)
      @keysdown[name] & PRESSED > 0
    end
  end
end
