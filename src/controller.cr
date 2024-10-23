module PF
  alias Keys = LibSDL::Scancode
  alias KeyCodes = LibSDL::Keycode

  # Handle button to action mapping in a dynamic way
  class Controller(T)
    @[Flags]
    enum State : UInt8
      Unset    = 0
      Pressed
      Released
      Read
    end

    # Detect the current keyboard layout
    def self.detect_layout
      keys = String.build do |io|
        {
          KeyCodes::Q,
          KeyCodes::W,
          KeyCodes::Y,
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
      @keysdown = {} of String => State

      @mapping.values.each do |key|
        @keysdown[key] = State::Unset
      end
    end

    # Map
    def map_event(event : SDL::Event?)
      case event
      when Event::Keyboard
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
      return nil if @keysdown[@mapping[button]] & State::Pressed == State::Pressed
      @keysdown[@mapping[button]] = State::Pressed
    end

    def release(button)
      return nil unless registered?(button)
      return nil unless @keysdown[@mapping[button]] & State::Pressed == State::Pressed
      @keysdown[@mapping[button]] = State::Released
    end

    # ===============

    def any_held?
      @keysdown.any? { |name, state| state & State::Pressed == State::Pressed }
    end

    def none_held?
      !any_held?
    end

    # Returns true the first time called if a button has been pressed
    def pressed?(name)
      return false if @keysdown[name] & State::Read == State::Read
      return false unless @keysdown[name] & State::Pressed == State::Pressed
      @keysdown[name] |= State::Read
      true
    end

    # Returns true if a registered button is being held
    def held?(name)
      @keysdown[name] & State::Pressed == State::Pressed
    end

    # Returns true the first time called after a button has been released
    def released?(name)
      return false unless @keysdown[name] & State::Released == State::Released
      return false if @keysdown[name] & State::Read == State::Read
      @keysdown[name] |= State::Read
      true
    end
  end
end
