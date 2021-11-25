module PF
  module SpriteAge
    property lifespan : Float64 = Float64::INFINITY
    property age : Float64 = 0.0

    def dead?
      self.age >= self.lifespan
    end

    def update_age(dt : Float64)
      self.age += dt
    end
  end
end
