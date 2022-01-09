require "../src/lib_sdl"
require "../src/pixel"

FPS_INTERVAL = 1.0
width = 400
height = 300
scale = 1

fps_lasttime : Float64 = Time.monotonic.total_milliseconds # the last recorded time.
fps_current : UInt32 = 0                                   # the current FPS.
fps_frames : UInt32 = 0                                    # frames passed since the last recorded fps.
last_time : Float64 = Time.monotonic.total_milliseconds

begin
  SDL.init(SDL::Init::VIDEO)

  window = SDL::Window.new("test", width * scale, height * scale, flags: SDL::Window::Flags::SHOWN)
  renderer = SDL::Renderer.new(window, flags: SDL::Renderer::Flags::ACCELERATED)
  raw_texture = LibSDL.create_texture(renderer, LibSDL::PixelFormatEnum::RGBA8888, LibSDL::TextureAccess::STREAMING, width, height)
  texture = SDL::Texture.new(raw_texture)

  fps_frames = 0

  loop do
    case event = SDL::Event.poll
    when SDL::Event::Quit
      break
    end

    et = Time.monotonic.total_milliseconds

    fps_frames += 1
    if fps_lasttime < et - FPS_INTERVAL * 1000
      fps_lasttime = et
      fps_current = fps_frames
      fps_frames = 0
      puts String.build { |io| io << fps_current << " fps" }
    end

    last_time = et

    pitch = uninitialized Int32
    pixels_pointer = uninitialized Void*

    LibSDL.lock_texture(texture, nil, pointerof(pixels_pointer), pointerof(pitch))
    pixels = Slice.new(Pointer(UInt32).new(pixels_pointer.address), width * height)

    0.upto(pixels.size - 1) do |n|
      pixels[n] = PF::Pixel.random.to_u32
    end

    LibSDL.unlock_texture(texture)

    renderer.copy(texture)
    renderer.present
  end
ensure
  SDL.quit
end
