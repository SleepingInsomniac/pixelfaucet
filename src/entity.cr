require "./sprite"

module PF
  # An entity is an object with a sprite and a physics body
  class Entity
    property sprite : Sprite? = nil

    property position : Point(Float64) = Point.new(0.0, 0.0)
    property velocity : Point(Float64) = Point.new(0.0, 0.0)
    property rotation : Float64 = 0.0
    property rotation_speed : Float64 = 0.0
    property mass : Float64 = 1.0

    def initialize(@sprite = nil)
    end

    def initialize(sprite_path : String)
      @sprite = Sprite.new(sprite_path)
    end

    def update(dt : Float64)
      @rotation += @rotation_speed * dt
      @position += @velocity * dt
    end

    def distance(other : Entity)
      position.distance(other.position)
    end
  end
end
