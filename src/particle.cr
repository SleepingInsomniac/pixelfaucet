require "./sprite"
require "./sprite/age"

module PF
  class Particle < Sprite
    include SpriteAge

    def update(dt : Float64)
      update_age(dt)
      return if dead?
      update_position(dt)
    end

    def draw(engine)
      return if dead?
      brightness = ((((@lifespan - @age) / @lifespan) * 255) / 2).to_u8
      color = Pixel.new(r: brightness, g: brightness, b: brightness)
      engine.draw_point(@position.x.to_i, @position.y.to_i, color)
    end
  end
end
