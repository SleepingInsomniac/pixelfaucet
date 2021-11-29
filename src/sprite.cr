require "crystaledge"

module PF
  abstract class Sprite
    include CrystalEdge

    def self.build
      sprite = new
      yield sprite
      sprite
    end

    property position : Vector2
    property velocity : Vector2
    property scale : Vector2
    property rotation : Float64
    property rotation_speed : Float64
    property mass : Float64 = 10.0

    def initialize
      @position = Vector2.new(0.0, 0.0)
      @velocity = Vector2.new(0.0, 0.0)
      @scale = Vector2.new(1.0, 1.0)
      @rotation = 0.0
      @rotation_speed = 0.0
    end

    def update_position(dt : Float64)
      @rotation += @rotation_speed * dt
      @position += @velocity * dt
    end

    def distance_between(other)
      self.position.distance(other.position)
    end

    abstract def update(dt : Float64)
    abstract def draw(engine : Game)
  end
end
