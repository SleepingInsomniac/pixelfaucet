require "sdl"

module SDL
  class Surface
    def pixels
      surface.pixels
    end
  end

  abstract struct Event
    struct Keyboard < Event
      def scancode
        _event.keysym.scancode
      end
    end
  end
end
