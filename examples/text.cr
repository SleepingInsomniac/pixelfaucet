require "../src/game"

class TextGame < PF::Game
  def initialize(*args, **kwargs)
    super
    @x = 0.0
    @y = 0.0
    @dx = 50.0
    @dy = 50.0
    @msg = "Hello, World!"
    @color = PF::Pixel.random
    @font = Pixelfont::Font.new("#{__DIR__}/../lib/pixelfont/fonts/pixel-5x7.txt")
  end

  def update(dt)
    @x += @dx * dt
    @y += @dy * dt

    if @x < 0
      @x = 0
      @dx = -@dx
      @color = PF::Pixel.random
    end

    if @x > width - @font.width_of(@msg)
      @x = width - @font.width_of(@msg)
      @dx = -@dx
      @color = PF::Pixel.random
    end

    if @y < 0
      @y = 0
      @dy = -@dy
      @color = PF::Pixel.random
    end

    if @y > height - @font.line_height
      @y = height - @font.line_height
      @dy = -@dy
      @color = PF::Pixel.random
    end
  end

  def draw
    clear(0, 0, 50)
    draw_string(@msg, @x.to_i, @y.to_i, @font, @color)
  end
end

engine = TextGame.new(160, 100, 4).run!
