require "../src/game"
require "../src/lehmer32"
require "../src/pixel_text"
require "../src/controller"

module PF
  class Proceedural < Game
    @buffer_size : Int32
    @buffer : Pointer(UInt32)
    @text = PF::PixelText.new("assets/pf-font.png")
    @pan : PF::Vector2(Float64) = PF::Vector[0.0, 0.0]
    @seed : UInt32

    def initialize(*args, **kwargs)
      super
      @buffer_size = width * height
      @buffer = screen.pixel_pointer(0, 0)
      @random = Lehmer32.new
      @redraw = true
      @text.color(PF::Pixel.new(255, 255, 255))

      @controller = PF::Controller(LibSDL::Scancode).new({
        LibSDL::Scancode::LEFT  => "left",
        LibSDL::Scancode::RIGHT => "right",
        LibSDL::Scancode::UP    => "up",
        LibSDL::Scancode::DOWN  => "down",
      })

      @speed = 100.0
      @seed = str_to_seed("PixelFaucet")
    end

    def str_to_seed(str : String)
      str.chars.map { |c| c.ord.to_u32! }.reduce(&.+)
    end

    def update(dt, event)
      @controller.map_event(event)
      @redraw = true if @controller.any_pressed?
      @pan.x += @speed * dt if @controller.held?("right")
      @pan.x -= @speed * dt if @controller.held?("left")
      @pan.y -= @speed * dt if @controller.held?("up")
      @pan.y += @speed * dt if @controller.held?("down")
    end

    def draw
      if @redraw
        @redraw = false
        start = elapsed_time
        0.upto(height) do |y|
          0.upto(width) do |x|
            seed = ((@pan.x.to_u32! &+ x).to_u32! & 0xFFFF) << 16 | ((@pan.y.to_u32! &+ y).to_u32! & 0xFFFF)
            @random.new_seed(seed)

            n = (y * width + x)

            if @random.rand(0..100) > 98
              b = @random.rand(0u8..0xFFu8)
              (@buffer + n).value = Pixel.new(b, b, b).to_u32
            else
              (@buffer + n).value = Pixel.black.to_u32
            end
          end
        end
        time = elapsed_time - start
        @text.draw_to(@screen, "frame: #{time.round(2)}ms", 5, 5, bg: Pixel.black)
      end
    end
  end
end

PF::Proceedural.new(400, 300, 3).run!
