require "../src/game"

module PF
  class Static < Game
    @buffer_size : Int32
    @buffer : Pointer(UInt32)

    def initialize(*args, **kwargs)
      super
      @buffer_size = width * height
      @buffer = screen.pixel_pointer(0, 0)
    end

    def update(dt)
    end

    def draw
      0.upto(@buffer_size) do |n|
        (@buffer + n).value = PF::Pixel.random.to_u32
      end
    end
  end
end

PF::Static.new(400, 300, 3).run!
