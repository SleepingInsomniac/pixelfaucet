module PF
  # Handle button to action mapping in a dynamic way
  class Controller(T)
    PRESSED = 0b0000001_u8
    READ    = 0b0000010_u8

    def initialize(@mapping : Hash(T, String))
      @keysdown = {} of String => UInt8

      @mapping.values.each do |key|
        @keysdown[key] = 0
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

    # Returns duration of time pressed or false if not pressed
    def action?(name)
      @keysdown[name] & PRESSED > 0
    end
  end
end
