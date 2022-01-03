require "../src/game"
require "../src/pixel_text"

class TextGame < PF::Game
  @text : PF::PixelText

  def initialize(*args)
    super
    @text = PF::PixelText.new("assets/pf-font.png")
    @text.color(PF::Pixel.new(255, 255, 255))
    @x = 0.0
    @y = 0.0
    @dx = 50.0
    @dy = 50.0
    @msg = "Hello, World!"
  end

  def update(dt, event)
    @x += @dx * dt
    @y += @dy * dt

    if @x < 0
      @x = 0
      @dx = -@dx
    end

    if @x > @width - (@msg.size * @text.width)
      @x = @width - (@msg.size * @text.width)
      @dx = -@dx
    end

    if @y < 0
      @y = 0
      @dy = -@dy
    end

    if @y > @height - (@text.height)
      @y = @height - (@text.height)
      @dy = -@dy
    end
  end

  def draw
    clear(0, 0, 50)
    @text.color(PF::Pixel.random)
    @text.draw(@screen, @msg, @x.to_i, @y.to_i)
  end
end

engine = TextGame.new(160, 100, 4).run!
