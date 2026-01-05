require "./entity"
require "./entity/entity_age"

module PF
  class Particle < Entity
    include EntityAge

    def update(dt : Float64)
      update_age(dt)
      return if dead?
      super(dt)
    end

    def draw(engine)
      return if dead?
      brightness = ((((@lifespan - @age) / @lifespan) * 255) / 2).to_u8
      color = RGBA.new(brightness, brightness, brightness)
      engine.draw_point(@position.x.to_i, @position.y.to_i, color)
    end
  end
end
