require "sdl"

@[Link("SDL2")]
lib LibSDL
end

module SDL
  class Surface
    def pixels
      surface.pixels
    end
  end
end
