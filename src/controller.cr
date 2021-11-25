module PF
  # Handle button to action mapping in a dynamic way
  class Controller(T)
    def initialize(@mapping : Hash(T, String))
      @keysdown = {} of String => Bool

      @mapping.values.each do |key|
        @keysdown[key] = false
      end
    end

    def registered?(button)
      @mapping.keys.includes?(button)
    end

    def press(button)
      return nil unless registered?(button)
      @keysdown[@mapping[button]] = true
    end

    def release(button)
      return nil unless registered?(button)
      @keysdown[@mapping[button]] = false
    end

    # Returns duration of time pressed or false if not pressed
    def action?(name)
      @keysdown[name]
    end
  end
end
