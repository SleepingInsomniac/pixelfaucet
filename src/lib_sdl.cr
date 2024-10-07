require "sdl"

lib LibSDL
  fun queue_audio = SDL_QueueAudio(dev : AudioDeviceID, data : Int16*, len : UInt32)
end

module SDL
  class Surface
    def pixels
      surface.pixels
    end
  end
end
