require "../src/game"
require "../src/lehmer32"

module PF
  class Proceedural < Game
    @buffer_size : Int32
    @buffer : Pointer(UInt32)
    @pan : Vector2(Float64) = PF::Vector[0.0, 0.0]
    @seed : UInt32

    def initialize(*args, **kwargs)
      super
      @buffer_size = width * height
      @buffer = screen.pixel_pointer(0, 0)
      @random = Lehmer32.new
      @redraw = true

      @controller = Controller(Keys).new({
        Keys::LEFT  => "left",
        Keys::RIGHT => "right",
        Keys::UP    => "up",
        Keys::DOWN  => "down",
      })
      plug_in @controller

      @speed = 100.0
      @seed = str_to_seed("PixelFaucet")
    end

    def str_to_seed(str : String)
      str.chars.map { |c| c.ord.to_u32! }.reduce(&.+)
    end

    def update(dt)
      @redraw = true if @controller.any_held?
      @pan.x += @speed * dt if @controller.held?("right")
      @pan.x -= @speed * dt if @controller.held?("left")
      @pan.y -= @speed * dt if @controller.held?("up")
      @pan.y += @speed * dt if @controller.held?("down")
    end

    def draw
      if @redraw
        @redraw = false
        start = elapsed_milliseconds
        0.upto(height) do |y|
          0.upto(width) do |x|
            seed = ((@pan.x.to_u32! &+ x).to_u32! & 0xFFFF) << 16 | ((@pan.y.to_u32! &+ y).to_u32! & 0xFFFF)
            @random.new_seed(seed)

            n = (y * width + x)

            if @random.rand(0..100) > 98
              b = @random.rand(0u8..0xFFu8)
              (@buffer + n).value = Pixel.new(b, b, b).to_u32
            else
              (@buffer + n).value = Pixel::Black.to_u32
            end
          end
        end
        time = elapsed_milliseconds - start
        draw_string("frame: #{time.round(2)}ms", 5, 5, Pixel::White, bg: Pixel::Black)
      end
    end
  end
end

PF::Proceedural.new(400, 300, 3).run!
